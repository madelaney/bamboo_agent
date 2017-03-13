require 'spec_helper'

describe 'bamboo_agent::agent' do
  shared_examples 'all params' do
    let (:title) { 'test-agent' }
    let (:params) do {
      'home' => '/home/test-agent',
      'server_url' => "https://bamboo.example.com",
      'capabilities' => {
        'system.builder.command.Bash' => '/bin/bash',
        'hostname'                    => 'foo.exmaple.com',
      },
      'wrapper_conf_properties' => {
        'wrapper.java.additional.2' => '-Djsse.enableSNIExtension=false',
        'wrapper.java.additional.3' => '-Dbamboo.agent.ignoreServerCertName=TRUE'
      }
    }
    end
    context 'it should create the user' do
      it { should contain_user('test-agent').with(
        'ensure'  => 'present',
        'comment' => 'bamboo-agent test-agent',
        'home'    => '/home/test-agent',
        'shell'   => '/bin/bash',
        'system'  => 'true',)
      }
    end
    context 'it should create the home dir' do
      it { should contain_file('/home/test-agent').with(
        'ensure' => 'directory',
        'owner'  => 'test-agent')
      }
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
    end
    context 'it should compile' do
      it do
        should compile.with_all_deps
      end
    end
  end
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :r9util_properties_lens_path => '/opt/puppetlabs/puppet/cache/lib/augeas/lenses'
          })
      end
      it_behaves_like 'all params'
    end
  end
end

