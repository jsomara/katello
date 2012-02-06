#
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

class Api::TasksController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_task, :only => [:show]

  before_filter :authorize

  def rules
    # tasks are used in: synchronization, promotion, packages updating, organizatino deletion
    test = lambda do
      if @organization
        Provider.any_readable?(@organization) || @organization.systems_readable?
      else
        # at the end of organization deletion, there is no organization, so we
        # check if the user has the rights to see the task.
        User.current == @task.user
      end
    end
    { 
      :index => test,
      :show => test,
    }
  end

  def index
    render :json => TaskStatus.where(:organization_id => @organization).to_json(:except => :id)
  end

  def show
    render :json => @task.refresh.to_json(:except => :id)
  end

  private

  def find_task
    @task = TaskStatus.find_by_uuid(params[:id])
    @organization = @task.organization
  end
end
