# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class collectd::plugin::tcpconns {
  @collectd::plugin { 'tcpconns':
    prefix  => '00-',
  }
}
