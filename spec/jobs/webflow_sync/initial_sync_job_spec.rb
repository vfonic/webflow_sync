# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::InitialSyncJob do
    let(:webflow_mock_client) do
      instance_double(Webflow::Client, collections: [{ slug: 'articles', id: 'mock_articles_id' }], create_item: { id: 'mock_item_id' })
    end

    before(:each) do
      allow(::Webflow::Client).to receive(:new).and_return(webflow_mock_client)
    end

    it 'assigns webflow_item_id to record' do
      article = create(:article)

      WebflowSync::InitialSyncJob.perform_now('articles')

      expect(article.reload.webflow_item_id).to eq('mock_item_id')
    end

    context 'when collection does not exist' do
      let(:webflow_mock_client) do
        instance_double(Webflow::Client, collections: [])
      end

      it 'raises an error when it cannot find a webflow collection' do
        create(:article)
        error_message = "Cannot find collection articles for Webflow site #{ENV.fetch('WEBFLOW_SITE_ID')}"

        expect do
          WebflowSync::InitialSyncJob.perform_now('articles')
        end.to raise_error(error_message)
      end
    end
  end
end
