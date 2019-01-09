lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "todoist/gem_version.rb"

Gem::Specification.new do |spec|
  spec.name          = "danger-todoist"
  spec.version       = Todoist::VERSION
  spec.authors       = ["Hannes Käufler"]
  spec.email         = ["hannes.kaeufler@gmail.com"]
  spec.description   = "A danger plugin for spotting introduced todos."
  spec.summary       = "Marking something with a todo is very common during implementing a new feature. Often those todos will get missed in code review."
  spec.homepage      = "https://github.com/hanneskaeufler/danger-todoist"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.3.8"

  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"

  # General ruby development
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0"

  # Testing support
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.12"

  # Linting code and docs
  spec.add_development_dependency "rubocop", "0.50"
  spec.add_development_dependency "yard", "~> 0.9.12"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  # If you want to work on older builds of ruby
  spec.add_development_dependency "listen", "3.0.7"

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require "pry"
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency "pry", "~> 0"
end
