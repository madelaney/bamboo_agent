# download and install install the jar file
# this defined type is private
#
# @param home home directory for bamboo-agent user
# @param username username of the bamboo-agent account
# @param server_url the url for the bamboo server
define bamboo_agent::install (
  String           $home,
  String           $username,
  String           $server_url,
  Boolean          $check_certificate = true,
  Optional[String] $java_home         = undef,
) {
  assert_private()

  $path = $java_home ? {
    Undef   => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    default => [ "${java_home}/bin", '/bin', '/usr/bin', '/usr/local/bin' ],
  }

  $no_check_cert_flag = $check_certificate ? {
    false   => '--no-check-certificate',
    default => ''
  }

  exec {"download-${title}-bamboo-agent-jar":
    command => "wget ${no_check_cert_flag} ${server_url}/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar",
    cwd     => $home,
    user    => $username,
    path    => ['/usr/bin', '/bin'],
    creates => "${home}/atlassian-bamboo-agent-installer.jar",
    require => File[$home],
  }

  exec { "install-${title}-bamboo-agent":
    command => "java -jar -Dbamboo.home=${home} atlassian-bamboo-agent-installer.jar ${server_url}/agentServer/ install",
    cwd     => $home,
    user    => $username,
    path    => $path,
    creates => "${home}/bin/bamboo-agent.sh",
    require => Exec["download-${title}-bamboo-agent-jar"],
  }
}

