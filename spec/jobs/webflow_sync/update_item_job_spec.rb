# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::UpdateItemJob, type: :job do
    let(:collection_slug) { RecordsType::RESOURCES }
    let(:municipality) { create(:municipality, webflow_site_id: 'webflow_site_id') }
    let(:resource) { create(:resource, municipality: municipality, webflow_item_id: 'webflow_item_id') }

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do
      resource.update!(title: 'Updated Resource title')

      result = WebflowSync::UpdateItemJob.perform_now(collection_slug, resource.id)

      expect(result['name']).to eq 'Updated Resource title'
    end
  end
end
