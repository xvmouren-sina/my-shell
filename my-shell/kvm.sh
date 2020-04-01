#!/bin/bash

##vhost_array:用于存储所有的虚拟机名
vhost_array=(`virsh list --all |awk 'NR>2{printf $2" "}'`) 

#######vvvvvvvvvvvvvvv输入控制函数（不完善）vvvvvvvvvvvvvvv########
CONTINUE() { 
    read -p "按Enter继续" enter;[ -z $enter ] && continue
}

QUIT() { #退出字符控制
	if [ -n "$1" ];then
		[ $1 == "q" ] || [ $1 == "quit" ] || [ $1 == "exit" ] && break 
		[ $1 == "QQ" ] && exit 0
	fi
}

READ_GET() { #read命令基础上添加一些判断
	case $1 in
	1) #获取一个输入 数字 并判断是否合法
		read -p "^-^:" number
		[ -z "$number" ] && echo "不能为空！" && CONTINUE
		QUIT $number
		[[ $number =~ [^0-9] ]] && [ $number != "q" ] && [ $number != "quit" ] &&  [ $number != "exit" ] && echo "只能输入数字和退出字符！" && CONTINUE
	;;
	2)  #简单获取一个 输入值
		read -p "请输入主机名：" vm_name
		QUIT $vm_name
		[ -z "$vm_name" ] && echo "不能为空！" && CONTINUE
	;;
	3)  #传入显示的字符串，返回不为空的 输入数据
		read -p "$2:" string
		QUIT $string
		[ -z $string ] && echo "不能为空！" && CONTINUE
		eval $3="$string"
	;;
	4)  #同3，但可以为空
		read -p "$2:" string
		QUIT "$string"
		eval $3="$string"
	;;
	5)  #判断IP，同3
		read -p "$2(eg:192.168.1.1):" ip
		QUIT $ip
        [ -z $ip ] && echo "不能为空！" && CONTINUE
		if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
			flag=(`awk -F "." '{a=2;for(i=1;i<5;i++)if($i>255)if($i<0)a=1;print a}' <<< $ip`)
			[ $flag == "1" ] && echo "你输入的IP: $ip 不合法，请重新输入！" && CONTINUE
			eval $3=$ip
		else
			echo "你输入的IP: $ip 不合法，请重新输入！" && CONTINUE
		fi
	esac
}
##############^^^^^^^^^^^^输入控制^^^^^^^^^^^^^^^^#################

#########vvvvvvvvvvvvvvvvv菜单选项 副本函数vvvvvvvvvvvvvvvvv#############
ADD_VM_S() { #添加虚拟机时常用属性
	READ_GET 3 "要创建的主机名" vm_name
	READ_GET 3 "内存大小(单位：M)" memory
	READ_GET 4 "磁盘路径(空为默认：/var/lib/libvirt/images/"$vm_name".qcow2)" disk_dir
	if [ -z "$disk_dir" ] ;then 
		disk_dir=/var/lib/libvirt/images/"$vm_name".qcow2
	elif [ -d "$disk_dir" ] ; then
		disk_dir=$disk_dir"/"$vm_name.qcow2""
	fi
	READ_GET 3 "磁盘大小（单位：G）"  disk_size
}

ADD_SNAP_S() {
	READ_GET 2
	! virsh dominfo $vm_name &>/dev/null && echo "虚拟机"$vm_name"不存在！" && CONTINUE
	if [ -n "$1" ];then
		READ_GET 3 "快照名" snap_name
		[ "$1" == "2" ] &&  virsh snapshot-dumpxml $vm_name $snap_name &>/dev/null && echo "$snap_name快照已存在" && CONTINUE
		[ "$1" == "3" ] &&  ! virsh snapshot-dumpxml $vm_name $snap_name &>/dev/null && echo "$snap_name不存在" && CONTINUE
	fi
	vm_name=$vm_name
}

#######^^^^^^^^^^^^^^^^副本^^^^^^^^^^^^^^^#############

#######vvvvvvvvvvvvvvvv菜单选项函数vvvvvvvvvvvvvvvvvvv#############
CON_VM() {
	echo "
	 #####vvvvvvvvvvv连接虚拟机vvvvvvvvvvvvvvvv#####
	 输入对应的数字选择功能（退出脚本‘QQ’）：
		1.使用console连接
		2.使用ssh连接
		q|quit|exit.返回至主菜单
	 #####^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^^#####"
	READ_GET 1
	case $number in
		"1")
			READ_GET 2
			virsh console $vm_name
			exit 0;;
		"2")
			READ_GET 3 "请输入主机IP" "vm_ip"
			ssh $vm_ip;;
	esac
}

MANAGE_VM() {
while true;do
	echo "
	 ####vvvvvvvvvvvvvv管理虚拟机vvvvvvvvvvvvvvvv#####
	 输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.启动虚拟机
		2.关闭虚拟机
		3.挂起虚拟机
		4.从挂起状态恢复虚拟机
		5.重启虚拟机
		6.重置虚拟机
		7.删除虚拟机
		8.为虚拟机添加console
		q|quit|exit.返回至主菜单
        主机：主机名...|（'--all' 所有的虚拟机）
	 #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^#####"
	READ_GET 1 2
	READ_GET 2
    MANAGERS() {
	case $number in
		1)
			virsh start $1;;
		2)
			virsh destroy $1;;
		3)
			virsh suspend $1;;
		4)
			virsh resume $1;;
		5)
			virsh reboot $1;;
		6)
			virsh reset $1;;
		7)
			virsh undefine $1;;
		8)
			echo "手动添加吧！"
	esac
	}
	[ "$vm_name" != "--all" ] && MANAGERS $vm_name
	[ "$vm_name" == "--all" ] && for i in ${vhost_array[*]};do
		MANAGERS $i
	done
	CONTINUE
done
}

LOOK_INFO() {
while true ;do
	echo "
	 ####vvvvvvvvvv信息大全（不全）vvvvvvvvvvvvvvv#####
	 输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.查看配置信息
		2.查看配置文件
		3.查看磁盘文件
		4.查看虚拟机网络配置文件
		5.列出所有的虚拟机
		6.列出所有虚拟网络
		7.列出虚拟机快照
		q|quit|exit.返回至主菜单
	  主机名：。。
	 #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^^^^####"
	READ_GET 1 2
	[[ $number =~ [^5-7] ]] && READ_GET 2
	case $number in
		1)
			virsh dominfo $vm_name;;
		2)
			virsh dumpxml $vm_name;;
		3)
			virsh domblklist $vm_name;;
		4)
			virsh net-dumpxml $vm_name;;
		5)
			virsh list --all;;
		6)
			virsh net-list --all;;
		7)
			virsh snapshot-list $vm_name;;
	esac
	CONTINUE
done
}

ADD_VM() {
while true ;do
	echo "
	 #####vvvvvvvvvvvvv添加虚拟机vvvvvvvvvvvvvv######
	 输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.完整克隆
		2.链接克隆
		3.cp磁盘复制
		4.命令安装
		5.PXE
	    q|quit|exit.返回至主菜单
	 #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^######"
	READ_GET 1 2
	case $number in
		1)
			echo "输入你要创建虚拟机的属性"
			READ_GET 3 "克隆哪台虚拟机" vm_who
			virsh dominfo $vm_who &>/dev/null ||echo ""$vm_who"不存在！ `continue`"
			READ_GET 3 "克隆机名" clone_name
			virsh dominfo $clone_name &>/dev/null && echo ""$clone_name"已经存在了！ `continue`"
			READ_GET 4 "生成的磁盘文件放哪（默认：/var/lib/libvirt/"$clone_name".img）" img_dir
			[ -z "$img_dir" ] && img_dir=/var/lib/libvirt/"$clone_name".img
			virt-clone -o $vm_who -n $clone_name -f $img_dir
			;;
		2)
			echo "先放你一马"	;;
		3)
			echo "先放你二马"   ;;
		4)
			echo "输入你要创建虚拟机的属性"
			ADD_VM_S
			READ_GET 3 "CPU个数" cpus
			READ_GET 3 "安装源" iso_dir
			READ_GET 4 "网络连接方式 默认NAT（1：NAT），（2：桥接）" conn_type
			READ_GET 4 "网络名称 默认（defalut）" net
			read -p "其它功能自行添加（--option ...）" other
			if [ -z "$conn_type" ] || [ "$conn_type" == "1" ];then
				conn_type="network"
			elif [ "$conn_type" == "2" ];then
				conn_type="bridege"
			fi 
			[ -z "$net" ] && net="default"
			virt-install -n $vm_name --memory $memory --vcpus $cpus --cdrom $iso_dir --disk "$disk_dir",size=10,format=qcow2,bus=scsi --network "$conn_type"="$net"  -x console=ttyS0 $other
			;;
		5)
			echo "PXE环境没写，太难了！"
			ADD_VM_S
			read -p "其它功能自行添加（--option ...）" other
			virt-install -n $vm_name --memory $memory --pxe --disk="$disk_dir",size="$disk_size",--format=qcow2 -x console=ttyS0 $other
	esac
	CONTINUE
done
}

VM_SNAPSHOT() {
while true ;do
    echo "
     #####vvvvvvvvvvvvv快照vvvvvvvvvvvvvv######
     输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.查看domaim已有的快照
		2.创建快照
		3.查看快照详情
		4.使用快照恢复虚拟机
		5.删除指定快照
		q|quit|exit.返回至主菜单
     #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^######"
	READ_GET 1
	case $number in
		1)
			ADD_SNAP_S
			virsh snapshot-list $vm_name && CONTINUE;;
		2)
			ADD_SNAP_S 2
			virsh snapshot-create-as $vm_name $snap_name && CONTINUE;;
		3)
			ADD_SNAP_S 3
            virsh snapshot-dumpxml $vm_name $snap_name && CONTINUE;;
		4)
			ADD_SNAP_S 3
			virsh destroy $vm_name
			virsh snapshot-revert $vm_name $snap_name && CONTINUE;;
		5)
			ADD_SNAP_S 3
			virsh snapshot-delete $vm_name $snap_name && CONTINUE
	esac
done
}

VM_STORAGE() {
while true ;do
    echo "
     #####vvvvvvvvvvvvv存储管理vvvvvvvvvvvvvv######
     输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.创建存储池
		2.查看以定义的存储池
		3.激活并启动存储池
		4.创建存储卷
		5.查看存储卷
		6.取消激活存储池
		7.取消定义存储池
        q|quit|exit.返回至主菜单
     #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^######"
	READ_GET 1
	case $number in
		1)
			READ_GET 3 "存储池名" pool_name
			READ_GET 3 "存储池的目录" pool_dir
			virsh pool-define-as $disk_name --type dir --targer $pool_dir;;
		2)
			virsh pool-list --all;;
		3)
			READ_GET 3 "存储池名" pool_name
			virsh pool-start $pool_name
			virsh pool-autostart $pool_name;;
		4)
			echo "选择方法 1：virsh命令；2：qemu命令"
			READ_GET 1
			READ_GET 3 "存储卷名" volume_name
			READ_GET 3 "存储卷大小（单位：G）" volume_size
			if [ "$number" == "1" ];then
				READ_GET 3 "存储池名" pool_name
				virsh vol-create-as $pool_name "$volume_name".qcow2 "$volume_size"G --format qcow2
			elif [ "$number" == "2" ];then
				READ_GET 4 "存储卷路径（默认：/var/lib/libvirt/images/）" volume_dir
				[ -z "$volume_dir" ] && volume_dir=/var/lib/libvirt/images/
				qemu-img create -f qcow2 $volume_dir"$volume_name".qcow2 "$volume_size"G
			fi;;
		5)
			READ_GET 3 "存储卷名" volume_name
			virsh vol-list vmdisk;;
		6)
			READ_GET 3 "存储池名" pool_name
			virsh pool-destroy $pool_name;;
		7)
			READ_GET 3 "存储池名" pool_name
			virsh pool-undefine $pool_name
	esac
done
}

VM_NETWORK() {
while true ;do
    echo "
     #####vvvvvvvvvvvvv网络管理vvvvvvvvvvvvvv######
     输入对应的提示符选择功能（退出脚本‘QQ’）：
		1.将**网络的dhcp关闭
		2.将**网络的dhcp开启
		3.关闭**网络
		4.开启**网络
		5.重启**网络
		6.创建一个网桥
		q|quit|exit.返回至主菜单
     #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^######"
    READ_GET 1
    case $number in
        1)
			echo "暂无该功能";;
		2)
            echo "暂无该功能";;
		3)
			READ_GET 3 "要关闭的网络名(eg:default)" net_name
			virsh net-destroy $net_name && echo "网络 $net_name 已关闭" || echo "网络 $net_name 关闭失败";CONTINUE ;;
		4)
			READ_GET 3 "要开启的网络名(eg:default)" net_name
            virsh net-start $net_name && echo "网络 $net_name 已开启" || echo "网络 $net_name 开启失败";CONTINUE ;;
		5)
			READ_GET 3 "要重启的网络名(eg:default)" net_name
			virsh net-destroy $net_name && echo "网络 $net_name 已关闭" || echo "网络 $net_name 关闭失败"
			virsh net-start $net_name && echo "网络 $net_name 已开启" || echo "网络 $net_name 开启失败";CONTINUE ;;
		6)
			echo "请输入以下配置信息"
			READ_GET 3 "要创建的网桥名" bridge_name
			card_dir="/etc/sysconfig/network-scripts/ifcfg-"
			cat $card_dir"$bridge_name" &> /dev/null && echo "$bridge_name 已存在" && CONTINUE
			READ_GET 3 "在那张网卡上的网段创建（eg:eth0）" card_name
			! cat $card_dir"$card_name" &> /dev/null && echo "$card_name 不存在" && CONTINUE
			READ_GET 5 "IPADDR" bridge_ip
			READ_GET 5 "GATEWAY" bridge_gw
			echo "
				DEVICE=$bridge_name
        		BOOTPROTO=static
        		ONBOOT=yes
        		TYPE=bridge
        		IPADDR=$bridge_ip
        		GATEWAY=$bridge_gw
        		DNS=114.114.114.114" > $card_dir"$bridge_name"
			echo "
				TYPE=Ethernet
        		BRIDGE=$bridge_name
        		BOOTPROTO=none
        		DEVICE=$card_name
        		ONBOOT=yes" > $card_dir"$card_name"
			echo "设置完成重启网络中..."
			! systemctl restart network && echo "重启失败，请手动检查并修复^-^ " && CONTINUE
			echo "设置成功 ^-^ "	
	esac
done
}

VM_HARD_MODIFY() {
while true ;do
    echo "
     #####vvvvvvvvvvvvv虚拟机硬件管理vvvvvvvvvvvvvv######
     输入对应的提示符选择功能（退出脚本‘QQ’）：
        1.修改内存
        2.修改CPU个数
        3.添加磁盘
        4.删除磁盘
        5.添加网卡
		6.删除网卡
        q|quit|exit.返回至主菜单
     #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^######"
    READ_GET 1
	echo "输入以下参数 实现对应功能"
	mode=1
	READ_GET 4 "输入 1:临时生效(重启失效)，2:永久生效；空为默认：1；" mode
	[ -z "mode" -o "mode" == "1" ] && for_ever=""
	[ "mode" == "2" ] && for_ever="--config"
	READ_GET 2
	! virsh dominfo $vm_name &>/dev/null && echo "虚拟机"$vm_name"不存在！" && CONTINUE
    case $number in
        1)
            READ_GET 3 "输入要设置的内存大小(单位:M)" mem_size
			let mem_size=$mem_size*1024
			[ -z "$mode" -o "$mode" == "1" ] && virsh setmem $vm_name $mem_size --live $for_ever && echo "内存设置成功" && CONTINUE
			echo "内存设置失败" && CONTINUE
			;;
        2)
            READ_GET 3 "输入要设置的CPU个数" cpus
            [ -z "$mode" -o "$mode" == "1" ] && virsh setmem $vm_name $cpus --live  $for_ever && echo "CPU设置成功" && CONTINUE
            echo "CPU设置失败" && CONTINUE
            ;;
		3)
			READ_GET 3 "要添加的磁盘文件名" disk_name
			READ_GET 4 "磁盘路径(空为默认：/var/lib/libvirt/images/"$disk_name".qcow2)" disk_dir
			READ_GET 3 "磁盘名(eg:sda|vda)" disk_name2
			READ_GET 3 "磁盘类型(eg:virtio)" disk_type
    		if [ -z "$disk_dir" ] ;then
    		    disk_dir=/var/lib/libvirt/images/"$disk_name".qcow2
    		elif [ -d "$disk_dir" ] ; then
    		    disk_dir=$disk_dir"/"$disk_name".qcow2"
    		fi  
    		READ_GET 3 "磁盘大小（单位：G）"  disk_size
			! qemu-img create -f qcow2 $disk_dir $disk_size"G" && echo "磁盘创建失败" && CONTINUE
			echo "
				<disk type='file' device='disk'>
    			   <driver name='$disk_name' type='qcow2'/> 
    			   <source file='$disk_dir'/> 
    			   <target dev='$disk_name2' bus='$disk_type'/>
    			</disk>" > $disk_name".xml"
			virsh attach-device $vm_name $disk_name".xml" --live $for_ever && echo "磁盘添加成功" && CONTINUE
			echo "磁盘添加失败" && CONTINUE;;
		4)
			READ_GET 3 "要删除的磁盘名" disk_name
			virsh detach-disk  $vm_name $disk_dir --live $for_ever && echo "删除磁盘成功" && CONTINUE
            echo "删除磁盘失败" && CONTINUE;;
		5)
			READ_GET 3 "要映射的网卡名" card_name
			READ_GET 4 "网络连接方式 默认桥接（1：NAT），（2：桥接）" conn_type
			if [ -z "$conn_type" ] || [ "$conn_type" == "2" ];then
                conn_type="bridge"
            elif [ "$conn_type" == "2" ];then
                conn_type="network"
            fi
			virsh attach-interface $vm_name --type $conn_type --source $card_name --model virtio --live $for_ever && echo "添加网卡成功" && CONTINUE
            echo "添加网卡失败" && CONTINUE;;
		6)
			echo "暂无该功能"
	esac
done
}
#######^^^^^^^^^^^^^^菜单选项方法^^^^^^^^^^^^#########

#######vvvvvvvvvvvvvvvvv主菜单vvvvvvvvvvvvvvv#########
while true ;do
	echo "
	 #####vvvvvvvvvvvvvv主菜单vvvvvvvvvvvvvvvvv#######
	 输入对应的数字选择功能（退出脚本‘q|quit|exit’）：	
		1.连接虚拟机
		2.管理虚拟机
		3.查看虚拟机信息
		4.添加虚拟机
		5.虚拟机快照
		6.存储
		7.网络
		8.添加|修改硬件
		9.迁移
		10.一键配置PXE
	 #####^^^^^^^^^^^^^^^END^^^^^^^^^^^^^^^^^^^^######"
	READ_GET 1
	case $number in
		"1")
			CON_VM ;;
		"2")
			MANAGE_VM ;;
		"3")
			LOOK_INFO ;;
		"4")
			ADD_VM ;;
		"5")
			VM_SNAPSHOT ;;
		"6")
			VM_STORAGE ;;
		"7")
			VM_NETWORK ;;
		"8")
			VM_HARD_MODIFY ;;
		"9")
            echo "暂无该功能" && CONTINUE ;;
		"10")
			echo "暂无该功能" && CONTINUE
	esac
done
