# This is needed to configure PF and start it so we don't loose
# SSH connection when running highstate
$provisionscript = <<SCRIPT

echo "--- START OF freebsd_init.rb ---"
kldload -q pf.ko
pfctl -q -F all
echo "pass in quick proto tcp from any to port ssh flags S/SA keep state" > /etc/pf.conf
pfctl -q -e
pfctl -qf /etc/pf.conf
echo "--- END OF freebsd_init.rb ---"

SCRIPT

Vagrant.configure(2) do |config|
  config.vm.provision "shell", inline: $provisionscript
end
