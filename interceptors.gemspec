
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "interceptors/version"

Gem::Specification.new do |spec|
  spec.name          = "interceptors"
  spec.version       = Interceptors::VERSION
  spec.authors       = ["Laerti Papa"]
  spec.email         = ["laerti.papa@xing.com"]

  spec.summary       = %q{Pedestal like interceptors service objects in Ruby}
  spec.description   = %q{Pedestal like interceptors service objects in Ruby, aka pipe and filter architecture}
  spec.homepage      = "https://www.github.com/laertispappas/interceptors"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
