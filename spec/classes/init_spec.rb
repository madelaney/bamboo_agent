require 'spec_helper'

describe 'bamboo_agent' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :r9util_properties_lens_path => '/opt/puppetlabs/puppet/cache/lib/augeas/lenses'
          })
      end
      let (:title) { 'test-agent' }
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
      context 'it should contain agent defined type' do
        it { should contain_bamboo_agent__agent('test-agent')}
        it { should contain_bamboo_agent__agent('test-agent2')}
      end
      context 'it should create the user' do
        it do
          should contain_group('foo')
        end
        it do should contain_user('test-agent').with(
          'ensure'  => 'present',
          'comment' => 'bamboo-agent test-agent',
          'home'    => '/home/test-agent',
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
      context 'it should install the jar' do
        it { should contain_bamboo_agent__install('test-agent')}
        it { should contain_bamboo_agent__install('test-agent2')}
        it do
          should contain_exec('download-test-agent-bamboo-agent-jar').with(
            'command' => 'wget  https://bamboo.example.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar',
            'cwd'     => '/home/test-agent',
            'user'    => 'test-agent',
            'path'    => ['/usr/bin','/bin'],
            'creates' => '/home/test-agent/atlassian-bamboo-agent-installer.jar').that_requires('File[/home/test-agent]')
        end
        it do
          should contain_exec('download-test-agent2-bamboo-agent-jar').with(
            'command' => 'wget  https://bamboo.example.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar',
            'cwd'     => '/home/test-agent2',
            'user'    => 'test-agent2',
            'path'    => ['/usr/bin','/bin'],
            'creates' => '/home/test-agent2/atlassian-bamboo-agent-installer.jar').that_requires('File[/home/test-agent2]')
        end
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
      end
      context 'it should manage capabilities file' do
        it { should contain_bamboo_agent__capabilities('test-agent') }
        it { should contain_bamboo_agent__capabilities('test-agent2') }
        it do
          should contain_file('/home/test-agent/bin/bamboo-capabilities.properties')
          should contain_file('/home/test-agent2/bin/bamboo-capabilities.properties')
          verify_contents(catalogue, '/home/test-agent/bin/bamboo-capabilities.properties', [
            "system.builder.command.Bash=/bin/bash",])
        end
      end
      context 'it should set wrapper conf properties' do
        it { should contain_bamboo_agent__wrapper_conf('test-agent') }
        it { should contain_bamboo_agent__wrapper_conf('test-agent2') }
        it do
          should contain_r9util__java_properties('/home/test-agent/conf/wrapper.conf')
          should contain_r9util__java_properties('/home/test-agent2/conf/wrapper.conf')
        end
      end
      context 'it should setup the service' do
        it { should contain_bamboo_agent__service('test-agent')}
        it { should contain_bamboo_agent__service('test-agent2')}
        if facts[:lsbdistcodename] == 'xenial' or facts[:operatingsystemmajrelease] == '7' then
          it do should contain_file('/lib/systemd/system/test-agent.service').with_content(
            /User=test-agent\nGroup=test-agent\nExecStart=\/home\/test-agent\/bin\/bamboo-agent.sh start\nExecStop=\/home\/test-agent\/bin\/bamboo-agent.sh stop/
            )
          end
          it do should contain_file('/lib/systemd/system/test-agent2.service').with_content(
            /User=test-agent2\nGroup=test-agent2\nExecStart=\/home\/test-agent2\/bin\/bamboo-agent.sh start\nExecStop=\/home\/test-agent2\/bin\/bamboo-agent.sh stop/
            )
          end
        else
          it do
            should contain_file('/etc/init.d/test-agent')
            verify_contents(catalogue, '/etc/init.d/test-agent', [
              "APP=test-agent",
              "USER=test-agent",
              "BASE=/home/test-agent"])
          end
          it do
            should contain_file('/etc/init.d/test-agent2')
            verify_contents(catalogue, '/etc/init.d/test-agent2', [
              "APP=test-agent2",
              "USER=test-agent2",
              "BASE=/home/test-agent2"])
          end
        end
        it do
          should contain_service('test-agent').with(
            'ensure' => 'running',
            'enable' => 'true')
        end
        it do
          should contain_service('test-agent2').with(
            'ensure' => 'running',
            'enable' => 'true')
        end
      end
      context 'it should compile' do
        it do
          should compile.with_all_deps
        end
      end
    end
  end
end

