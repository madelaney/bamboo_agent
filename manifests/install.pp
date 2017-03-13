# download and install install the jar file
# this defined type is private
#
# @param home home directory for bamboo-agent user
# @param username username of the bamboo-agent account
# @param server_url the url for the bamboo server
define bamboo_agent::install (
  $home,
  $username,
  $server_url,
  )
{
  assert_private()

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
}
