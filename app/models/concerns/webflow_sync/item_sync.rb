# frozen_string_literal: true

# Synchronizes any changes to public records to Webflow
module WebflowSync
  module ItemSync
    extend ActiveSupport::Concern

    included do
      include WebflowSync::Callbacks

      # override this method to get more granular, per site customization
      def webflow_site_id
        WebflowSync.configuration.webflow_site_id
      end

      def as_webflow_json
        self.as_json
      end
    end
  end
end
