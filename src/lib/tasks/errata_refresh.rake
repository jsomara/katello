require 'errata_processor'

namespace :katello do
  desc "Check for new errata on CDN and add them to the system if new"
  task :refresh_errata => [:environment] do
    Rails.logger.info("Refreshing errata")
    e = ErrataProcessor.new(Katello.config.errata_cdn_url)
    e.refresh
  end
end
