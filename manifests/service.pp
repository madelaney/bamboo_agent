# set up the service
# @param username username of the bamboo-agent service account
# @param home home directory of the bamboo-agent user
define bamboo_agent::service(
  $username,
  $home,
  ){

  assert_private()

  case $::service_provider {
    'systemd' : {
      $init_path     = '/lib/systemd/system'
      $init_template = 'bamboo-agent/unit.erb'
    }
    default: {
      $init_path = '/etc/init.d'
      $service_template = 'bamboo_agent/init.sh.erb'
    }
  }

  $initscript = "${init_path}/${username}"

  file {$initscript:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template($service_template)
  }

  service { $username:
    ensure  => running,
    enable  => true,
    require => File[$initscript]
  }
}
