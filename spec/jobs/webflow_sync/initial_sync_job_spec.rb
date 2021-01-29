# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::InitialSyncJob, type: :job do
    let(:webflow_mock_client) do
      instance_double('webflow_mock_client',
                      collections: [
                        {
                          'slug' => 'articles',
                          '_id' => 'mock_articles_id',
                        },
                      ],
                      create_item: {
                        '_id' => 'mock_item_id',
                      })
    end

    let!(:article) { create(:article) }

    before(:each) do
      allow(Webflow::Client).to receive(:new).and_return(webflow_mock_client)
    end

    xit 'assigns webflow item id to record' do
      WebflowSync::InitialSyncJob.perform_now(municipality.id)

      article.reload
      expect(article.webflow_item_id).to eq('mock_item_id')
    end

    xcontext 'when collection does not exist' do
      let(:webflow_mock_client) do
        instance_double('webflow_mock_client', collections: [])
      end

      it 'raises an error when it cannot find a webflow collection' do
        expect do
          WebflowSync::InitialSyncJob.perform_now(municipality.id)
        end.to raise_error('Cannot find collection articles for Webflow site ')
      end
    end
  end
end
