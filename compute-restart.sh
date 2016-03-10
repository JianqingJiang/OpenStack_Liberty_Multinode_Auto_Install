source admin-openrc.sh
service chrony restart
service nova-compute restart
service neutron-plugin-linuxbridge-agent restart
nova service-list
neutron agent-list
