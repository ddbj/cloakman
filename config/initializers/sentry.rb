Sentry.init do |config|
  config.breadcrumbs_logger = [ :active_support_logger ]
  config.dsn                = Rails.application.config_for(:app).sentry_dsn
  config.enable_tracing     = true
end
