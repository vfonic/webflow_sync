# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  RSpec.describe WebflowSync::UpdateItemJob do
    let(:model_name) { 'articles' }
    let(:article) { create(:article, webflow_item_id: '653817458c993c9a49fc411b') }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, update_item: nil, find_collection_id: nil) }
    let(:collection_slug) { 'articles' }
    let(:collection_id) { WebflowSync::Api.new(site_id: webflow_site_id).find_collection_id(collection_slug:) }
    let(:sync_webflow_slug) { false }
    let(:webflow_site_id) { ENV.fetch('WEBFLOW_SITE_ID') }

    before(:each) do
      @old_sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      @old_webflow_site_id = WebflowSync.configuration.webflow_site_id
      @old_skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync

      WebflowSync.configure do |config|
        config.sync_webflow_slug = sync_webflow_slug
        config.webflow_site_id = webflow_site_id
        config.skip_webflow_sync = false
      end
    end

    after(:each) do
      WebflowSync.configure do |config|
        config.sync_webflow_slug = @old_sync_webflow_slug
        config.webflow_site_id = @old_webflow_site_id
        config.skip_webflow_sync = @old_skip_webflow_sync
      end
    end

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do # rubocop:disable RSpec/ExampleLength
      title = 'Updated article title'
      article.title = title

      article.save!
      perform_enqueued_jobs

      item = WebflowSync::Api.new(site_id: webflow_site_id).get_item(collection_id:, webflow_item_id: article.webflow_item_id)
      expect(item.dig(:fieldData, :name)).to eq(title)
    end

    it 'publishes item on Webflow', vcr: { cassette_name: 'webflow/publish_item' } do # rubocop:disable RSpec/ExampleLength
      title = 'New live title'
      article.title = title

      article.save!
      perform_enqueued_jobs

      item = WebflowSync::Api.new(site_id: webflow_site_id).get_item(collection_id:, webflow_item_id: article.webflow_item_id)
      expect(item.dig(:fieldData, :name)).to eq(title)
      expect(Time.zone.parse(item.fetch(:lastPublished))).to be >= Time.zone.parse(item.fetch(:lastUpdated))
    end

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_id:, model_name:, id: record_id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_site_id is nil' do
      let(:webflow_site_id) { nil }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_id:, model_name:, id: article.id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_item_id is nil' do
      let(:mock_webflow_api) { instance_double(WebflowSync::Api, update_item: nil, create_item: nil) }

      before(:each) do
        article.update!(webflow_item_id: nil)
      end

      it 'calls CreateItemJob', vcr: { cassette_name: 'webflow/update_item_calls_create_item_job' } do
        allow(WebflowSync::CreateItemJob).to receive(:perform_later)

        WebflowSync::UpdateItemJob.perform_now(collection_id:, model_name:, id: article.id)
        perform_enqueued_jobs

        expect(WebflowSync::CreateItemJob).to have_received(:perform_later)
      end
    end

    context 'when slug name is passed' do
      let(:collection_slug) { 'stories' }
      let(:article) { create(:article, webflow_item_id: '65381893e6d401cdd3f3a363') }

      it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_sync_to_specified_collection' } do
        title = 'Updated article title'
        article.update!(title:)

        result = WebflowSync::UpdateItemJob.perform_now(collection_id:, model_name:, id: article.id)

        expect(result.dig(:fieldData, :name)).to eq(title)
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
