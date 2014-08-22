# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class nsca::server {
  include icinga # to set up the 'nagios' user for nsca
  include nsca

  @ufw::allow { 'allow-nsca-from-all':
    port => 5667,
  }

  file { '/etc/nsca.cfg':
    ensure    => file,
    source    => 'puppet:///modules/nsca/etc/nsca.cfg',
    subscribe => Class['nsca'],
  }
  service {'nsca':
    ensure    => running,
    hasstatus => false,
    subscribe => [
      File['/etc/nsca.cfg'],
      Class['nsca']
    ],
    # ugh. cross-module dependency alert.
    # we require Package['icinga'] because it creates the 'nagios'
    # user which the nsca process depends on. I don't want to depend
    # on Class['icinga'] because that feels a bit too restrictive - we
    # don't want to stop nsca starting before icinga has started.
    #
    # if you can imagine a better way of doing this, please do it! :)
    # -- ppotter 2013-02-07
    require   => Package['icinga'],
  }
}
