class nis::params {
  case $::osfamily {
    'Debian': {
      $nis_package = 'nis'
      $nis_service = 'nis'
      $nis_pattern = '/usr/sbin/ypbind'
    }
    'RedHat': {
      $nis_package = 'ypbind'
      $nis_service = 'ypbind'
    }
    default: {fail("NIS class does not work on osfamily: ${::osfamily}")}
    }
}
