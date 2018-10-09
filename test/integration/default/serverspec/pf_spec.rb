require 'serverspec'
require 'json'

set :backend, :exec

pillar = JSON.parse(`salt-call --local --config-dir=/tmp/kitchen/etc/salt -l quiet --output=json pillar.get pf`)['local'] || ''

describe 'pf/init.sls' do
  if pillar['service_enabled']
    describe kernel_module('pf') do
      it { should be_loaded }
    end

    describe service('pf') do
      it { should be_enabled }
    end

    describe service('pf') do
      it { should be_running }
    end

    if pillar['pflog']['enabled']
      describe kernel_module('pflog') do
        it { should be_loaded }
      end

      describe service('pflog') do
        it { should be_enabled }
      end

      describe service('pflog') do
        it { should be_running }
      end
    end

    if pillar['pfsync']['enabled']
      describe "pfsync" do

        it "kernel module is loaded" do
          expect(kernel_module('pfsync')).to be_loaded
        end

        it "is enabled to start on boot" do
          expect(service('pfsync')).to be_enabled
        end

        # pfsync service rc file doesn't have a 'status' option
        # so we check if the interface is properly configured
        if !pillar['pfsync']['syncdev'].to_s.strip.empty? && !pillar['pfsync']['syncpeer'].to_s.strip.empty?
          it "pfsync0 interface is correctly configured" do
            expect(command("ifconfig pfsync0 | grep -i pfsync\: | sed 's/^[[:space:]]*//'").stdout).to match("^pfsync: syncdev: #{pillar['pfsync']['syncdev']} syncpeer: #{pillar['pfsync']['syncpeer']} maxupd: 128 defer: off")
          end
        end
      end
    end
  end
end
