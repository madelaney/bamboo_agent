# create the agent
define bamboo_agent::agent(
  $home,
  $server_url,
  $capabilities = {},
  $manage_user = true,
  $manage_home = true,
  $username = $title,
#  $user_groups = [],
  $manage_capabilities = true,
  $wrapper_conf_properties = {},
  )
{

  # setup user
  if $manage_user == true {
    user { $username:
      ensure  => present,
      comment => "bamboo-agent ${username}",
      home    => $home,
      shell   => '/bin/bash',
      #groups  => $user_groups,
      system  => true,
    }
  }

  if $manage_home == true {
    file {$home:
      ensure => directory,
      owner  => $username,
    }
  }
  # dowload the jar
  exec {"download-${title}-bamboo-agent-jar":
    command => "wget ${server_url}/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar",
    cwd     => $home,
    user    => $username,
    path    => ['/usr/bin', '/bin'],
    creates => "${home}/atlassian-bamboo-agent-installer.jar",
    require => File[$home],
  }
  ->
  exec { "install-${title}-bamboo-agent":
    command => "java -jar -Dbamboo.home=${home} atlassian-bamboo-agent-installer.jar ${server_url}/agentServer/ install",
    cwd     => $home,
    user    => $username,
    path    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    creates => "${home}/bin/bamboo-agent.sh",
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
