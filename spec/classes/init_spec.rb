require 'spec_helper'

describe 'bamboo_agent' do
  shared_examples 'all params' do
    let (:params) do {
      'agents' => {
        'test-agent' => {
          'home' => '/home/test-agent',
          'user_groups' => ['foo'],
          'manage_groups' => true,
          'server_url' => 'https://bamboo.example.com',
          'capabilities' => {
            'system.builder.command.Bash' => '/bin/bash',
            'hostname'                    => 'foo.exmaple.com',
          },
          'wrapper_conf_properties' => {
            'wrapper.java.additional.2' => '-Djsse.enableSNIExtension=false',
            'wrapper.java.additional.3' => '-Dbamboo.agent.ignoreServerCertName=TRUE'
          }
        },
        'test-agent2' => {
          'home'       => '/home/test-agent2',
          'server_url' => 'https://bamboo.example.com'
        }
      }
    }
    end
    context 'it should create the group' do
      it do
        should contain_group('foo')
      end
    end
    context 'it should create the user' do
      it do should contain_user('test-agent').with(
        'ensure'  => 'present',
        'comment' => 'bamboo-agent test-agent',
        'home'    => '/home/test-agent',
        'groups'  => ['foo'],
        'shell'   => '/bin/bash',
        'system'  => 'true',)
      end
      it do should contain_user('test-agent2').with(
        'ensure'  => 'present',
        'comment' => 'bamboo-agent test-agent2',
        'home'    => '/home/test-agent2',
        'shell'   => '/bin/bash',
        'system'  => 'true',)
      end
    end
    context 'it should create the home dir' do
      it do should contain_file('/home/test-agent').with(
        'ensure' => 'directory',
        'owner'  => 'test-agent')
      end
      it do should contain_file('/home/test-agent2').with(
        'ensure' => 'directory',
        'owner'  => 'test-agent2')
      end
    end
    context 'it should download the jar' do
      it do
        should contain_exec('download-test-agent-bamboo-agent-jar').with(
          'command' => 'wget https://bamboo.example.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar',
          'cwd'     => '/home/test-agent',
          'user'    => 'test-agent',
          'path'    => ['/usr/bin','/bin'],
          'creates' => '/home/test-agent/atlassian-bamboo-agent-installer.jar').that_requires('File[/home/test-agent]')
      end
      it do
        should contain_exec('download-test-agent2-bamboo-agent-jar').with(
          'command' => 'wget https://bamboo.example.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar',
          'cwd'     => '/home/test-agent2',
          'user'    => 'test-agent2',
          'path'    => ['/usr/bin','/bin'],
          'creates' => '/home/test-agent2/atlassian-bamboo-agent-installer.jar').that_requires('File[/home/test-agent2]')
      end
    end
    context 'it should install the jar' do
      it do
        should contain_exec('install-test-agent-bamboo-agent') .with(
          'command' => 'java -jar -Dbamboo.home=/home/test-agent atlassian-bamboo-agent-installer.jar https://bamboo.example.com/agentServer/ install',
          'cwd'     => '/home/test-agent',
          'user'    => 'test-agent',
          'path'    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
          'creates' => '/home/test-agent/bin/bamboo-agent.sh',
          )
      end
      it do
        should contain_exec('install-test-agent2-bamboo-agent') .with(
          'command' => 'java -jar -Dbamboo.home=/home/test-agent2 atlassian-bamboo-agent-installer.jar https://bamboo.example.com/agentServer/ install',
          'cwd'     => '/home/test-agent2',
          'user'    => 'test-agent2',
          'path'    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
          'creates' => '/home/test-agent2/bin/bamboo-agent.sh',
          )
      end
      it do
        should contain_service('test-agent').with(
          'ensure' => 'running',
          'enable' => 'true',
          )
      end
    end
  end
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it_behaves_like 'all params'
      #it do
      #  should compile.with_all_deps
      #end
    end
  end
end

