require 'serverspec'
set :backend, :exec

describe 'pf/init.sls' do
  describe kernel_module('pf') do
    it { should be_loaded }
  end

end
