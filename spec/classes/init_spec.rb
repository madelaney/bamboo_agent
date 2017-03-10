require 'spec_helper'
describe 'bamboo_agent' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      #context 'with default values for all parameters' do
      #  it { should contain_class('bamboo_agent') }
      #end
    end
  end
end
