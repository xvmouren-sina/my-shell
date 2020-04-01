#!/bin/bash
#需要先在/etc/hosts下写好主机IP解析

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
	2)  #获取一个 IP或者hosts下的解析名
		read -p "^-^:" host
		#[[ $host =~ ^[a-zA-Z] ]] && CONTINUE
		if [[ $host =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
			flag=(`awk -F "." '{a=2;for(i=1;i<5;i++)if($i>255)if($i<0)a=1;print a}' <<< $host`)
			[ $flag == "1" ] && echo "你输入的IP: $host 不合法，请重新输入！" && CONTINUE
		else
			echo "你输入的IP: $host 不合法，请重新输入！" && CONTINUE
		fi
	;;
	esac
}
##############^^^^^^^^^^^^输入控制^^^^^^^^^^^^^^^^#################

echo "你要配置几台node："
READ_GET 1
echo "主机IP"
for i in `seq $number`;do
	READ_GET 2	
	eval node$i=$host	
	node_hosts=$node_hosts"\"$host\"",
done
node_hosts=${node_hosts%%,}

sh CA.sh





