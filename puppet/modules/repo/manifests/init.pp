class repo {
  require common

  $webapp_user = lookup("webapp_user")
  $app_root = lookup("app_root")
  $app_source = lookup("app_source")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

  if $app_tag {
    vcsrepo { $app_root:
      ensure   => latest,
      provider => git,
      source   => $app_source,
      revision => $app_tag,
      user     => $webapp_user,
    }
  } else {
    vcsrepo { $app_root:
      ensure   => latest,
      provider => git,
      source   => $app_source,
      revision => hiera("app_tag"),
      user     => $webapp_user,
    }
  }

  exec { "sed -i \"s/webapp_user:.*/webapp_user: ${webapp_user}/g\" ${$app_root}/puppet/data/common.yaml":
    path    => $exec_path,
    require => Vcsrepo[$app_root]
  }
}