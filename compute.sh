#!/bin/bash
for args in $@
do
echo $args
done
sed -i '21d' /etc/chrony/chrony.conf
sed -i '20 a server controller iburst' /etc/chrony/chrony.conf
service chrony restart
sed -i '2,100d' /etc/network/interfaces
sed -i '1 a auto eth0' /etc/network/interfaces
sed -i '2 a iface eth0 inet static' /etc/network/interfaces
sed -i "3 a address $1" /etc/network/interfaces
sed -i "4 a netmask $2" /etc/network/interfaces
sed -i "5 a gateway $3" /etc/network/interfaces
sed -i '6 a dns-nameservers 203.95.1.2' /etc/network/interfaces
sed -i '7 a #' /etc/network/interfaces
sed -i '8 a auto eth1' /etc/network/interfaces
sed -i '9 a iface eth1 inet manual' /etc/network/interfaces
sed -i '10 a up ip link set dev $IFACE up' /etc/network/interfaces
sed -i '11 a down ip link set dev $IFACE down' /etc/network/interfaces
sed -i '12 a #' /etc/network/interfaces
sed -i '13 a auto lo' /etc/network/interfaces
sed -i '14 a iface lo inet loopback' /etc/network/interfaces
ifdown eth0 && ifup eth0
ifdown eth1 && ifup eth1
sed -i '2,100d' /etc/hostname
sed -i "1 a compute$5" /etc/hostname
sed -i '2,100d' /etc/hosts
sed -i '1 a 127.0.0.1  localhost' /etc/hosts
sed -i "2 a $4  controller" /etc/hosts
for ((i=1;i<=$6;i++))
do
let a=2+$i
let mid=6+$i
let b=$mid
#echo $a
#echo $mid
#echo $b
eval c="$"$b""
#echo $c
sed -i "$a a $c  compute$i" /etc/hosts
done
echo -e "your compute node managerment ip is $1"
sleep 1
echo -e "your compute node ip netmask is $2"
sleep 1
echo -e "your compute node ip gateway $3"
sleep 1
#echo -e "your controller node external name is $4"
#sleep 1
#echo -e "your compute node number is $5"
#sleep 1
echo -e "total compute node number is $6"
sleep 1
for ((i=1;i<=$6;i++))
do
let mid=6+$i
let b=$mid
eval c="$"$b""
echo -e "your compute$i node ip address is $c"
sleep 1
done
#echo -n "Please enter your management ip address > "
#read MANAGEMENT_NETWORK
crudini --set /etc/nova/nova.conf DEFAULT my_ip $1
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$4:6080/vnc_auto.html
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $1
#service mysql restart
#crudini --set /etc/mongodb.conf '' bind_ip $1
#service mongodb stop
#rm /var/lib/mongodb/journal/prealloc.*
#service mongodb start
#crudini --set /etc/nova/nova.conf DEFAULT my_ip $1
#su -s /bin/sh -c "nova-manage db sync" nova
#echo -n "Please enter your ext ip name, for example:eth1 > "
#read EXT_NETWORK_NAME
#crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings public:$4
#crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $1
#su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
#info()
#{
#   brctl show | grep brq
#}
#res=`info`
#brq_num=${res:3:11}
#echo ${res:3:11}
#echo ${res} | awk '{print length ($9)}'
#brctl addif brq$brq_num $4
