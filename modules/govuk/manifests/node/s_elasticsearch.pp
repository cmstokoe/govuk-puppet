class govuk::node::s_elasticsearch inherits govuk::node::s_base {

  include java::oracle7::jre

  class { 'java::set_defaults':
    jdk => 'oracle7',
    jre => 'oracle7',
  }

  $es_heap_size = $::memtotalmb / 4 * 3

  class { 'elasticsearch':
    cluster_hosts        => ['elasticsearch-1.backend:9300', 'elasticsearch-2.backend:9300', 'elasticsearch-3.backend:9300'],
    cluster_name         => "govuk-${::govuk_platform}",
    heap_size            => "${es_heap_size}m",
    number_of_replicas   => '1',
    minimum_master_nodes => '2',
    host                 => $::fqdn,
    require              => Class['java::oracle7::jre'],
  }

  elasticsearch::plugin { 'head':
    install_from => 'mobz/elasticsearch-head',
  }

  rsyslog::snippet { '300-open_udp_port':
    content => template('govuk/etc/rsyslog.d/open_udp_port.conf.erb')
  }
}
