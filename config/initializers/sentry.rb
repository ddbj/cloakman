Sentry.init do |config|
  config.breadcrumbs_logger = [ :active_support_logger ]
  config.dsn                = ENV["SENTRY_DSN"]
  config.enable_tracing     = true
end
