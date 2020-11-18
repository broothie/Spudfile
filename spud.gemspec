require_relative 'lib/spud/version'

Gem::Specification.new do |gem|
  gem.name        = 'spud'
  gem.version     = Spud::VERSION
  gem.summary     = 'Spud is a task runner, in the form of a ruby DSL.'
  gem.homepage    = 'https://github.com/broothie/spud#readme'
  gem.license     = 'MIT'

  gem.authors     = ['Andrew Booth']
  gem.email       = 'andrew@andrewbooth.xyz'

  gem.files       = Dir['lib/**/*.rb']
  gem.executables << 'spud'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'pry', '~> 0.13.1'
  gem.add_development_dependency 'byebug', '~> 11.0'
end
