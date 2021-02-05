class cleanup {
  require webapp

  $app_root = lookup("common::app_root")
  file { "${app_root}/.faims_has_updates":
    ensure  => absent
  }

}