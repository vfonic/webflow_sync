# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::DestroyItemJob, type: :job do
    let(:article) { create(:article) }

    it 'destroys item on Webflow', vcr: { cassette_name: 'webflow/delete_item' } do
      result = WebflowSync::DestroyItemJob.perform_now(collection_slug: 'articles',
                                                       webflow_site_id: 'webflow_site_id',
                                                       webflow_item_id: 'webflow_item_id')
      expect(result).to eq({ 'deleted' => 1 })
    end
  end
end
