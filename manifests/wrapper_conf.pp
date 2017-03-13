# Defines properties in the wrapper.conf file
# @param home The home directory of the bamboo-agent user
# @param properties A hash of options to add to the wrapper.conf file
define bamboo_agent::wrapper_conf (
  $home,
  $properties = {},
  )
{
  $path = "${home}/conf/wrapper.conf"

  r9util::java_properties {$path:
    properties => $properties
  }

}
