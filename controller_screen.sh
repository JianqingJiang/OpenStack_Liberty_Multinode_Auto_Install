#! /bin/bash
#init=1
yesno() 
{
    dialog --title "First screen" --backtitle "BNC Software" --clear --yesno \
        "Start this program or not ? \nThis decesion have to make by Admin." 16 51

    # yes is 0, no is 1 , esc is 255
    result=$?
    if [ $result -eq 1 ] ; then
        exit 1;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    menu;
}



menu()
{
    dialog --title "Second screen" --backtitle "BNC Software" --menu "Choose one" 12 35 5 \
    1 "controller node config" 2 "compute node config" 3 "config list" 4 "install" 5 "exit" 2>/tmp/select
    # yes is 0, no is 1 , esc is 255
    result=$(cat /tmp/select)
    if [ $result -eq 1 ] ; then
        eth_dialog;
    elif [ $result -eq 2 ] ; then
        compute_number;
    elif [ $result -eq 3 ] ; then
        config_list;
    elif [ $result -eq 4 ] ; then
        install_dialog;
    elif [ $result -eq 5 ] ; then
        exit 255;   
    elif [ $result -eq 255 ] ; then
        exit 255;
    fi
}

eth_num()
{
wc -l /tmp/eth_all>/tmp/eth_number
#tail -n 1 /tmp/eth_number|awk {'print $1'}
export eth_num=`tail -n 1 /tmp/eth_number|awk {'print $1'}`
#echo $eth_num
}


select_eth()
{
    ip a | grep 'eth' | awk '{print $2}' | grep eth >/tmp/eth_all
    eth_num;
    eth_text;
}

eth_text()
{
    x=1
    cat /tmp/eth_all | while read line
    do
        echo ${line:0:4}>/tmp/eth_$x
        x=`expr $x + 1`
    done
}

convert()
{
    eth_hang[i]=`cat /tmp/eth_$i`
#    echo ${eth_hang[i]}
}

eth_add_text()
{
    eth_add[$i]=${eth_add[$i]}$i" "${eth_hang[$i]}
#    echo ${eth_add[$i]}
}

eth_sum()
{
    eth_sum=$eth_sum${eth_add[$i]}" "
#    echo $eth_sum
}

eth_real()
{   
    n=$(cat /tmp/mgnt_eth)
    echo ${eth_hang[$n]}>/tmp/mgnt_eth_real
}

eth_dialog()
{
   dialog --title "Pick a choice" --menu "Choose your management netcard" 12 35 5 \
   $eth_sum 2>/tmp/mgnt_eth
   result=$?
   if [ $result -eq 1 ] ; then
       menu;
   elif [ $result -eq 255 ]; then
       exit 255;
   fi
   controller;
}

controller() 
{
    cat /dev/null >/tmp/management_ip
    dialog --title "Third screen" --backtitle "BNC Software" --clear --inputbox \
        "Please input your Management ip for OpenStack controller (default: 0.0.0.0) " 16 51 "0.0.0.0" 2>/tmp/controller_ip
#dialog --title "Configuration" --form "Please input the configuration for OpenStack:" 15 50 5    "Management ip:" 1  1 "" 1  25  18  0    "Netmask:" 2  1 "" 2  25  18  0    "Gateway:" 3  1 "" 3  25  18  0    "External netcard name:"    4   1 "" 4  25  18  0    "Compute node number:" 5  1 "" 5  25  18  0
    result=$?
    if [ $result -eq 1 ] ; then
        eth_dialog;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    netmask;
}

netmask() 
{
    cat /dev/null >/tmp/netmask
    dialog  --title "Fourth screen" --backtitle "BNC Software" --clear --inputbox \
        "Please input your netmask (default: 255.255.255.0) " 16 51 "255.255.255.0" 2>/tmp/netmask

    result=$?
    if [ $result -eq 1 ] ; then
        controller;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    gateway;
}

gateway()
{
    cat /dev/null >/tmp/gateway
    dialog  --title "Fifth screen" --backtitle "BNC Software" --clear --inputbox \
        "Please input your gateway ip address (default: 192.168.0.1) " 16 51 "192.168.0.1" 2>/tmp/gateway

    result=$?
    if [ $result -eq 1 ] ; then
        netmask;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    netcard_name;
}


netcard_name()
{
    dialog --title "Pick a choice(2)" --menu "Choose your external netcard" 12 35 5 \
    $eth_sum 2>/tmp/netcard_name
    result=$?
    if [ $result -eq 1 ] ; then
        gateway;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    menu;
}

netcard_real()
{
    n=$(cat /tmp/netcard_name)
    echo ${eth_hang[$n]}>/tmp/netcard_real
}


compute_number()
{
    cat /dev/null >/tmp/compute_number
    dialog  --title "Third screen" --backtitle "BNC Software" --clear --inputbox \
        "Please input your compute node number (default: 1) " 16 51 "1" 2>/tmp/compute_number

    result=$?
    if [ $result -eq 1 ] ; then
        menu;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi

    
}
compute() 
{
    cat /dev/null >/tmp/compute$i
    dialog --title "compute configuration screen" --backtitle "BNC Software" --clear --inputbox \
        "Please input your compute$i ip address: (default: 192.168.0.2)" 16 51 "192.168.0.2" 2>/tmp/compute$i

    result=$?
    if [ $result -eq 1 ] ; then
        exit 255;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi
#    let x=1+$i
#    compute;
}

#for ((i=1;i<=$number;i++))
#do
#compute $i;
#done
#dialog --backtitle "first" --title "first" --yesno "first" 15 60  
finish() 
{
#    dialog --title "Confirm screen" --backtitle "BNC Software" --clear --inputbox \
    dialog --title "Confirm screen" --backtitle "BNC Software" --yesno "Congratulations! The BNC OpenStack configuration has finished!" 15 60  
#        "Congratulations! The BNC Software has finished!" 16 51 
#n : $(cat /tmp/test.username)\n Password: $(cat /tmp/test.password)\n Occupation: $(cat /tmp/test.occupation)" 16 51

#    result=$?
#    if [ $result -eq 1 ] ; then
#        occupation
#    elif [ $result -eq 255 ]; then
#        exit 255;
#    fi
     menu;
}

config_list()
{     
     dialog --title "Third screen" --backtitle "BNC Software" --clear --msgbox \
     "Managemnet netcard name: $(cat /tmp/mgnt_eth_real) \n Controller management ip: $(cat /tmp/controller_ip) \n Netmask: $(cat /tmp/netmask)\n Gateway: $(cat /tmp/gateway)\n External netcard name: $(cat /tmp/netcard_real)\n Compute node number: $(cat /tmp/compute_number)\n $sum" 16 51
     result=$?
     if [ $result -eq 1 ] ; then
     menu;
     elif [ $result -eq 0 ] ; then
     menu;
     elif [ $result -eq 255 ]; then
     exit 255;
     fi
     
}
text_compute()
{
    pretext[$i]="Compute$i ip address: "
    text[$i]="$(cat /tmp/compute$i)"
    echo ${text[$i]}
}
add_text()
{
    add[$i]=${add[$i]}${pretext[$i]}${text[$i]}"\n"" "
}


compute_ip_sum()
{
    ip_sum[$i]=${ip_sum[$i]}${text[$i]}" "
#   echo ${ip_sum[$i]}
}

sum_up()
{
    sumup=$sumup${ip_sum[$i]}
#   echo $sumup
}


sum()
{
    sum=$sum${add[$i]} #>/tmp/stream
}

install_dialog()
{
    dialog --title "Second screen" --backtitle "BNC Software" --clear --yesno \
    "Install BNC OpenStack or not ? \nPlease make sure your config is ready." 16 51

    # yes is 0, no is 1 , esc is 255
    result=$?
    if [ $result -eq 1 ] ; then
        menu;
    elif [ $result -eq 255 ]; then
        exit 255;
    fi
    install;
}

install()
{
    declare -i PERCENT=0
    (
        ./controller.sh $(cat /tmp/mgnt_eth_real) $(cat /tmp/controller_ip) $(cat /tmp/netmask) $(cat /tmp/gateway) $(cat /tmp/netcard_real) $(cat /tmp/compute_number) $sumup 1>suc.txt 2>err.txt
        while(($PERCENT<100))
        do
                if [ $PERCENT -le 100 ];then
                    echo $PERCENT
                fi
        let PERCENT+=1
        sleep 0.1
        done
    ) | dialog --title "Second screen" --backtitle "BNC Software" --gauge "OpenStack will install in a few minutes...\n The successful log in suc.txt and The error log in err.txt" 12 50 0
    menu;
}

select_eth;
for((i=1;i<=$eth_num;i++))
{
convert $i;
}
for((i=1;i<=$eth_num;i++))
{
eth_add_text $i;
}
for((i=1;i<=$eth_num;i++))
{
eth_sum $i;
}
eth_real;
netcard_real;

yesno;
number=($(awk '{print $1}' /tmp/compute_number))
for ((i=1;i<=$number;i++))
do
compute $i;
done
for ((i=1;i<=$number;i++))
do 
text_compute $i;
done
for ((i=1;i<=$number;i++))
do
add_text $i;
done
for ((i=1;i<=$number;i++))
do
compute_ip_sum $i;
done
for ((i=1;i<=$number;i++))
do
sum_up $i;
done
for ((i=1;i<=$number;i++))
do
sum $i;
done
finish;

