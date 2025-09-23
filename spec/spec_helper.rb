# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

require 'action_view'

# This line can be dropped once we no longer support Rails 7.2
require 'uri'

# Start SimpleCov
SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter])
  add_filter 'spec/'
end

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end

# fake global Rails module
module Rails
  class << self
    def root
      @root ||= Pathname.new('/this/is/just/for/testing/page_title_helper')
    end

    def env
      'test'
    end
  end
end

# Mock ActionView a bit to allow easy (fake) template assignment
class TestView < ActionView::Base
  attr_reader :controller

  def initialize(controller_path = nil, action = nil) # rubocop:disable Lint/MissingSuper
    @controller = ActionView::TestCase::TestController.new
    @controller.controller_path = controller_path
    params[:action] = action if action
  end

  def controller!(controller_path, action)
    @controller.controller_path = controller_path
    params[:action] = action
  end
end

require 'page_title_helper'
