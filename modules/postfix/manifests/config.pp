# == Class: postfix::config
#
# Manage the postfix servers configuration
#
# === Parameters
#
# [*smarthost*]
#   Hostname to relay all mail through. This will also trigger the rewriting
#   of local accounts to a centralised mailing list.
#
# [*smarthost_user*]
#   User to authenticate all relayed mail with.
#
# [*smarthost_pass*]
#   Pass to authenticate all relayed mail with.
#
# [*rewrite_mail_domain*]
#   Rewrite outbound mail so it appears to come from the given domain
#
# [*rewrite_mail_list*]
#   The mail user/list name to use in the rewrite rules
#
class postfix::config(
  $ensure = present,
  $smarthost,
  $smarthost_user,
  $smarthost_pass,
  $rewrite_mail_domain,
  $rewrite_mail_list
) {

  file { '/etc/mailname':
    ensure  => $ensure,
    content => "${::fqdn}\n",
  }

  file { '/etc/postfix/main.cf':
    ensure  => $ensure,
    content => template('postfix/etc/postfix/main.cf.erb'),
    notify  => Service[postfix],
    require => File['/etc/mailname'],
  }

  if $smarthost {

    postfix::postmapfile { 'outbound_rewrites':
      ensure  => $ensure,
      content => template('postfix/etc/postfix/outbound_rewrites.erb'),
    }
    postfix::postmapfile { 'local_remote_rewrites':
      ensure  => $ensure,
      content => template('postfix/etc/postfix/local_remote_rewrites.erb'),
    }

    if ($smarthost_user and $smarthost_pass) {
      postfix::postmapfile { 'sasl_passwd':
        ensure  => $ensure,
        content => template('postfix/etc/postfix/sasl_passwd.erb'),
      }
    }
  }

}
