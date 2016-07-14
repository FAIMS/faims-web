class apache {
  require common

  $apache_packages = $::lsbdistcodename ? {
		trusty => ["apache2","apache2-threaded-dev","libcurl4-openssl-dev","libapr1-dev","libaprutil1-dev"],
		xenial => ["apache2","apache2-dev","libcurl4-openssl-dev","libapr1-dev","libaprutil1-dev"],
		default => ["apache2","apache2-threaded-dev","libcurl4-openssl-dev","libapr1-dev","libaprutil1-dev"]
	}
  package { $apache_packages:
    ensure  => "present"
  }

}
