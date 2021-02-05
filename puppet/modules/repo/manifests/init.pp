class repo {
  require common

  $webapp_user = lookup("common::webapp_user")
  $app_root = lookup("common::app_root")
  $app_source = lookup("common::app_source")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  notify { 'webapp_user: $webapp_user, app_root: $app_root, app_source: $app_source': withpath => true}
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