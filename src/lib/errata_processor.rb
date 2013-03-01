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

  def initialize(url, last_modified=nil)
    @url = url
    @latest_errata = last_modified
  end

  def refresh
    errata = []
    if upstream_errata_new?(url, latest_errata)
      errata = load_errata(url)
    end
    return errata
  end

  def upstream_errata_new?(url, latest_errata)
    modified_date = get_modified_date_from_url(url)
    Rails.logger.info "Remote last modified #{modified_date}: local last modified : #{latest_errata}"
    return modified_date > latest_errata
  end

  def get_modified_date_from_url(url)
    uri = URI(url)
    http = Net::HTTP.start(uri.host, uri.port)
    modified_date_str = http.head(uri.path)['last-modified']
    return DateTime.parse(modified_date_str)
  end

  def load_errata(url)
    return parse_remote_payload(url)
    Rails.logger.info "Loaded #{errata.size} new errata"
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
