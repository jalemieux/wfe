lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wfe'


Gem::Specification.new do |s|
  s.name        = 'wfe'
  #s.version     = Wfe::VERSION
  s.version     = '0.0.1'
  s.date        = Time.now
  s.summary     = "Workflow Engine"
  s.description = "Persistent workflow engine using active record"
  s.authors     = ["Jacques Lemieux"]
  s.email       = 'jacques@marketo.com'
  s.add_dependency "activerecord", ">= 3.2.13"
  s.bindir = '/usr/bin'
  s.post_install_message = "Enjoy the gem!"
  s.require_paths = ["lib"]


  s.files = Dir[
    'bin/*.rb',
    'lib/**/*.rb',
    'examples/**/*.rb',
    'doc/*',
    'migrations/*_migration.rb',
    'rakelib/*',
    'spec/*'
  ]

  #s.homepage    = ''
end
