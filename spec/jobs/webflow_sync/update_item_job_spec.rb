# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  RSpec.describe WebflowSync::UpdateItemJob do
    let(:model_name) { 'articles' }
    let(:article) { create(:article, webflow_item_id: '60defde681813e53c6be97ea') }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, update_item: nil) }

    let(:sync_webflow_slug) { false }
    let(:webflow_site_id) { ENV.fetch('WEBFLOW_SITE_ID') }

    before(:each) do
      @old_publish_on_sync = WebflowSync.configuration.publish_on_sync
      @old_sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      @old_webflow_site_id = WebflowSync.configuration.webflow_site_id

      WebflowSync.configure do |config|
        config.publish_on_sync = false
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

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do
      article.update!(title: 'Updated article title')

      result = WebflowSync::UpdateItemJob.perform_now(model_name, article.id)

      expect(result['name']).to eq 'Updated article title'
    end

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(model_name, record_id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_site_id is nil' do
      let(:webflow_site_id) { nil }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(model_name, article.id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_item_id is nil' do
      let(:mock_webflow_api) do
        instance_double(WebflowSync::Api, update_item: nil, create_item: nil)
      end

      before(:each) do
        article.update!(webflow_item_id: nil)
      end

      it 'calls CreateItemJob' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(model_name, article.id)

        expect(mock_webflow_api).to have_received(:create_item)
      end
    end

    context 'when slug name is passed' do
      let(:collection_slug) { 'stories' }
      let(:article) { create(:article, webflow_item_id: '60e322688be95d22c22d5041') }

      it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_sync_to_specified_collection' } do
        article.update!(title: 'Updated article title')

        result = WebflowSync::UpdateItemJob.perform_now(model_name, article.id, 'stories')

        expect(result['name']).to eq 'Updated article title'
      end

      it 'syncs with correct WebFlow collection', vcr: { cassette_name: 'webflow/update_check_specified_collection' } do
        result = WebflowSync::UpdateItemJob.perform_now(model_name, article.id, 'stories')
        client = Webflow::Client.new

        collection = client.collection(result['_cid'])

        expect(collection['slug']).to eq collection_slug
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
