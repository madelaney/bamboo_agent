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
