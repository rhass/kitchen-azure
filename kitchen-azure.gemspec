# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/azure_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-azure'
  spec.version       = Kitchen::Driver::MSAZURE_VERSION
  spec.authors       = ['Grant Ellis']
  spec.email         = ['grant.ellis@marks-and-spencer.com']
  spec.description   = %q{A Test Kitchen Driver for Microsoft Azure}
  spec.summary       = 'Builds test-kitchen Linux VMs in Microsoft Azure'
  spec.homepage      = 'https://github.com/DigitalInnovation/kitchen-azure'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.2'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'azure'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'countloc'
end
