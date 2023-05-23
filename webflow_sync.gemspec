# frozen_string_literal: true

require_relative 'lib/webflow_sync/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.1'
  spec.name        = 'webflow_sync'
  spec.version     = WebflowSync::VERSION
  spec.authors     = ['Viktor']
  spec.email       = ['viktor.fonic@gmail.com']
  spec.homepage    = 'https://github.com/vfonic/webflow_sync'
  spec.summary     = 'Keep Rails models in sync with WebFlow.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 5.0'
  spec.add_dependency 'sprockets-rails'
  spec.add_dependency 'webflow-ruby'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
