require 'spec_helper'

describe 'bamboo_agent::service' do
  let(:title) { 'test-agent'}
  let(:params) do {
    'username' => 'test-agent',
    'home'     => '/home/test-agent'
    }
  end
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :r9util_properties_lens_path => '/opt/puppetlabs/puppet/cache/lib/augeas/lenses'
          })
      end
    end
  end
end
