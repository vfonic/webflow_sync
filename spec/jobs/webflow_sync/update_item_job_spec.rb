# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::UpdateItemJob, type: :job do
    let(:collection_slug) { 'articles' }
    let(:article) { create(:article, webflow_item_id: 'webflow_item_id') }
    let(:mock_webflow_api) { instance_double('mock_webflow_api', update_item: nil) }

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_slug, record_id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_site_id is nil' do
      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do
      article.update!(title: 'Updated article title')

      result = WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

      expect(result['name']).to eq 'Updated article title'
    end
  end
end
