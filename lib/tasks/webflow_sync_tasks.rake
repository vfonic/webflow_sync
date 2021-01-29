# frozen_string_literal: true

namespace :webflow_sync do
  desc 'Perform initial sync from Rails to WebFlow'
  task :initial_sync, %i[collection_slug] => :environment do |_task, args|
    WebflowSync::InitialSyncJob.perform_later(args[:collection_slug])
  end
end
