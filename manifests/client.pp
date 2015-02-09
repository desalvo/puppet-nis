class nis::client inherits nis {
  include nis::params

  if $::osfamily == 'Debian' {
    service { $::nis::params::nis_service:
              ensure     => running,
              enable     => true,
              hasrestart => true,
              hasstatus  => false,
              pattern    => $::nis::params::nis_pattern,
              subscribe  => [File["/etc/yp.conf"]],
              require    => [File["/etc/yp.conf"],File["/etc/nsswitch.conf"]]
    }
  } else {
    service { $::nis::params::nis_service:
              ensure     => running,
              enable     => true,
              hasrestart => true,
              subscribe  => [File["/etc/yp.conf"]],
              require    => [File["/etc/yp.conf"],File["/etc/nsswitch.conf"]]
    }
  }
}
