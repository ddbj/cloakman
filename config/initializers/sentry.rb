Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn                = Rails.application.credentials.sentry_dsn

  if Rails.env.production?
    config.enabled_patches << :solid_queue_recurring

    config.cron.default_checkin_margin = 10
    config.cron.default_max_runtime    = 180

    # The Sentry plan includes a single cron monitor.
    config.rails.solid_queue_exclude_recurring_tasks = [/\A(?!import_datasets\z)/]
  end
end
