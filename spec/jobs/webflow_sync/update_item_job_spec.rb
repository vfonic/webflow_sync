# frozen_string_literal: true

require 'rails_helper'

module WebflowSync
  RSpec.describe WebflowSync::UpdateItemJob, type: :job do
    let(:collection_slug) { 'articles' }
    let(:article) { create(:article, webflow_item_id: 'webflow_item_id') }

    it 'updates item on Webflow', vcr: { cassette_name: 'webflow/update_item' } do
      article.update!(title: 'Updated article title')

      result = WebflowSync::UpdateItemJob.perform_now(collection_slug, article.id)

      expect(result['name']).to eq 'Updated article title'
    end
  end
end
