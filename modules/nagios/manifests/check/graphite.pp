# == Define: nagios::check::graphite
#
# Wrapper for `nagios::check` that references `check_graphite` and creates
# an alert with the appropriate `graph_url` link containing warning and
# critical bands.
#
# It is deliberately quite simple and doesn't take many arguments, which
# will result in the defaults from `nagios::check`. It can be extended as
# necessary.
#
# === Parameters
#
# [*target*]
#   Graphite expression that will return a single metric. See:
#   http://graphite.readthedocs.org/en/1.0/url-api.html#target
#
# [*desc*]
#   Description of the Nagios alert. Will be passed to the `nagios::check`
#   param `service_description`.
#
# [*warning*]
#   Integer that will raise a warning alert.
#
# [*critical*]
#   Integer that will raise a critical alert.
#
# [*args*]
#   Single string of additional arguments passed to `check_graphite`. This
#   will trigger the use of `check_graphite_metric_args` instead of
#   `check_graphite_metric`.
#   Default: ''
#
#
define nagios::check::graphite(
  $target,
  $desc,
  $warning,
  $critical,
  $args = undef
) {
  $check_command = $args ? {
    undef   => 'check_graphite_metric',
    default => 'check_graphite_metric_args',
  }
  $args_real = $args ? {
    undef   => '',
    default => "!${args}",
  }

  $monitoring_domain_suffix = extlookup("monitoring_domain_suffix", "")
  $graph_width = 600
  $graph_height = 300

  nagios::check { $title:
    check_command       => "${check_command}!${target}!${warning}!${critical}${args_real}",
    service_description => $desc,
    graph_url           => "https://graphite.${monitoring_domain_suffix}/render/?\
width=${graph_width}&height=${graph_height}&\
target=${target}&\
target=alias(dashed(constantLine(${warning})),\"warning\")&\
target=alias(dashed(constantLine(${critical})),\"critical\")",
  }
}
