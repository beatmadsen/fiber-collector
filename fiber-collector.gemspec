# frozen_string_literal: true

require_relative "lib/fiber/collector/version"


Gem::Specification.new do |spec|
  spec.name = "fiber-collector"
  spec.version = Fiber::Collector::VERSION
  spec.authors = ["Erik Madsen"]
  spec.email = ["beatmadsen@gmail.com"]

  spec.summary = "Collect results from multiple concurrently scheduled tasks"
  spec.description = "Simple constructs to collect results from multiple concurrently scheduled tasks inspired by JavaScript's Promise.all(), Promise.any() and Promise.race() methods"
  spec.homepage = 'https://github.com/beatmadsen/fiber-collector'
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/beatmadsen/fiber-collector'
  spec.metadata["changelog_uri"] = 'https://github.com/beatmadsen/fiber-collector/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
