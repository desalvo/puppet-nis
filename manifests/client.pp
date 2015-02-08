class nis::client inherits nis {
    include nis::params
    service { $::nis::params::nis_service:
              ensure => running,
              enable => true,
              hasrestart => true,
              subscribe => [File["/etc/yp.conf"]],
              require => [File["/etc/yp.conf"],File["/etc/nsswitch.conf"]]
    }
}
