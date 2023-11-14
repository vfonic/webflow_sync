# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  RSpec.describe WebflowSync::CreateItemJob do
    let(:model_name) { 'articles' }
    let(:article) { create(:article) }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, create_item: nil) }

    let(:sync_webflow_slug) { false }
    let(:webflow_site_id) { ENV.fetch('WEBFLOW_SITE_ID') }

    before(:each) do
      @old_sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      @old_webflow_site_id = WebflowSync.configuration.webflow_site_id

      WebflowSync.configure do |config|
        config.sync_webflow_slug = sync_webflow_slug
        config.webflow_site_id = webflow_site_id
      end
    end

    after(:each) do
      WebflowSync.configure do |config|
        config.sync_webflow_slug = @old_sync_webflow_slug
        config.webflow_site_id = @old_webflow_site_id
      end
    end

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::CreateItemJob.perform_now(model_name, record_id)

        expect(mock_webflow_api).not_to have_received(:create_item)
      end
    end

    context 'when webflow_site_id is nil' do
      let(:webflow_site_id) { nil }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::CreateItemJob.perform_now(model_name, article.id)

        expect(mock_webflow_api).not_to have_received(:create_item)
      end
    end

    it 'creates item on Webflow', vcr: { cassette_name: 'webflow/create_item', allow_unused_http_interactions: false } do
      old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
      WebflowSync.configuration.skip_webflow_sync = false
      WebflowSync::CreateItemJob.perform_now(model_name, article.id)
      WebflowSync.configuration.skip_webflow_sync = old_skip_webflow_sync

      expect(article.reload.webflow_item_id).to be_present
    end

    it 'creates published item on Webflow', vcr: { cassette_name: 'webflow/create_and_publish_item', allow_unused_http_interactions: false } do # rubocop:disable RSpec/ExampleLength
      old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
      WebflowSync.configuration.skip_webflow_sync = false
      WebflowSync::CreateItemJob.perform_now(model_name, article.id)
      WebflowSync.configuration.skip_webflow_sync = old_skip_webflow_sync

      article_item = WebflowSync::Api.new(webflow_site_id).get_item('articles', article.reload.webflow_item_id)
      expect(article_item.fetch(:lastPublished)).to be_present
    end

    context 'when sync_webflow_slug is true' do
      let(:sync_webflow_slug) { true }

      it 'syncs webflow_slug', vcr: { cassette_name: 'webflow/create_item', allow_unused_http_interactions: false } do
        old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
        WebflowSync.configuration.skip_webflow_sync = false
        WebflowSync::CreateItemJob.perform_now(model_name, article.id)
        WebflowSync.configuration.skip_webflow_sync = old_skip_webflow_sync

        expect(article.reload.webflow_slug).to be_present
      end
    end

    context 'when sync_webflow_slug is false' do
      let(:sync_webflow_slug) { false }

      it 'does not sync webflow slug', vcr: { cassette_name: 'webflow/create_item', allow_unused_http_interactions: false } do
        old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
        WebflowSync.configuration.skip_webflow_sync = false
        WebflowSync::CreateItemJob.perform_now(model_name, article.id)
        WebflowSync.configuration.skip_webflow_sync = old_skip_webflow_sync

        expect(article.reload.webflow_slug).to be_nil
      end
    end

    context 'when slug name is passed' do
      let(:collection_slug) { 'stories' }

      it 'creates item on Webflow',
         vcr: { cassette_name: 'webflow/create_sync_to_specified_collection', allow_unused_http_interactions: false } do
        old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
        WebflowSync.configuration.skip_webflow_sync = false
        WebflowSync::CreateItemJob.perform_now(model_name, article.id, 'stories')
        WebflowSync.configuration.skip_webflow_sync = old_skip_webflow_sync

        expect(article.reload.webflow_item_id).to be_present
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
