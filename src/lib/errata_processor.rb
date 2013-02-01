# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'xz'
require 'open-uri'
require 'net-http'

class ErrataProcessor

  def initialize
    if !AppConfig.use_pulp?
      @url = AppConfig.errata_url
      @latest_errata = UpstreamErrata.last_installed_date
    end
  end

  # general process for errata processing
  # 1. HEAD errata file from upstream; check date
  # 2. if date < today, end
  # 3. else download file, parse errata until "stale" errata
  #    received
  #
  # this should run by default every few hours
  def refresh
    if !AppConfig.use_pulp?
      process_errata(@url, @latest_errata)
    end
  end

  def process_errata(url, latest_errata)
    process_new_errata(url) if upstream_errata_new?(url, latest_errata)
  end

  # determine if the upstream errata is fresh
  def upstream_errata_new?(url, latest_errata)
    Rails.logger.info "Checking remote server for new errata"
    uri = URI(url)
    http = Net::HTTP.start(uri.host, uri.port)
    modified_date_str = http.head(uri.path)['last-modified']
    modified_date = DateTime.parse(modified_date_str)
    Rails.logger.info "Remote server last modified #{modified_date}"
    Rails.logger.info "Last errata update from #{latest_errata}"
    return modified_date > latest_errata
  end

  def process_new_errata(url)
    Rails.logger.info "Processing new upstream errata...."
    errata = parse_remote_payload(url)
    errata.each do |e|
      upstream_errata = UpstreamErrata.from_json(e)
      # TODO only save if new errata
      upstream_errata.save
    end
    Rails.logger.info "Added #{errata.size} new errata"
  end

  # load remote stream xz file, decompress stream with XZ library
  # no advantage can be had from chunking the file from XZ as JSON
  # parsing will not succeed until the entire file is in memory
  #
  # this can be changed to download first & process local file stream
  def parse_remote_payload(url)
    open(url) do |f|
      JSON.load(XZ.decompress_stream(f))
    end
  end
end
