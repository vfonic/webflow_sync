# frozen_string_literal: true

module WebflowSync
  class UpdateItemJob < ApplicationJob
    # WebFlow collection slug should be in plural form.
    # For collections that have spaces in their name, WebFlow sets slug by replacing space for "-".
    # 'JobListing'.underscore.dasherize.pluralize => 'job-listings'
    # 'job_listing'.underscore.dasherize.pluralize => 'job-listings'
    def perform(model_name, id, collection_slug = nil)
      model_class = model_name.underscore.classify.constantize
      record = model_class.find_by(id:)
      return if record.blank?
      return if record.webflow_site_id.blank?
      collection_slug ||= record.try(:collection_slug) || model_name.underscore.dasherize.pluralize

      return WebflowSync::CreateItemJob.perform_now(model_name, id, collection_slug) if record.webflow_item_id.blank?

      WebflowSync::Api.new(record.webflow_site_id).update_item(record, collection_slug)
    end
  end
end
