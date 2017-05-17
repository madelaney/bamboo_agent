# set up the service
# @param username username of the bamboo-agent service account
# @param home home directory of the bamboo-agent user
define bamboo_agent::service (
  String           $username,
  String           $home,
  String           $service_name = $title,
  Optional[String] $java_home = undef,
) {

  assert_private()

  case $::operatingsystem {
    'Ubuntu': {
      case $::lsbdistcodename {
        'xenial': {
          $init_path        = '/lib/systemd/system'
          $service_template = 'bamboo_agent/unit.erb'
          $initscript       = "${init_path}/${service_name}.service"
        }
        default: {
          $init_path        = '/etc/init.d'
          $service_template = 'bamboo_agent/init.sh.erb'
          $initscript       = "${init_path}/${service_name}"
        }
      }
    }
    'Redhat','CentOS': {
      case $::operatingsystemmajrelease {
        '7': {
          $init_path        = '/lib/systemd/system'
          $service_template = 'bamboo_agent/unit.erb'
          $initscript       = "${init_path}/${service_name}.service"
        }
        default: {
          $init_path        = '/etc/init.d'
          $service_template = 'bamboo_agent/init.sh.erb'
          $initscript       = "${init_path}/${service_name}"
        }
      }
    }
    default: {
      $init_path        = '/etc/init.d'
      $service_template = 'bamboo_agent/init.sh.erb'
      $initscript       = "${init_path}/${service_name}"
    }
  }

  file {$initscript:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template($service_template),
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => File[$initscript],
  }
}
