# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class loadbalancer {

  include nginx

  # Install a default vhost returning 200 OK for the purposes of the
  # downstream vShield Edge load balancer healthchecks
  nginx::config::vhost::default { 'default':
    status         => '200',
    status_message => '',
  }

}
