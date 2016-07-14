class webapp_services {

  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

  exec { "/etc/init.d/god stop":
    path => $exec_path,
  }

  exec { "service apache2 stop":
    path => $exec_path,
  }

  service { "god":
    ensure     => "running",
    enable     => "true",
    hasrestart => "true",
    require    => Exec["/etc/init.d/god stop"]
  }

  service { "apache2":
    ensure     => "running",
    enable     => "true",
    hasrestart => "true",
    require    => Exec["service apache2 stop"]
  }

}
