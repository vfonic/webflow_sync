# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::UpdateItemJob, type: :job do
    let(:collection_slug) { 'articles' }
    let(:article) { create(:article, webflow_item_id: '60defde681813e53c6be97ea') }
    let(:mock_webflow_api) { instance_double('mock_webflow_api', update_item: nil) }

    before(:each) do
      WebflowSync.configure do |config|
        config.webflow_site_id = 'webflow_site_id'
        config.api_token = 'webflow_api_token'
      end
    end

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do
      article.update!(title: 'Updated article title')

      result = WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

      expect(result['name']).to eq 'Updated article title'
    end

    context 'when record does not exist' do
      let(:record_id) { 1_234_567 }

      it 'does not sync' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_slug, record_id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_site_id is nil' do
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

        WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

        expect(mock_webflow_api).not_to have_received(:update_item)
      end
    end

    context 'when webflow_item_id is nil' do
      let(:mock_webflow_api) do
        instance_double('mock_webflow_api', update_item: nil, create_item: nil)
      end

      before(:each) do
        article.update!(webflow_item_id: nil)
      end

      it 'calls CreateItemJob' do
        allow(WebflowSync::Api).to receive(:new).and_return(mock_webflow_api)

        WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

        expect(mock_webflow_api).to have_received(:create_item)
      end
    end
  end
end
