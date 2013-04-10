module Validators
  class LdapGroupValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value && Katello.config.validate_ldap?
        record.errors[attribute] << N_("does not exist in your current LDAP system. Please choose a different group, or contact your LDAP administrator to have this group created") if !Ldap.valid_group?(value)
      end
    end
  end

  class LdapUserValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value && Katello.config.validate_ldap?
        record.errors[attribute] << N_("does not exist in your current LDAP system. Please choose a different user, or contact your LDAP administrator if you think this message is in error.") if !Ldap.valid_user?(value)
      end
    end
  end


