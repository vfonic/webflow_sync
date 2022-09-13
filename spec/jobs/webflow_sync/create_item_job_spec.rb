# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  RSpec.describe WebflowSync::CreateItemJob, type: :job do
    let(:model_name) { 'articles' }
    let(:article) { create(:article) }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, create_item: nil) }

    let(:sync_webflow_slug) { false }
    let(:publish_on_sync) { false }
    let(:webflow_site_id) { ENV.fetch('WEBFLOW_SITE_ID') }

    before(:each) do
      @old_publish_on_sync = WebflowSync.configuration.publish_on_sync
      @old_sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      @old_webflow_site_id = WebflowSync.configuration.webflow_site_id

      WebflowSync.configure do |config|
        config.publish_on_sync = publish_on_sync
        config.sync_webflow_slug = sync_webflow_slug
        config.webflow_site_id = webflow_site_id
      end
    end

    after(:each) do
      WebflowSync.configure do |config|
        config.publish_on_sync = @old_publish_on_sync
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

    it 'creates item on Webflow', vcr: { cassette_name: 'webflow/create_item' } do
      WebflowSync::CreateItemJob.perform_now(model_name, article.id)

      expect(article.reload.webflow_item_id).to be_present
    end

    context 'when sync_webflow_slug is true' do
      let(:sync_webflow_slug) { true }

      it 'syncs webflow_slug', vcr: { cassette_name: 'webflow/create_item' } do
        WebflowSync::CreateItemJob.perform_now(model_name, article.id)

        expect(article.reload.webflow_slug).to be_present
      end
    end

    context 'when sync_webflow_slug is false' do
      let(:sync_webflow_slug) { false }

      it 'does not sync webflow slug', vcr: { cassette_name: 'webflow/create_item' } do
        WebflowSync::CreateItemJob.perform_now(model_name, article.id)

        expect(article.reload.webflow_slug).to be_nil
      end
    end

    context 'when publish_on_sync is true' do
      let(:publish_on_sync) { true }

      it 'publishes all domains', vcr: { cassette_name: 'webflow/create_item_and_publish' } do
        publish_uri = "https://api.webflow.com/sites/#{ENV.fetch('WEBFLOW_SITE_ID')}/publish"

        WebflowSync::CreateItemJob.perform_now(model_name, create(:article).id)

        expect(WebMock).to have_requested(:post, publish_uri)
      end
    end

    context 'when slug name is passed' do
      let(:collection_slug) { 'stories' }

      it 'creates item on Webflow', vcr: { cassette_name: 'webflow/create_sync_to_specified_collection' } do
        WebflowSync::CreateItemJob.perform_now(model_name, article.id, 'stories')

        expect(article.reload.webflow_item_id).to be_present
      end

      it 'syncs with correct WebFlow collection', vcr: { cassette_name: 'webflow/create_check_specified_collection' } do
        result = WebflowSync::CreateItemJob.perform_now(model_name, article.id, 'stories')
        client = Webflow::Client.new

        collection = client.collection(result['_cid'])

        expect(collection['slug']).to eq collection_slug
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
