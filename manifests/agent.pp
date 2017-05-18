# defined type to create bamboo agents
#
#
# @param home home directory for the bamboo agent user
# @param server_url url for the bamboo server the agent talks to
# @param capabilities hash of custom capabilities for the agent
# @param manage_user Create the bamboo service account(s)
# @param manage_groups Create the groups specified for bamboo agent user
# @param manage_home If set to true, will create the home directory for the bamboo agent user
# @param username Username for bamboo-agent service account
# @param user_groups A list of groups to add the bamboo-agent user too
# @param manage_capabilities Whether the module should manage the capabilities file for the agent
# @param wrapper_conf_properties Additonal java arguments to put in wrapper.conf
# @param check_certificate Whether to have wget check the certificate of the Bamboo server when downloading the installer jar
# @param java_home Specify a value for the `JAVA_HOME` environment variable to include in the system init script
define bamboo_agent::agent (
  String           $home,
  String           $server_url,
  Hash             $capabilities            = {},
  Boolean          $manage_user             = true,
  Boolean          $manage_groups           = false,
  Boolean          $manage_home             = true,
  String           $username                = $title,
  String           $service_name            = $title,
  Array            $user_groups             = [],
  Boolean          $manage_capabilities     = true,
  Hash             $wrapper_conf_properties = {},
  Boolean          $check_certificate       = true,
  Optional[String] $java_home               = undef,
) {

  if $manage_groups == true {
    group {$user_groups:
      ensure => present,
    }
  }
  # setup user
  if $manage_user == true {
    user { $username:
      ensure  => present,
      comment => "bamboo-agent ${username}",
      home    => $home,
      shell   => '/bin/bash',
      groups  => $user_groups,
      system  => true,
    }
  }

  if $manage_home == true {
    file {$home:
      ensure => directory,
      owner  => $username,
    }
  }

  bamboo_agent::install {$service_name:
    home              => $home,
    username          => $username,
    server_url        => $server_url,
    check_certificate => $check_certificate,
    java_home         => $java_home,
  }

  if $manage_capabilities == true {
    bamboo_agent::capabilities { $service_name:
      home         => $home,
      username     => $username,
      capabilities => $capabilities,
      require      => [ User[$username], Bamboo_agent::Install[$service_name], ],
      notify       => Service[$service_name],
    }
  }

  bamboo_agent::wrapper_conf { $service_name:
    home       => $home,
    properties => $wrapper_conf_properties,
    notify     => Service[$service_name]
  }

  bamboo_agent::service { $service_name:
    username  => $username,
    home      => $home,
    java_home => $java_home,
    require   => Bamboo_Agent::Install[$service_name],
  }

}
