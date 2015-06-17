define add_nis_host_allow($hn = $title, $process) {
    augeas { "nis-hosts-allow-${process}-${hn}":
       context => "/files/etc/hosts.allow",
       changes => [
           "set 01/process ${process}",
           "set 01/client[.='${hn}'] ${hn}",
       ],
       onlyif => "match *[process='${process}'] size == 0"
    }
    augeas { "nis-hosts-allow-${process}-${hn}-client":
       context => "/files/etc/hosts.allow",
       changes => "set *[process='${process}']/client[.='${hn}'] ${hn}",
       require => Augeas["nis-hosts-allow-${process}-${hn}"],
    }
}

class nis::server (
      $ypdomain,
      $ypmaster,
      $master = true,
      $client = undef,
      $nicknames = undef,
      $securenets = undef,
      $hostallow = undef,
    ) {

    include nis::client
    include nis::params
    include rpcbind

    if ! defined(Package[$::nis::params::nis_srv_package]) {
      package { $::nis::params::nis_srv_package: ensure => latest }
    }

    if ($nicknames) {
        file { "/var/yp/nicknames":
            ensure  => file,
            owner   => "root",
            group   => "root",
            mode    => 0644,
            source  => $nicknames,
            require => Package[$::nis::params::nis_srv_package],
            notify  => Service[$::nis::params::nis_srv_service],
        }
    }

    if ($securenets) {
        file { "/var/yp/securenets":
            ensure  => file,
            owner   => "root",
            group   => "root",
            mode    => 0644,
            source  => $securenets,
            require => Package[$::nis::params::nis_srv_package],
            notify  => Service[$::nis::params::nis_srv_service],
        }
    }

    case $::osfamily {
      'Debian': {
        if ($master) {
          augeas{ 'default nis master':
            context => '/files/etc/default/nis',
            changes => [
              'set NISSERVER master',
            ],
            require => Package[$::nis::params::nis_srv_package],
          }
        } else {
          augeas{ 'default nis slave':
            context => '/files/etc/default/nis',
            changes => [
              'set NISSERVER slave',
            ],
            require => Package[$::nis::params::nis_srv_package],
          }
        }

        exec { 'yp-config':
          command => "domainname $ypdomain && ypinit -s $ypmaster",
          path    => [ '/bin', '/usr/bin', '/usr/lib64/yp', '/usr/lib/yp', '/usr/sbin' ],
          unless  => "test -d /var/yp/$ypdomain",
          require => Package[$::nis::params::nis_srv_package],
          notify  => Service[$::nis::params::nis_srv_service],
    }
      }
      'RedHat': {
        if ($hostallow) {
          add_nis_host_allow{$hostallow: process => "portmap"}
        }

        augeas{ "ypserv service" :
          context => "/files/etc/services",
          changes => [
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypserv",
              "set service-name[.='ypserv']/port 834",
              "set service-name[.='ypserv']/protocol tcp",
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypserv",
              "set service-name[.='ypserv'][2]/port 834",
              "set service-name[.='ypserv'][2]/protocol udp",
          ],
          onlyif => "match service-name[port='834'] size == 0",
          require => Package[$::nis::params::nis_srv_package],
        }

        augeas{ "ypxfrd service" :
          context => "/files/etc/services",
          changes => [
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypxfrd",
              "set service-name[.='ypxfrd']/port 835",
              "set service-name[.='ypxfrd']/protocol tcp",
              "ins service-name after /files/etc/services/service-name[last()]",
              "set service-name[last()] ypxfrd",
              "set service-name[.='ypxfrd'][2]/port 835",
              "set service-name[.='ypxfrd'][2]/protocol udp",
          ],
          onlyif => "match service-name[port='835'] size == 0",
          require => Package[$::nis::params::nis_srv_package],
        }

        augeas{ "nis server network" :
          context => "/files/etc/sysconfig/network",
          changes => [
              "set YPSERV_ARGS '\"-p 834\"'",
              "set YPXFRD_ARGS '\"-p 835\"'",
          ],
          require => Package[$::nis::params::nis_srv_package],
          notify  => Service[$::nis::params::nis_srv_service],
        }

    exec { 'yp-config':
        command => "domainname $ypdomain && ypinit -s $ypmaster && authconfig --enablenis --enablekrb5 --kickstart",
        path    => [ '/bin', '/usr/bin', '/usr/lib64/yp', '/usr/lib/yp', '/usr/sbin' ],
        unless  => "test -d /var/yp/$ypdomain",
        require => Package[$::nis::params::nis_srv_package],
        notify  => Service[$::nis::params::nis_srv_service],
    }
      }
    }

    augeas{ "nis server nicknames" :
        context => "/files/var/yp/nicknames",
        changes => [
            "set passwd/map passwd.byname",
            "set group/map group.byname",
            "set hosts/map hosts.byname",
            "set netgroup/map netgroup",
        ],
        require => Package[$::nis::params::nis_srv_package],
        notify  => Service[$::nis::params::nis_srv_service],
    }

    if ! defined(Service[$::nis::params::nis_srv_service]) {
      service { $::nis::params::nis_srv_service:
        ensure => running,
        enable => true,
        hasrestart => true,
        require => Package[$::nis::params::nis_srv_package],
      }
    }
}
