class repo {
  require common

  $webapp_user = lookup("common::webapp_user")
  $app_root = lookup("common::app_root")
  $app_source = lookup("common::app_source")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  
  
  vcsrepo { $app_root:
    ensure   => latest,
    provider => git,
    source   => $app_source,
    user     => $webapp_user,
  }

  exec { "sed -i \"s/webapp_user:.*/webapp_user: ${webapp_user}/g\" ${$app_root}/puppet/data/common.yaml":
    path    => $exec_path,
    require => Vcsrepo[$app_root]
  }
}