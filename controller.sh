#!/bin/bash
for args in $@
do
echo $args
done 
sed -i '21d' /etc/chrony/chrony.conf
sed -i '20 a server controller iburst' /etc/chrony/chrony.conf
service chrony restart
sed -i '2,100d' /etc/network/interfaces
sed -i "1 a auto $1" /etc/network/interfaces
sed -i "2 a iface $1 inet static" /etc/network/interfaces
sed -i "3 a address $2" /etc/network/interfaces
sed -i "4 a netmask $3" /etc/network/interfaces
sed -i "5 a gateway $4" /etc/network/interfaces
sed -i '6 a dns-nameservers 203.95.1.2' /etc/network/interfaces
sed -i '7 a #' /etc/network/interfaces
sed -i "8 a auto $5" /etc/network/interfaces
sed -i "9 a iface $5 inet manual" /etc/network/interfaces
sed -i '10 a up ip link set dev $IFACE up' /etc/network/interfaces
sed -i '11 a down ip link set dev $IFACE down' /etc/network/interfaces
sed -i '12 a #' /etc/network/interfaces
sed -i '13 a auto lo' /etc/network/interfaces
sed -i '14 a iface lo inet loopback' /etc/network/interfaces
ifdown $1 && ifup $1
ifdown $5 && ifup $5
sed -i '2,100d' /etc/hosts
sed -i '1 a 127.0.0.1  localhost' /etc/hosts
sed -i "2 a $2  controller" /etc/hosts
for ((i=1;i<=$6;i++))
do
let a=2+$i
let mid=6+$i
let b=$mid
#echo $a
#echo $mid
#echo $b
eval c="$""{""$b"}""
#echo $c
sed -i "$a a $c  compute$i" /etc/hosts
done
echo -e "your controller node managerment netcard name is $1"
sleep 1
echo -e "your controller node managerment ip is $2"
sleep 1
echo -e "your controller node ip netmask is $3"
sleep 1
echo -e "your controller node ip gateway $4"
sleep 1
echo -e "your controller node external netcard name is $5"
sleep 1
echo -e "your compute node number is $6"
sleep 1
for ((i=1;i<=$6;i++))
do
let mid=6+$i
let b=$mid
eval c="$""{""$b"}""
echo -e "your compute$i node ip address is $c"
sleep 1
done
#echo -n "Please enter your management ip address > "
#read MANAGEMENT_NETWORK
crudini --set /etc/mysql/conf.d/mysqld_openstack.cnf mysqld bind-address $2
service mysql restart
crudini --set /etc/mongodb.conf '' bind_ip $2
service mongodb stop
#rm /var/lib/mongodb/journal/prealloc.*
service mongodb start
crudini --set /etc/nova/nova.conf DEFAULT my_ip $2
su -s /bin/sh -c "nova-manage db sync" nova
#echo -n "Please enter your ext ip name, for example:eth1 > "
#read EXT_NETWORK_NAME
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings public:$5
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $2
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
info()
{
   brctl show | grep brq
}
res=`info`
brq_num=${res:3:11}
#echo ${res:3:11}
#echo ${res} | awk '{print length ($9)}'
brctl addif brq$brq_num $5
