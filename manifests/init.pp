# Class: bamboo_agent
# ===========================
#
# This simply calls on the bamboo_agent::agent defined type to create the bamboo agent(s)
#
# $agents should contain a hash mapping to the parameters in the bamboo_agent::agent defined type
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

# @example Create 2 puppet agents
# @example
#    class { 'bamboo_agent':
#     'agents' =>
#        'bamboo-agent' => {
#        home         => '/var/lib/bamboo-agent',
#        server_url   => 'https://bamboo.example.com',
#        capabilities => {
#          'system.builder.command.Bash' => '/bin/bash',
#          'hostname'                    => $::hostname,
#        },
#        'wrapper_conf_properties' => {
#          'wrapper.java.additional.4' => '-Djsse.enableSNIExtension=false',
#          'wrapper.java.additional.2' => '-Dbamboo.agent.ignoreServerCertName=TRUE'
#        }
#      },
#        'bamboo-agent2' => {
#          home       => '/var/lib/bamboo-agent2',
#          server_url => 'https://bamboo.example.com',
#        }
#    }
#  }
#
# Authors
# -------
#
# Author Name dschaaff@knuedge.com
#
# Copyright
# ---------
#
# Copyright 2017 KnuEdge, Inc.
#
# @param agents hash of bamboo agents mapping to bamboo_agent::agent defined type
class bamboo_agent (
  Hash $agents = {},
) {

  # user iteration and other defines to setup each agent
  $agents.each |String $agent, Hash $params| {
    bamboo_agent::agent { $agent:
      * => $params,
    }
  }
}
