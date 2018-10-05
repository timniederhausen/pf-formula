require 'serverspec'
set :backend, :exec

describe file('/etc/pf.conf') do
  it { should exist }
  its(:content) { should match 'public_interface = "em0"' }
  its(:content) { should match 'jail_network = "192.168.1.0/24"' }
  its(:content) { should match 'skip on lo0' }
  its(:content) { should match 'scrub on \$public_interface reassemble tcp no-df random-id' }
  its(:content) { should match 'nat on \$public_interface from em0 to \!\$jail_network -> \(\$public_interface\)' }
  its(:content) { should match 'block log all' }
  its(:content) { should match 'pass out quick no state' }
  its(:content) { should match 'pass in proto { icmp, icmp6 } from any to any no state' }
  # Test ordering also
  it { should contain('public_interface = "em0"').after(/^\# Macros/) }
  it { should contain('skip on lo0').after(/\# Options/) }
  it { should contain('scrub on \$public_interface reassemble tcp no-df random-id').after(/\# Traffic/) }
  it { should contain('nat on \$public_interface from em0 to !\$jail_network -> (\$public_interface)').after(/^\# Translation/) }
  it { should contain('block log all').after(/^\# Packet Filtering/) }
  it { should contain('pass out quick no state').after(/^\# Packet Filtering/) }
  it { should contain('pass in proto { icmp, icmp6 } from any to any no state').after(/^\# Packet Filtering/) }
end

