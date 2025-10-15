# Interceptors

Interceptor-driven use case toolkit for Ruby and Rails applications.

## Features
- Consistent `Result` object with `ok?`/`err?` helpers and metadata.
- Base `UseCase` class with interceptor pipeline support.
- Built-in interceptors for logging, validation, retries, timeouts, transactions, and idempotency.
- Uniform error taxonomy (`AppError`, `ValidationError`, `AuthError`) with HTTP semantics.
- Instrumentation via `ActiveSupport::Notifications`.
- Optional Rails responder helper for controllers or jobs.

## Installation

Add the gem to your bundle:

```ruby
gem "interceptors"
```

## Usage

```ruby
class CreateUser < Interceptors::UseCase
  use Interceptors::LoggingInterceptor.new
  use Interceptors::ValidationInterceptor.new do |ctx|
    errors = {}
    errors[:email] = "is required" if ctx[:email].to_s.strip.empty?
    errors
  end

  private

  def execute(ctx)
    user = User.create!(email: ctx[:email])
    Interceptors::Result.ok(user)
  rescue ActiveRecord::RecordInvalid => e
    Interceptors::Result.err(Interceptors::ValidationError.new(e.record.errors.to_hash))
  end
end

result = CreateUser.call(email: "user@example.com")
result.ok? #=> true
```

### Richer example: checkout flow

```ruby
class CheckoutOrder < Interceptors::UseCase
  use Interceptors::LoggingInterceptor.new
  use Interceptors::TimeoutInterceptor.new(seconds: 3)
  use Interceptors::RetryInterceptor.new(tries: 3, on: [ActiveRecord::Deadlocked])
  use Interceptors::TransactionInterceptor.new
  use Interceptors::IdempotencyInterceptor.new(key_proc: ->(ctx) { "checkout:#{ctx[:idempotency_key]}" })

  use Interceptors::ValidationInterceptor.new do |ctx|
    errors = {}
    errors[:cart_id] = "is required" if ctx[:cart_id].to_s.empty?
    errors[:payment_token] = "is required" if ctx[:payment_token].to_s.empty?
    errors
  end

  private

  def execute(ctx)
    guard_policy!(ctx[:actor], ctx[:cart_id])

    cart    = Cart.lock.find(ctx[:cart_id])
    payment = charge_payment!(ctx[:payment_token], cart.total_cents)

    order = persist_order!(cart, payment, ctx)

    Interceptors::Result.ok(order, meta: { order_id: order.id, payment_id: payment.id })
  rescue PaymentGateway::Error => e
    Interceptors::Result.err(
      Interceptors::AppError.new(e.message, code: "payment_failed", http_status: 422, details: { gateway: e.code })
    )
  end

  def guard_policy!(actor, cart_id)
    allowed = actor&.can?(:checkout, cart_id)
    raise Interceptors::AuthError.new unless allowed
  end

  def charge_payment!(token, amount_cents)
    PaymentGateway.charge!(token: token, amount_cents: amount_cents)
  end

  def persist_order!(cart, payment, ctx)
    Order.create!(
      user: ctx[:actor].user,
      total_cents: cart.total_cents,
      payment_reference: payment.id,
      shipping_address: ctx[:shipping_address]
    ).tap do |order|
      cart.line_items.each do |line_item|
        order.order_lines.create!(sku: line_item.sku, qty: line_item.quantity, price_cents: line_item.price_cents)
      end
    end
  end
end

result = CheckoutOrder.call(
  cart_id: params[:cart_id],
  payment_token: params[:payment_token],
  shipping_address: params[:shipping_address],
  idempotency_key: request.headers["Idempotency-Key"],
  actor: Current.session
)

if result.ok?
  render json: { order_id: result.value.id }, status: :created
else
  err = result.error
  render json: { error: err.code, message: err.message, details: err.details }, status: err.http_status
end
```

Instrument use cases with ActiveSupport:

```ruby
ActiveSupport::Notifications.subscribe("use_case.finish") do |_name, _start, _finish, _id, payload|
  Rails.logger.info("[UseCase] #{payload[:name]} ok=#{payload[:ok]}")
end
```

For Rails controllers, include the responder helper:

```ruby
class UsersController < ApplicationController
  include Interceptors::Rails::UseCaseResponder

  def create
    respond_with_use_case(CreateUser.call(user_params))
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `bundle exec rspec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
