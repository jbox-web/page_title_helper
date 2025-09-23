# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PageTitleHelper do
  let(:view) { TestView.new('contacts', 'list') }

  before do
    I18n.load_path = [File.join(File.dirname(__FILE__), 'fixtures/en.yml')]
    I18n.reload!
  end

  describe PageTitleHelper::Interpolations do
    it 'interpolate :app and :title' do
      expect(described_class.app({})).to eq 'Page title helper'
      expect(described_class.app(app: 'Appname')).to eq 'Appname'
      expect(described_class.title(title: 'untitled')).to eq 'untitled'
    end

    it 'allow adding custom interpolations' do
      # extend Interpolations
      PageTitleHelper.interpolates(:app_reverse) { |env| app(env).reverse.downcase }

      expect(described_class.app_reverse(app: 'Anna')).to eq 'anna'
      expect(described_class.interpolate(':app_reverse', app: 'app')).to eq 'ppa'
    end

    it 'interpolate in correct order, i.e. longest first' do
      PageTitleHelper.interpolates(:foobar) { |_env| 'foobar' }
      PageTitleHelper.interpolates(:foobar_test) { |_env| 'foobar_test' }
      PageTitleHelper.interpolates(:title_foobar) { |_env| 'title_foobar' }

      result = 'title_foobar / foobar_test / foobar / foobar_x'
      expect(described_class.interpolate(':title_foobar / :foobar_test / :foobar / :foobar_x', {})).to eq result
    end
  end

  describe '#page_title (define w/ block)' do
    it 'return title from block and render with app name' do
      expect(view.page_title { 'foo' }).to eq 'foo'
      expect(view.page_title).to eq 'foo - Page title helper'
    end

    it 'set custom title using a translation with a placeholder' do
      expect(view.page_title { I18n.t(:placeholder, name: 'Bella') }).to eq 'Displaying Bella'
      expect(view.page_title).to eq 'Displaying Bella - Page title helper'
    end
  end

  describe '#page_title! (define)' do
    it 'set page title' do
      expect(view.page_title!('test')).to eq 'test'
      expect(view.page_title).to eq 'test - Page title helper'
    end

    it 'set page title and interpret second argument as custom format' do
      described_class.formats[:bang] = ':title !! :app'

      expect(view.page_title!('test', :bang)).to eq 'test'
      expect(view.page_title).to eq 'test !! Page title helper'
    end
  end

  describe '#page_title (rendering)' do
    it 'read default title from I18n, based on controller/action' do
      expect(view.page_title).to eq 'contacts.list.title - Page title helper'
    end

    it 'only print app name if format: :app' do
      expect(view.page_title(format: :app)).to eq 'Page title helper'
    end

    it 'print custom app name if :app defined and format: :app' do
      expect(view.page_title(app: 'Some app', format: :app)).to eq 'Some app'
    end

    it 'use custom format, if :format option is defined' do
      expect(view.page_title { 'test' }).to eq 'test'
      expect(view.page_title(app: 'Some app', format: ':app :: :title')).to eq 'Some app :: test'
      expect(view.page_title(format: 'Some app / :title')).to eq 'Some app / test'
    end

    it 'return just title if format: false is passed' do
      expect(view.page_title { 'untitled' }).to eq 'untitled'
      expect(view.page_title(format: false)).to eq 'untitled'
    end

    it 'return title if format: false and when using the DRY-I18n titles' do
      expect(view.page_title(format: false)).to eq 'contacts.list.title'
    end

    it 'render translated :"app.tagline" if no title is available' do
      view.controller! 'view/does', 'not_exist'
      expect(view.page_title).to eq 'Default - Page title helper'
    end

    it 'render use controller.title as first fallback, if no title exists' do
      view.controller! 'admin/account', 'index'
      expect(view.page_title(default: 'Other default')).to eq 'Account administration - Page title helper'
    end

    it 'not fallback to controller.title if controller.action.title exists' do
      view.controller! 'admin/account', 'show'
      expect(view.page_title(default: 'Other default')).to eq 'Account - Page title helper'
    end

    it 'fallback to controller.new.title if create has no title' do
      view.controller! 'admin/account', 'create'
      expect(view.page_title(default: 'Other default')).to eq 'New account - Page title helper'
    end

    it 'fallback to controller.edit.title if update has no title' do
      view.controller! 'admin/account', 'update'
      expect(view.page_title(default: 'Other default')).to eq 'Edit account - Page title helper'
    end

    it 'render custom "default" string, if title is not available nor controller.title' do
      view.controller! 'view/does', 'not_exist'
      expect(view.page_title(default: 'Some default')).to eq 'Some default - Page title helper'
    end

    it 'render custom default translation, if title is not available nor controller.title' do
      view.controller! 'view/does', 'not_exist'
      expect(view.page_title(default: :'app.other_tagline')).to eq 'Other default - Page title helper'
    end
  end

  describe 'README.md' do
    it 'interpolate :controller' do
      described_class.interpolates(:controller) { |env| env[:view].controller.controller_name.humanize }

      expect(view.page_title(format: ':title - :controller')).to eq 'contacts.list.title - Test'
    end
  end

  context 'when MultipleFormatsTest' do
    describe '#page_title supporting multiple formats through arrays' do
      it 'accept an array passed in the page_title block and use the second argument as format' do
        view.page_title { ['Oh my...!', ':title // :app'] }
        expect(view.page_title).to eq 'Oh my...! // Page title helper'
      end

      it 'still return title as string and not the array' do
        expect(view.page_title { ['Oh my...!', ':title // :app'] }).to eq 'Oh my...!'
      end
    end

    describe '#page_title with format aliases' do
      before do
        described_class.formats[:myformat] = ':title <-> :app'
      end

      it 'have a default alias named :app' do
        expect(view.page_title(format: :app)).to eq 'Page title helper'
      end

      it 'allow custom aliases to be defined and used' do
        view.page_title { 'Test' }
        expect(view.page_title(format: :myformat)).to eq 'Test <-> Page title helper'
      end

      it 'fallback to default format, if array is not big enough (i.e. only contains single element...)' do
        expect(view.page_title { ['Test'] }).to eq 'Test'
        expect(view.page_title).to eq 'Test - Page title helper'
      end

      describe 'used with the array block' do
        it 'also allow aliases returned in that array thingy' do
          expect(view.page_title { ['Test', :myformat] }).to eq 'Test'
          expect(view.page_title).to eq 'Test <-> Page title helper'
        end

        it 'override locally supplied :format arguments' do
          expect(view.page_title { ['Something', '* * * :title * * *'] }).to eq 'Something'
          # yeah, using x-tra ugly titles :)
          expect(view.page_title(format: '-= :title =-')).to eq '* * * Something * * *'
        end
      end
    end

    describe '#page_title, aliases and YAML' do
      let(:view) { TestView.new }

      before do
        I18n.load_path = [File.join(File.dirname(__FILE__), 'fixtures/en_wohaapp.yml')]
        I18n.reload!
        described_class.formats[:promo] = ':app > :title'
      end

      it 'allow to override format through YAML' do
        view.controller! 'pages', 'features'
        expect(view.page_title).to eq 'Wohaapp > Feature comparison'
      end

      it 'handle raw string formats from YAML as well' do
        view.controller! 'pages', 'signup'
        expect(view.page_title).to eq 'Sign up for Wohaapp now!'
      end
    end
  end
end
