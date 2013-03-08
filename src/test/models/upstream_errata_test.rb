# encoding: utf-8
#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require './test/models/upstream_errata_base'


class UpstreamErrataClassTest < UpstreamErrataTestBase

  def test_latest_errata_missing
    assert UpstreamErrata.latest_errata == Date.parse("1 Feb 1970")
  end

  def test_latest_errata_present
    u = UpstreamErrata.new
    u.errata_id = "rhsa_1234"
    u.updated = Date.parse("3 March 2007")
    u.save

    p = UpstreamErrata.new
    p.errata_id = "rhsa_1235"
    p.updated = Date.parse("2 March 2007")
    p.save

    assert UpstreamErrata.latest_errata == Date.parse("3 March 2007")
  end

  def test_needs_new_errata
    u = UpstreamErrata.new
    u.errata_id = "rhsa_1234"
    u.updated = Date.parse("3 March 2007")
    u.save

    assert u.old_erratum.updated == Date.parse("3 March 2007")
  end

  def test_updated
    u = UpstreamErrata.new
    u.errata_id = "rhsa_1234"
    u.description = "old"
    u.updated = Date.parse("3 March 2007")
    u.save

    p = UpstreamErrata.new
    p.errata_id = "rhsa_1234"
    p.description = "new"
    p.updated = Date.parse("4 March 2007")

    p.update_or_save

    assert UpstreamErrata.latest_errata == Date.parse("4 March 2007")
    requery_old = UpstreamErrata.where("errata_id = 'rhsa_1234'").first
    assert p.description == requery_old.description
  end

  def test_old_errata
    u = UpstreamErrata.new
    u.errata_id = "rhsa_1234"
    u.description = "old"
    u.updated = Date.parse("3 March 2007")
    u.save

    p = UpstreamErrata.new
    p.errata_id = "rhsa_1234"
    assert p.old_erratum.description == 'old'
  end
end
