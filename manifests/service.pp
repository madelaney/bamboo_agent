# set up the service

define bamboo_agent::service(
  $username,
  $home,
  ){

  case $::service_provider {
    #'systemd' : {
    #  $init_path     = ''
    #  $init_template = ''
    #}
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
    enable  => true,
    ensure  => running,
    require => File[$initscript]
    #hasrestart => true,
    #hasstatus  => true,
  }
}
