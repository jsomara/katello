require 'errata_processor'

namespace :katello do
  desc "Check for new errata on CDN and add them to the system if new"
  task :refresh_errata => [:environment] do
    Rails.logger.info("Refreshing errata")
    ErrataProcess.refresh
  end
end
