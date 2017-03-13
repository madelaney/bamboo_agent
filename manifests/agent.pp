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
define bamboo_agent::agent(
  $home,
  $server_url,
  $capabilities = {},
  $manage_user = true,
  $manage_groups = false,
  $manage_home = true,
  $username = $title,
  $user_groups = [],
  $manage_capabilities = true,
  $wrapper_conf_properties = {},
  )
{

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
  bamboo_agent::install {$username:
    home       => $home,
    username   => $username,
    server_url => $server_url,
  }
  ~>
  if $manage_capabilities == true {
    bamboo_agent::capabilities{$username:
      home         => $home,
      username     => $username,
      capabilities => $capabilities,
      require      => User[$username]
    }
  }

  bamboo_agent::wrapper_conf {$username:
    home       => $home,
    properties => $wrapper_conf_properties,
  }

  bamboo_agent::service{$username:
    username => $username,
    home     => $home,
  }

}
