Rails.application.config.action_dispatch.rescue_responses.update(
  "LDAPError::NoSuchObject" => :not_found
)
