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

require 'open-uri'
require 'net/http'

class ErrataProcessor

  def initialize(url, last_modified=nil)
    @url = url
    @latest_errata = last_modified
  end

  def refresh
    if !Katello.config.use_pulp
      @latest_errata ||= UpstreamErrata.latest_errata
      errata = load_data_from_upstream(@url, @latest_errata)
      if !errata.empty?
        errata.each do |e|
          new_errata = UpstreamErrata.from_json(e)
          new_errata.update_or_save
        end
      end
    end
  end

  def load_data_from_upstream(url, latest_errata)
    errata = []
    if upstream_errata_new?(url, latest_errata)
      errata = load_errata(url)
    end
    return errata
  end

  def upstream_errata_new?(url, latest_errata)
  end

  def load_errata(url)
    return parse_remote_payload(url)
  end

  # load remote stream xz file, decompress stream with XZ library
  # no advantage can be had from chunking the file from XZ as JSON
  # parsing will not succeed until the entire file is in memory
  #
  # this can be changed to download first & process local file stream
  def parse_remote_payload(url)
  end
end
