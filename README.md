# bamboo_agent

## Build Status
[![Build Status](https://travis-ci.org/knuedge/bamboo_agent.svg?branch=master)](https://travis-ci.org/knuedge/bamboo_agent)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with bamboo_agent](#setup)
    * [What bamboo_agent affects](#what-bamboo_agent-affects)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs and manages remote bamboo agents. It supports multiple agents and can manage the capabilities and wrapper.conf files.

## Setup

### What bamboo_agent affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Usage

The bamboo_agent class accepts a single parameter, agents, containing a hash of values that map directly onto the bamboo_agent::agent defined type. This example will create 2 bamboo agents, with custom capabilities and the wrapper.conf file managed for the first agent.

```
class { 'bamboo_agent':
  agents => {
    'bamboo-agent' => {
      home         => '/var/lib/bamboo-agent',
      server_url   => 'https://bamboo.example.com',
      capabilities => {
        'system.builder.command.Bash' => '/bin/bash',
        'hostname'                    => $::hostname,
      },
      'wrapper_conf_properties' => {
        'wrapper.java.additional.4' => '-Djsse.enableSNIExtension=false',
        'wrapper.java.additional.2' => '-Dbamboo.agent.ignoreServerCertName=TRUE'
      }
    },
    'bamboo-agent2' => {
      java_home  => '/etc/alternatives/jre_1.8.0',
      home       => '/var/lib/bamboo-agent2',
      server_url => 'https://bamboo.example.com',
    }
  }
}
```

To use hiera
```
include bamboo_agent
```

```
bamboo_agent::agents:
  'bamboo-agent':
    home: '/home/bamboo-agent'
    user_groups:
      - 'rvm'
    server_url: 'https://bamboo.example.com'
    capabilities:
      hostname: "%{::hostname}"
      os: "%{::operatingsystem}"
    wrapper_conf_properties:
      wrapper.java.additional.2: '-Dbamboo.agent.ignoreServerCertName=true'
      wrapper.java.additional.3: '-Djsse.enableSNIExtension=false'
```


## Reference

### Class `bamboo_agent`
The main class.
#### Parameters
* `agents`: Accepts a hash. See the bamboo_agent::agent defined type for accepted parameters

### Defined Type`bamboo_agent::agent`
#### Parameters
* `home`: *requried* The home directory of the bamboo-agent user
    - Default: unset
* `server_url`: *required* The bamboo server url
    - Default: unset
* `capabilities`: *optional* Hash of custom capabilites
    - Default: `{}`
* `manage_user`: *optionl* Whether the module should create the user account
    - Default: `true`
* `manage_groups`: *optional* Whether the module should create groups specified in `$user_groups*``
    - Default: `false`
* `manage_home`: *optional* Whether the module should create the users home directory
    - Default: `true`
* `username`: *optional* The username of the bamboo-agent user
    - Default: `$title`
* `user_groups`: *optional* Groups bamboo-agent user should be a member of
* `manage_capabilities`: *optional* Whether the module should manage the bamboo-agent's capabilities file
    - Default: `true`
* `wrapper_conf_properties`: *optoinal* Options to be placed in the bamboo-agent's wrapper.conf file
    - Default: `{}`
* `service_name`: *optional* Specify a unique name for the configured system service to be known as.
    - Default: `$title`
* `check_certificate`: *optional* Whether to have wget check the certificate of the Bamboo server when downloading the installer jar
    - Default: `true`
* `java_home`: *optional* Specify a value for the `JAVA_HOME` environment variable to include in the system init script.
    - Default: unset

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

- Fork this module
- Create a branch
- Add tests for your changes
- Submit a pull request


