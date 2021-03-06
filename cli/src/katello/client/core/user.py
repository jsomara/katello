#
# Katello User actions
# Copyright (c) 2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import os
import sys
from gettext import gettext as _

from katello.client.api.user import UserAPI
from katello.client.api.user_role import UserRoleAPI
from katello.client.api.utils import get_user
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, convert_to_mime_type, attachment_file_name, save_report

Config()

# base user action -----------------------------------------------------

class UserAction(Action):

    def __init__(self):
        super(UserAction, self).__init__()
        self.api = UserAPI()


# user actions ---------------------------------------------------------

class List(UserAction):

    description = _('list all known users')

    def run(self):
        users = self.api.users()

        self.printer.addColumn('id')
        self.printer.addColumn('username')
        self.printer.addColumn('email')
        self.printer.addColumn('disabled')

        self.printer.setHeader(_("User List"))
        self.printer.printItems(users)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(UserAction):

    description = _('create user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))
        self.parser.add_option('--password', dest='password', help=_("initial password (required)"))
        self.parser.add_option('--email', dest='email', help=_("email (required)"))
        self.parser.add_option("--disabled", dest="disabled", type="bool", help=_("disabled account (default is 'false')"), default=False)

    def check_options(self):
        self.require_option('username')
        self.require_option('password')
        self.require_option('email')

    def run(self):
        username = self.get_option('username')
        password = self.get_option('password')
        email = self.get_option('email')
        disabled = self.get_option('disabled')

        user = self.api.create(username, password, email, disabled)
        if is_valid_record(user):
            print _("Successfully created user [ %s ]") % user['username']
        else:
            print >> sys.stderr, _("Could not create user [ %s ]") % user['username']
        return os.EX_OK

# ------------------------------------------------------------------------------

class Info(UserAction):

    description = _('list information about user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')

        user = get_user(username)
        if user == None:
            return os.EX_DATAERR

        self.printer.addColumn('id')
        self.printer.addColumn('username')
        self.printer.addColumn('email')
        self.printer.addColumn('disabled')

        self.printer.setHeader(_("User Information"))
        self.printer.printItem(user)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(UserAction):

    description = _('delete user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')

        user = get_user(username)
        if user == None:
            return os.EX_DATAERR

        self.api.delete(user['id'])
        print _("Successfully deleted user [ %s ]") % username
        return os.EX_OK

# ------------------------------------------------------------------------------

class Update(UserAction):

    description = _('update an user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))
        self.parser.add_option('--password', dest='password', help=_("initial password"))
        self.parser.add_option('--email', dest='email', help=_("email"))
        self.parser.add_option("--disabled", dest="disabled", help=_("disabled account (default is 'false')"), default=False)

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')
        password = self.get_option('password')
        email = self.get_option('email')
        disabled = self.get_option('disabled')

        user = get_user(username)
        if user == None:
            return os.EX_DATAERR

        if password == None and email == None and disabled == None:
            print _("Provide at least one parameter to update user [ %s ]") % username
            return os.EX_DATAERR

        user = self.api.update(user['id'], password, email, disabled)
        print _("Successfully updated user [ %s ]") % username
        return os.EX_OK

# ------------------------------------------------------------------------------

class ListRoles(UserAction):

    description = _("list user's roles")

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')

        user = get_user(username)
        if user == None:
            return os.EX_DATAERR

        roles = self.api.roles(user['id'])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.setHeader(_("User Role List"))
        self.printer.printItems(roles)
        return os.EX_OK


class AssignRole(UserAction):

    @property
    def description(self):
        if self.__assign:
            return _('assign role to a user')
        else:
            return _('unassign role to a user')

    def assign(self):
        return self.__assign

    def __init__(self, assign = True):
        super(AssignRole, self).__init__()
        self.role_api = UserRoleAPI()

        self.__assign = assign

    def setup_parser(self):
        self.parser.add_option('--username', dest='username', help=_("user name (required)"))
        self.parser.add_option('--role', dest='role', help=_("user role (required)"))

    def check_options(self):
        self.require_option('username')
        self.require_option('role')

    def run(self):
        userName = self.get_option('username')
        roleName = self.get_option('role')

        user = get_user(userName)
        if user == None:
            return os.EX_DATAERR

        role = self.role_api.role_by_name(roleName)
        if role == None:
            print _("Role [ %s ] not found" % roleName)
            return os.EX_DATAERR

        msg = self.update_role(user['id'], role['id'])
        print msg
        return os.EX_OK

    def update_role(self, userId, roleId):
        if self.assign():
            return self.api.assign_role(userId, roleId)
        else:
            return self.api.unassign_role(userId, roleId)


class Report(UserAction):

    description = _('user report')

    def setup_parser(self):
        self.parser.add_option('--format', dest='format', help=_("report format (possible values: 'html', 'text' (default), 'csv', 'pdf')"))

    def run(self):
        format = self.get_option('format')
        report = self.api.report(convert_to_mime_type(format, 'text'))

        if format == 'pdf':
            save_report(report[0], attachment_file_name(report[1], 'katello_users_report.pdf'))
        else:
            print report[0]

        return os.EX_OK


# user command ------------------------------------------------------------

class User(Command):

    description = _('user specific actions in the katello server')
