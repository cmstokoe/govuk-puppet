# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class jenkins::master inherits jenkins {

  $app_domain = hiera('app_domain')

  apt::source { 'jenkins':
    location     => 'http://apt.production.alphagov.co.uk/jenkins',
    release      => 'binary',
    architecture => $::architecture,
    key          => '37E3ACBB',
  }

  package { 'jenkins':
    ensure  => '1.554.2',
    require => Class['jenkins'],
  }

  file { '/etc/default/jenkins':
    ensure  => file,
    source  => 'puppet:///modules/jenkins/etc/default/jenkins',
    require => Package['jenkins'],
  }

  service { 'jenkins':
    ensure    => 'running',
    subscribe => File['/etc/default/jenkins'],
  }

  package { 'keychain':
    ensure => 'installed'
  }

  file { '/home/jenkins/.bashrc':
    source  => 'puppet:///modules/jenkins/dot-bashrc',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0700',
    require => Package['keychain'],
  }

  file { '/var/govuk-archive':
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    require => User['jenkins'],
  }
}
