# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::InitialSyncJob, type: :job do
    let(:webflow_mock_client) do
      instance_double('webflow_mock_client',
                      collections: [
                        {
                          'slug' => 'resources',
                          '_id' => 'mock_resources_id',
                        },
                      ],
                      create_item: {
                        '_id' => 'mock_item_id',
                      })
    end

    let!(:municipality) { create(:municipality) }
    let!(:resource) { create(:resource, { municipality_id: municipality.id }) }

    before(:each) do
      allow(Webflow::Client).to receive(:new).and_return(webflow_mock_client)
    end

    it 'assigns webflow item id to record' do
      WebflowSync::InitialSyncJob.perform_now(municipality.id)

      resource.reload
      expect(resource.webflow_item_id).to eq('mock_item_id')
    end

    context 'when collection does not exist' do
      let(:webflow_mock_client) do
        instance_double('webflow_mock_client', collections: [])
      end

      it 'raises an error when it cannot find a webflow collection' do
        expect do
          WebflowSync::InitialSyncJob.perform_now(municipality.id)
        end.to raise_error('Cannot find collection resources for Webflow site ')
      end
    end
  end
end
