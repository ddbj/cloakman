# Where to send somebody once they are done here.
#
# Cloakman is the account service for several applications, and the one
# that sent somebody here rarely wants them left on Cloakman's own front
# page afterwards. The case this was built for is an invitation to a
# DDBJ Repository group: the person holding it cannot walk through it
# without an account, and making them go back to the mail to find the
# link again is a step that reads as a mistake.
#
# The referring application names the address; Cloakman decides whether
# it is one of ours. An address that is not is IGNORED rather than
# refused — a link that cannot be followed back is still a link that
# creates the account, and refusing would strand somebody mid-signup
# over a configuration mistake they cannot see or fix.
module ReturnTo
  extend ActiveSupport::Concern

  included do
    helper_method :return_to
  end

  private

  def return_to
    return @return_to if defined?(@return_to)

    @return_to = allowed_return_to(params[:return_to])
  end

  # Origins, not string prefixes. A prefix match is fooled by a host that
  # merely starts the same way — `accounts.ddbj.nig.ac.jp.example.com`
  # begins with `accounts.ddbj.nig.ac.jp` — and comparing parsed origins
  # cannot be.
  def allowed_return_to(raw)
    return nil if raw.blank?

    origin = origin_of(raw) or return nil

    allowed = Array(Rails.application.config_for(:app).return_to_allowed_origins)

    allowed.filter_map { origin_of(it) }.include?(origin) ? raw.to_s : nil
  end

  def origin_of(value)
    uri = URI.parse(value.to_s)

    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?

    # `http://accounts.ddbj.nig.ac.jp@evil.example.com/` parses with host
    # `evil.example.com`, so the origin comparison already refuses it —
    # but a form of address whose whole purpose is to be misread has no
    # business in a redirect we vouch for, and the browser would show it
    # in the bar on the way past.
    return nil if uri.userinfo.present?

    port = ":#{uri.port}" unless uri.port == uri.default_port

    "#{uri.scheme}://#{uri.host.downcase}#{port}"

    # URI::InvalidURIError is one of several siblings under URI::Error;
    # the intent is "anything that is not a URL is not one of ours".
  rescue URI::Error
    nil
  end
end
