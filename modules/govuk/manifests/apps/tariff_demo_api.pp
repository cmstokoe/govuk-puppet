class govuk::apps::tariff_demo_api($port = 3043) {
  govuk::app { 'tariff-demo-api':
    app_type          => 'rack',
    port              => $port,
    health_check_path => '/healthcheck',
  }
}
