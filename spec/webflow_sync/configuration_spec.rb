# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebflowSync::Configuration do
  before(:each) do
    @skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
  end

  after(:each) do
    WebflowSync.configuration.skip_webflow_sync = @skip_webflow_sync # rubocop:disable RSpec/InstanceVariable
  end

  context 'when skip_webflow_sync is false' do
    it 'is false' do
      WebflowSync.configure do |config|
        config.skip_webflow_sync = false
      end

      expect(WebflowSync.configuration.skip_webflow_sync).to be(false)
    end
  end

  context 'when skip_webflow_sync is true' do
    it 'is true' do
      WebflowSync.configure do |config|
        config.skip_webflow_sync = true
      end

      expect(WebflowSync.configuration.skip_webflow_sync).to be(true)
    end
  end

  context 'when sync_webflow_slug is true' do
    before(:each) do
      @sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      WebflowSync.configure do |config|
        config.sync_webflow_slug = true
      end
    end

    after(:each) do
      WebflowSync.configure do |config|
        config.sync_webflow_slug = @sync_webflow_slug # rubocop:disable RSpec/InstanceVariable
      end
    end

    it 'is true' do
      expect(WebflowSync.configuration.sync_webflow_slug).to be(true)
    end
  end
end
