Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]
  config.traces_sample_rate = 0.2
  config.send_default_pii = true
end
