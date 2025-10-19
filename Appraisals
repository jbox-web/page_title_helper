# frozen_string_literal: true

appraise 'rails_7.2' do
  gem 'rails', '~> 7.2.0'

  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0") }' do
    gem 'uri'
  end
end

appraise 'rails_8.0' do
  gem 'rails', '~> 8.0.0'
end

appraise 'rails_8.1' do
  gem 'rails', '~> 8.1.0.rc1'
end
