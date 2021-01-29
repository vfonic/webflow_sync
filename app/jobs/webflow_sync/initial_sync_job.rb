# frozen_string_literal: true

module WebflowSync
  class InitialSyncJob < ApplicationJob
    attr_reader :municipality

    def perform(municipality_id)
      @municipality = Municipality.find(municipality_id)
      webflow = WebflowApi.new(municipality.webflow_site_id)
      puts "Setting up Muni collections for #{municipality.title}"

      # RecordsType::ALL_TYPES.each do |collection_slug|
      collection_slug = RecordsType::RESOURCES
      model_class = RecordsType.to_model_class(collection_slug)
      model_class.where(webflow_item_id: nil, municipality_id: municipality.id).find_each do |record|
        webflow.create_item(record, collection_slug)
      end
      # end
    end
  end
end
