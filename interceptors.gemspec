require_relative "lib/interceptors/version"

Gem::Specification.new do |spec|
  spec.name          = "interceptors"
  spec.version       = Interceptors::VERSION
  spec.authors       = ["Laerti papa"]
  spec.email         = ["laertis.pappas@gmail.com"]

  spec.summary       = "Interceptor-driven use case toolkit for Ruby and Rails applications."
  spec.description   = "Interceptors provides a production-ready pattern for building use case objects with consistent results, interceptor pipelines, and instrumentation."
  spec.homepage      = "https://github.com/laertispappas/interceptors"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.glob("lib/**/*") +
               %w[README.md CHANGELOG.md LICENSE Gemfile Rakefile]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "rspec"
end
