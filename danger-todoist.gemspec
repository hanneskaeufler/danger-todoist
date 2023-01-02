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
  spec.required_ruby_version = ">= 3"

  spec.add_runtime_dependency "danger-plugin-api", "~> 1"

  # General ruby development
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13"

  # Testing support
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "simplecov", "~> 0.22"

  # Linting code and docs
  spec.add_development_dependency "rubocop", "1.42"
  spec.add_development_dependency "rubocop-rake", "0.6.0"
  spec.add_development_dependency "rubocop-rspec", "2.16.0"
  spec.add_development_dependency "yard", "~> 0.9.28"

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require "pry"
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency "pry", "~> 0"
end
