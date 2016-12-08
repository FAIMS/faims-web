class imagemagick {
	require common

	
	if $::lsbdistcodename == 'trusty' {
		apt::ppa { 'ppa:mc3man/trusty-media':
		}

		exec { "update imagemagick sources":
			path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin",
			command => '/bin/true',
			unless => 'apt-get update',
			timeout => 600,
			require => Apt::Ppa['ppa:mc3man/trusty-media']
		}

		$imagemagick_packages = ["imagemagick","libmagickwand-dev","ffmpeg","libmagickcore5-extra","ghostscript","netpbm","autotrace","html2ps","ufraw-batch","dcraw","transfig","libbz2-1.0","curl"]

		package { $imagemagick_packages:
			ensure => "present",
			require => Exec["update imagemagick sources"]
		}

	} elsif $::lsbdistcodename == 'xenial' {
		$imagemagick_packages = ["imagemagick","libmagickwand-dev","ffmpeg","libmagickcore-6.q16-2-extra","ghostscript","netpbm","autotrace","html2ps","ufraw-batch","dcraw","transfig","libbz2-1.0","curl"]
		exec { "update imagemagick sources":
			path=> "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin",
			command => '/bin/true',
			unless=> 'apt-get update',
			timeout => 600
		}

		package { $imagemagick_packages:
			ensure => "present",
			require => Exec["update imagemagick sources"]
		}
	}
}
