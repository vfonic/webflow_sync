# frozen_string_literal: true

module WebflowSync
  class CreateItemJob < ApplicationJob
    # WebFlow collection slug should be in plural form.
    # For collections that have spaces in their name, WebFlow sets slug by replacing space for "-".
    # 'JobListing'.underscore.dasherize.pluralize => "job-listings"
    # 'job_listing'.underscore.dasherize.pluralize => "job-listings"
    # We can sync Rails model that has different class name than its WebFlow collection
    # model_name => Rails model that has webflow_site_id and webflow_item_id columns
    # collection_slug => slug of the WebFlow collection
    # model_name = 'articles'; id = article.id, collection_slug = 'stories'
    def perform(model_name, id, collection_slug = model_name.underscore.dasherize.pluralize)
      model_class = model_name.underscore.classify.constantize
      record = model_class.find_by(id:)
      return if record.blank?
      return if record.webflow_site_id.blank?

      WebflowSync::Api.new(record.webflow_site_id).create_item(record, collection_slug)
    end
  end
end
