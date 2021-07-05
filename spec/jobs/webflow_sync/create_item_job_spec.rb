# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::CreateItemJob, type: :job do
    let(:collection_slug) { 'articles' }
    let(:article) { create(:article) }
    let(:mock_webflow_api) do
      instance_double('mock_webflow_api', create_item: nil)
    end

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::CreateItemJob.perform_now(collection_slug, record_id)

        expect(mock_webflow_api).not_to have_received(:create_item)
      end
    end

    context 'when webflow_site_id is not present' do
      before(:each) do
        WebflowSync.configure do |config|
          config.webflow_site_id = nil
        end
      end

      after(:each) do
        WebflowSync.configure do |config|
          config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
        end
      end

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::CreateItemJob.perform_now(collection_slug, article.id)

        expect(mock_webflow_api).not_to have_received(:create_item)
      end
    end

    it 'creates item on Webflow', vcr: { cassette_name: 'webflow/create_item' } do
      WebflowSync::CreateItemJob.perform_now(collection_slug, article.id)

      expect(article.reload.webflow_item_id).to be_present
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
          config.sync_webflow_slug = @sync_webflow_slug
        end
      end

      it 'syncs webflow_slug', vcr: { cassette_name: 'webflow/create_item' } do
        WebflowSync::CreateItemJob.perform_now(collection_slug, article.id)

        expect(article.reload.webflow_slug).to be_present
      end
    end

    context 'when sync_webflow_slug is false' do
      before(:each) do
        @sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
        WebflowSync.configure do |config|
          config.sync_webflow_slug = false
        end
      end

      after(:each) do
        WebflowSync.configure do |config|
          config.sync_webflow_slug = @sync_webflow_slug
        end
      end

      it 'does not sync webflow slug', vcr: { cassette_name: 'webflow/create_item' } do
        WebflowSync::CreateItemJob.perform_now(collection_slug, article.id)

        expect(article.reload.webflow_slug).to be_nil
      end
    end

    context 'when publish_on_sync is true' do
      before(:each) do
        @publish_on_sync = WebflowSync.configuration.publish_on_sync
        WebflowSync.configure do |config|
          config.publish_on_sync = true
        end
      end

      after(:each) do
        WebflowSync.configure do |config|
          config.publish_on_sync = @publish_on_sync
        end
      end

      it 'publishes all domains', vcr: { cassette_name: 'webflow/create_item_and_publish' } do
        publish_uri = "https://api.webflow.com/sites/#{ENV.fetch('WEBFLOW_SITE_ID')}/publish"

        WebflowSync::CreateItemJob.perform_now(collection_slug, create(:article).id)

        expect(WebMock).to have_requested(:post, publish_uri)
      end
    end
  end
end
