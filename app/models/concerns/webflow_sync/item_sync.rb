# frozen_string_literal: true

# Synchronizes any changes to public records to Webflow
module WebflowSync
  module ItemSync
    extend ActiveSupport::Concern

    included do
      include WebflowSync::Callbacks

      # override this method to get more granular, per site customization
      # for example, you could have Site model in your codebase:
      #
      # class Site < ApplicationRecord
      #   has_many :articles
      # end
      #
      # class Article < ApplicationRecord
      #   belongs_to :site
      #
      #   def webflow_site_id
      #     self.site.webflow_site_id
      #   end
      # end
      #
      def webflow_site_id = WebflowSync.configuration.webflow_site_id

      # override this method in your model to match the collection slug in Webflow
      def webflow_collection_slug = self.model_name.collection.underscore.dasherize

      # override this method in your model to match the collection id in Webflow
      # overriding this method is optional, but it will save you a Webflow API call!
      def webflow_collection_id
        @webflow_collection_id ||= WebflowSync::Api.new(site_id: self.webflow_site_id)
                                                   .find_collection_id(collection_slug: self.webflow_collection_slug)
      end

      # You can customize this to your liking:
      # def as_webflow_json
      #   {
      #     title: self.title.capitalize,
      #     slug: self.title.parameterize,
      #     published_at: self.created_at,
      #     image: self.image_url
      #   }
      # end
      def as_webflow_json = self.as_json
    end
  end
end
