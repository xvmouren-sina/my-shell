 #!/bin/bash
        #
        VIP=192.168.10.3	#集群虚拟IP
        CPORT=80	#定义集群端口
        FAIL_BACK=127.0.0.1	#本机回环地址
        RS=("192.168.10.7" "192.168.10.8")	#编写集群地址
        declare -a RSSTATUS  #变量RSSTATUS定义为数组态
        RW=("2" "1")
        RPORT=80	#定义集群端口
        TYPE=g	#制定LVS工作模式：g=DR m=NAT
        CHKLOOP=3
        LOG=/var/log/ipvsmonitor.log
        addrs() {
          ipvsadm -a -t $VIP:$CPORT -r $1:$RPORT -$TYPE -w $2
          [ $? -eq 0 ] && return 0 || return 1
        }
        delrs() {
          ipvsadm -d -t $VIP:$CPORT -r $1:$RPORT
          [ $? -eq 0 ] && return 0 || return 1
        }
        checkrs() {
          local I=1
          while [ $I -le $CHKLOOP ]; do
            if curl --connect-timeout 1 http://$1 &> /dev/null; then
              return 0
            fi
            let I++
          done
          return 1
        }
        initstatus() {
          local I
          local COUNT=0;
          for I in ${RS[*]}; do
            if ipvsadm -L -n | grep "$I:$RPORT" && > /dev/null ; then
              RSSTATUS[$COUNT]=1
            else
              RSSTATUS[$COUNT]=0
            fi
          let COUNT++
          done
        }
        initstatus
        while :; do
          let COUNT=0
          for I in ${RS[*]}; do
            if checkrs $I; then
              if [ ${RSSTATUS[$COUNT]} -eq 0 ]; then
                 addrs $I ${RW[$COUNT]}
                 [ $? -eq 0 ] && RSSTATUS[$COUNT]=1 && echo "`date +'%F %H:%M:%S'`, $I is back." >> $LOG
              fi
            else
              if [ ${RSSTATUS[$COUNT]} -eq 1 ]; then
                 delrs $I
                 [ $? -eq 0 ] && RSSTATUS[$COUNT]=0 && echo "`date +'%F %H:%M:%S'`, $I is gone." >> $LOG
              fi
            fi
            let COUNT++
          done
          sleep 5
        done