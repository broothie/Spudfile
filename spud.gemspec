
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spud'

Gem::Specification.new do |s|
  s.name        = 'spud'
  s.version     = '0.1.0'
  s.date        = '2010-04-05'
  s.summary     = 'A build tool'
  s.description = 'Spud is a build tool, written as a ruby DSL'
  s.authors     = ['Andrew Booth']
  s.email       = 'adbooth8@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb')
  s.homepage    = 'https://github.com/broothie/spud#readme'
  s.license     = 'MIT'

  s.files       = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  s.executables << 'spud'

  s.add_development_dependency 'bundler', '~> 1.17'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
