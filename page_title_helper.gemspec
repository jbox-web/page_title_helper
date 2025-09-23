# frozen_string_literal: true

require_relative 'lib/page_title_helper/version'

Gem::Specification.new do |s|
  s.name        = 'page_title_helper'
  s.version     = PageTitleHelper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Lukas Westermann']
  s.email       = ['lukas.westermann@gmail.com']
  s.homepage    = 'https://github.com/lwe/page_title_helper'
  s.summary     = 'Simple, internationalized and DRY page titles and headings for Rails.'
  s.description = 'Simple, internationalized and DRY page titles and headings for Rails.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.2.0'

  s.files = Dir['README.md', 'CHANGELOG.md', 'LICENSE', 'lib/**/*.rb']

  s.add_dependency 'rails', '>= 7.1'
end
