# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ruby86/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jan Chmelicek']
  gem.email         = ['chmeldax@gmail.com']
  gem.description   = %q{Ruby x86 emulator}
  gem.summary       = %q{Ruby x86 emulator}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'ruby86'
  gem.require_paths = ['ruby86']
  gem.version       = Ruby86::VERSION

  gem.add_development_dependency 'rspec'
end
