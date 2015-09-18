class nis::params {
  case $::osfamily {
    'Debian': {
      $nis_package = 'nis'
      $nis_service = 'nis'
      $nis_srv_package = 'nis'
      $nis_srv_service = 'nis'
      $nis_pattern = '/usr/sbin/ypbind'
      $securenets_file  = '/etc/ypserv.securenets'
    }
    'RedHat': {
      $nis_package = 'ypbind'
      $nis_service = 'ypbind'
      $nis_srv_package = ['ypserv','ypbind','yp-tools']
      $nis_srv_service = 'ypserv'
      $nis_pattern = 'ypbind'
      $securenets_file  = '/var/yp/securenets'
    }
    default: {fail("NIS class does not work on osfamily: ${::osfamily}")}
  }
}
