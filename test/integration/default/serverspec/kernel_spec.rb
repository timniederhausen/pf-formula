require 'serverspec'
set :backend, :exec

describe 'pf/inir.sls' do
  describe kernel_module('pf') do
    it { should be_loaded }
  end

end
