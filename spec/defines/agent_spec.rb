require 'spec_helper'
describe 'bamboo_agent::agent' do
  shared_examples 'all params' do
    let :title do 'test-agent' end
    let :params do {
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
    context 'it should createt the user' do
      it { should contain_user('test-agent').with(
        'ensure'  => 'present',
        'comment' => 'bamboo-agent test-agent',
        'home'    => '/home/test-agent'),
        'shell'   => '/bin/bash',
        'system'  => 'true,'
      }
    end
    context 'it should create the home dir' do
      it { should contain_file('/home/test-agent').with(
        'ensure' => 'directory',
        'owner'  => 'test-agent')
      }
    end
    context 'it should download the jar' do
      it should contain_exec('download-test-agent-bamboo-agent-jar').with(
        'command' => 'wget https://bamboo.example.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar',
        'cwd'     => '/home/test-agent',
        'user'    => 'test-agent',
        'path'    => ['/usr/bin','bin'],
        'creates' => '/home/test-agent/atlassian-bamboo-agent-installer.jar').that_requires('File[/home/test-agent]')
    end
    context 'it should install the jar' do
      it should contain_exec('install-test-agent-bamboo-agent')
    end
  end
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      # TODO:need to update once systemd files in place
      if facts['operatinsystem'] = 'Ubuntu' and facts['operatingsystemmajrelease'] == '14.04' then
        context 'it should createt the user' do
          it_behaves_like 'all params'
        end
      elsif facts['osfamily'] = 'Redhat' and facts['operatingsystemmajrelease'] == '6' then
        context 'it should createt the user' do
          it_behaves_like 'all params'
        end
      end
    end
  end
  at_exit { RSpec::Puppet::Coverage.report! }

end
