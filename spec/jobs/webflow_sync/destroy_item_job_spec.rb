# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::DestroyItemJob do
    let(:article) { create(:article) }
    let(:mock_webflow_api) { instance_double(WebflowSync::Api, delete_item: nil) }
    let(:webflow_site_id) { ENV.fetch('WEBFLOW_SITE_ID') }

    context 'when webflow_item_id is nil' do
      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::DestroyItemJob.perform_now(collection_slug: 'articles',
                                                webflow_site_id:,
                                                webflow_item_id: nil)

        expect(mock_webflow_api).not_to have_received(:delete_item)
      end
    end

    context 'when webflow_site_id is nil' do
      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::DestroyItemJob.perform_now(collection_slug: 'articles',
                                                webflow_site_id: nil,
                                                webflow_item_id: 'webflow_item_id')

        expect(mock_webflow_api).not_to have_received(:delete_item)
      end
    end

    context 'when webflow_site_id is set' do
      it 'destroys item on Webflow and publish all domains', vcr: { cassette_name: 'webflow/delete_item' } do
        result = WebflowSync::DestroyItemJob.perform_now(collection_slug: 'articles',
                                                         webflow_site_id:,
                                                         webflow_item_id: '60defde69683113ebb79e864')
        expect(result).to eq({ 'deleted' => 1 })
      end
    end
  end
end
