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
