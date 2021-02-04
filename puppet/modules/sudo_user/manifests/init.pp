class sudo_user {
  require common

  $webapp_user = lookup("webapp_user")

  file { "/etc/sudoers.d/${$webapp_user}":
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template('sudo_user/user')
  }

}