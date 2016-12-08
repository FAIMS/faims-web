class spatialite {
  require common

  $spatialite_packages = $::lsbdistcodename ? {
    xenial => ["sqlite3","libproj-dev","libgeos++-dev","libfreexl-dev","libspatialite-dev","libsqlite3-mod-spatialite"],
    default => ["sqlite3","libproj-dev","libgeos++-dev","libfreexl-dev","libspatialite-dev"]
  }

  package { $spatialite_packages:
    ensure  => "present"
  }

}
