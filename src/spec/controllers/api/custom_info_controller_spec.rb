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

require 'spec_helper.rb'
require 'helpers/system_test_data.rb'
include OrchestrationHelper
include SystemHelperMethods

describe Api::CustomInfoController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:facts) { {"distribution.name" => "Fedora"} }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})

    Resources::Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})

    @org = Organization.create!(:name => "test_org", :cp_key => "test_org")
    @env1 = KTEnvironment.create!(:name => "test_env", :prior => @org.library.id, :organization => @org)

    @system = System.create!(:name => "test_sys", :cp_type => "system", :environment => @env1.id, :facts => facts)
  end

  describe "attach to a aystem" do
    CustomInfo.should_receive(:create).with(hash_including(:informable_type => 'system', :informable_id => @system.id, :keyname => "test_key", :value => "test_value")).once.and_return()
    post :create, :informable_id => @system.id, :informable_type => "system", :keyname => "test_key", :value => "test_value"
    response.code.should == "200"
  end
end