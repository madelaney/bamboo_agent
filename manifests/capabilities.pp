# create a bamboo capabilities file
# https://confluence.atlassian.com/bamboo/configuring-remote-agent-capabilities-using-bamboo-capabilities-properties-289276849.html
# @param home home directory of the bamboo agent user
# @param username the username of the bamboo agent user
# @param capabilities A hash of custom capablities for the agent
define bamboo_agent::capabilities(
  $home,
  $username,
  $capabilities = {},
  ){

  file {"${home}/bin/bamboo-capabilities.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $username,
    content => template('bamboo_agent/bamboo-capabilities.properties.erb')
    }
}
