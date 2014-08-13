# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'migrer/version'

Gem::Specification.new do |gem|
  gem.name          = "migrer"
  gem.version       = Migrer::VERSION
  gem.licenses      = ['MIT']
  gem.authors       = ["Sathya Sekaran", "Michael Durnhofer"]
  gem.email         = ["sfsekaran@gmail.com"]
  gem.description   = %q{The polite data migration valet.}
  gem.summary       = %q{The 'migrer' gem helps generate, execute, and keep track of data migrations.}
  gem.homepage      = "http://github.com/sfsekaran/migrer"

  gem.rubyforge_project = "migrer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib", "script", "db"]

  gem.add_runtime_dependency "activerecord", ">= 3.2", "< 5.0"
end
