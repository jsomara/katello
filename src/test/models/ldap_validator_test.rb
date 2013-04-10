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

require 'minitest_helper'


class LdapValidatorTest < MiniTest::Rails::ActiveSupport::TestCase
    load_fixtures

    # TODO: RAILS32 remove top reference to load_fixtures
    if @loaded_fixtures.nil?
      @loaded_fixtures = load_fixtures
    end

  def self.before_suite
    services  = ['Candlepin',, 'ElasticSearch']
    models    = ['User', 'Organization', 'LdapGroupRole']
    disable_glue_layers(services, models)
  end

  def setup
    Katello.config[:warden] = 'ldap'
    Katello.config[:validate_ldap] = 'true'
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)
    @dev                = KTEnvironment.find(environments(:dev).id)
  end

  def test_valid_login
  end
end

