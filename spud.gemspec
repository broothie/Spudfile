
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spud'

Gem::Specification.new do |gem|
  gem.name        = 'spud'
  gem.version     = Spud::VERSION
  gem.summary     = 'A build tool'
  gem.description = 'Spud is a rule tool, writ
ten as a ruby DSL'
  gem.homepage    = 'https://github.com/broothie/spud#readme'
  gem.license     = 'MIT'

  gem.authors     = ['Andrew Booth']
  gem.email       = 'andrew@andrewbooth.xyz'

  gem.files       = Dir.glob('lib/**/*.rb')
  gem.executables << 'spud'

  gem.add_development_dependency 'bundler', '~> 1.17'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'pry', '~> 0.13.1'
  gem.add_development_dependency 'byebug', '~> 11.0'
end
