module LDAPAssertion
  refine Net::LDAP do
    def assert_call(...)
      case ret = public_send(...)
      when true, Array
        ret
      when false, nil
        raise LDAPError.from_result(get_operation_result)
      else
        raise "must not happen"
      end
    end
  end
end
