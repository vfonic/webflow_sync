# frozen_string_literal: true

require 'rails/generators/active_record'

module WebflowSync
  module Generators
    class ApiTokenFlowGenerator < Rails::Generators::Base
      desc 'Generates Omniauth flow for authenticating WebFlow application to get WebFlow API token'

      source_root File.expand_path('templates/api_token', __dir__)

      def generate
        gem 'omniauth-webflow'
        run 'bundle install'
        template 'webflow_callback_controller.rb', 'app/controllers/webflow_callback_controller.rb'
        template 'omniauth_webflow.rb', 'config/initializers/omniauth_webflow.rb'
        route "post '/auth/webflow/callback', to: 'webflow_callback#index'"
        route "get '/auth/webflow/callback', to: 'webflow_callback#index'"

        puts <<~END_OF_INSTRUCTIONS.indent(4)


          We've generated all the files needed to successfully authenticate
          with WebFlow to get API token.
          There are couple of steps left to get the token:

               1. Download ngrok: https://ngrok.com/download
               2. Run `ngrok http 3000`
               3. Copy the URL that ngrok gives you (something like: https://dd7cc807bf91.ngrok.io)
               4. Go to: https://webflow.com/dashboard/account/integrations
               5. Register New Application
               6. In "Redirect URI" put: https://dd7cc807bf91.ngrok.io/auth/webflow/callback
               7. Save
               8. Copy client ID and client secret to ENV variables or add
                  them directly in config/initializers/omniauth_webflow.rb
               9. Start rails server locally
              10. Go to https://dd7cc807bf91.ngrok.io/auth/webflow
              11. Finally authenticate, beware which permissions to give
                  (some are "allow access", some are "restrict access", it's confusing)
              12. Copy the rendered API token and put it in ENV.fetch('WEBFLOW_API_TOKEN')
              13. After you've got the API token, you probably don't need
                  the Omniauth WebFlow code so you can remove the code that this
                  generator created from your codebase.
                  It is also a security issue to leave the Omniauth endpoint in your
                  codebase, that has the ability to generate API tokens for your WebFlow
                  account!!!

          Easy.


        END_OF_INSTRUCTIONS
      end
    end
  end
end
