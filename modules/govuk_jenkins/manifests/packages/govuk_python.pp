# == Class: govuk_jenkins::packages::govuk-python
#
# Installs Python in /usr/local/bin/
#
# === Parameters
#
# [*apt_mirror_hostname*]
#   The hostname of an APT mirror
#
# [*apt_mirror_gpg_key_fingerprint*]
#   The fingerprint of an APT mirror
#
class govuk_jenkins::packages::govuk_python (
  $govuk_python_version = '2.7.14',
  $govuk_python_setuptools_version = '39.0.1',
  $govuk_python_pip_version = '10.0.1',
  $apt_mirror_hostname,
  $apt_mirror_gpg_key_fingerprint,
){

  apt::source { 'govuk-python':
    location     => "http://${apt_mirror_hostname}/govuk-python",
    release      => 'stable',
    architecture => $::architecture,
    key          => $apt_mirror_gpg_key_fingerprint,
  }

  package { 'govuk-python':
    ensure  => $govuk_python_version,
    require => Apt::Source['govuk-python'],
  }

  package { 'govuk-python-setuptools':
    ensure  => $govuk_python_setuptools_version,
    require => Apt::Source['govuk-python'],
  }

  package { 'govuk-python-pip':
    ensure  => $govuk_python_pip_version,
    require => Apt::Source['govuk-python'],
  }

}
