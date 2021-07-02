# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::CreateItemJob, type: :job do
    let(:collection_slug) { 'articles' }
    let(:article) { create(:article) }
    let(:mock_webflow_api) do
      instance_double('mock_webflow_api', create_item: nil)
    end

    before(:each) do
      WebflowSync.configure do |config|
        config.webflow_site_id = 'webflow_site_id'
        config.api_token = 'webflow_api_token'
      end
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
          config.webflow_site_id = 'webflow_site_id'
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

    context 'when publish_to_all_domains is true' do
      before(:each) do
        @publish_to_all_domains = WebflowSync.configuration.publish_to_all_domains
        WebflowSync.configure do |config|
          config.publish_to_all_domains = true
        end
      end

      after(:each) do
        WebflowSync.configure do |config|
          config.publish_to_all_domains = @publish_to_all_domains
        end
      end

      it 'publishes all domains', vcr: { cassette_name: 'webflow/create_item_and_publish', record: :once } do
        WebflowSync::CreateItemJob.perform_now(collection_slug, article.id)
      end
    end
  end
end
