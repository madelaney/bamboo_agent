# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://docs.puppet.com/guides/tests_smoke.html
#
class { 'bamboo_agent':
  agents => {
    'bamboo-agent'  => {
      home                      => '/var/lib/bamboo-agent',
      server_url                => 'https://bamboo.example.com',
      capabilities              => {
        'system.builder.command.Bash' => '/bin/bash',
        'hostname'                    => $::hostname,
      },
      'wrapper_conf_properties' => {
        'wrapper.java.additional.3' => '-Djsse.enableSNIExtension=false',
        'wrapper.java.additional.2' => '-Dbamboo.agent.ignoreServerCertName=true'
      }
    },
    'bamboo-agent2' => {
      home       => '/var/lib/bamboo-agent2',
      server_url => 'https://bamboo.example.com',
    }
  }
}

