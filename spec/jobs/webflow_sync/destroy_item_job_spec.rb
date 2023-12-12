# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::DestroyItemJob do
    let(:article) { create(:article) }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, delete_item: nil, find_collection_id: nil) }
    let(:collection_slug) { 'articles' }
    let(:collection_id) { WebflowSync::Api.new(site_id: webflow_site_id).find_collection_id(collection_slug:) }
    let(:webflow_site_id) { WebflowSync.configuration.webflow_site_id }

    before(:each) do
      @old_sync_webflow_slug = WebflowSync.configuration.sync_webflow_slug
      @old_webflow_site_id = WebflowSync.configuration.webflow_site_id

      WebflowSync.configure do |config|
        config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
        config.skip_webflow_sync = false
      end
    end

    after(:each) do
      WebflowSync.configure do |config|
        config.webflow_site_id = @old_webflow_site_id
        config.skip_webflow_sync = @old_skip_webflow_sync
      end
    end

    context 'when webflow_item_id is nil' do
      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::DestroyItemJob.perform_now(collection_id:, webflow_site_id:, webflow_item_id: nil)

        expect(mock_webflow_api).not_to have_received(:delete_item)
      end
    end

    context 'when webflow_site_id is nil' do
      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::DestroyItemJob.perform_now(collection_id:, webflow_site_id: nil, webflow_item_id: 'webflow_item_id')

        expect(mock_webflow_api).not_to have_received(:delete_item)
      end
    end

    context 'when webflow_site_id is set' do
      it 'destroys item on Webflow', vcr: { cassette_name: 'webflow/delete_item' } do
        webflow_item_id = '65783b4e8708079b31dfa7b7'

        WebflowSync::DestroyItemJob.perform_now(collection_id:, webflow_site_id:, webflow_item_id:)

        expect do
          WebflowSync::Api.new(site_id: webflow_site_id).get_item(collection_id:, webflow_item_id:)
        end.to raise_error(Webflow::Error, 'Requested resource not found')
      end

      context 'when item with webflow_item_id does not exist on Webflow' do
        it 'raises Webflow::Error', vcr: { cassette_name: 'webflow/delete_item_not_found' } do
          webflow_item_id = 'does_not_exist_on_webflow'

          expect do
            WebflowSync::DestroyItemJob.perform_now(collection_id:, webflow_site_id:, webflow_item_id:)
          end.to raise_error(Webflow::Error, 'Validation Error: Provided ID is invalid')
        end
      end
    end
  end
end
