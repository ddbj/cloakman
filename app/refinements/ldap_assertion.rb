module LDAPAssertion
  refine TrueClass do
    def assert
      # nop
    end
  end

  refine FalseClass do
    def assert
      raise LDAPError.from_result(LDAP.connection.get_operation_result)
    end
  end
end
