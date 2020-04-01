#红色部分根据自己的需求来定义
#!/bin/bash
#卸载系统自带的Mysql
/bin/rpm -e $(/bin/rpm -qa | grep mysql|xargs) --nodeps
/bin/rm -f /etc/my.cnf
  
#安装编译代码需要的包
/usr/bin/yum -y install make gcc-c++ cmake bison-devel ncurses-devel
  
#编译安装mysql5.6
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -M -s /sbin/nologin
#转到/usr/local/src下 
cd /usr/local/src #或是直接把tar包放在该目录下
#wget -c http://ftp.ntu.edu.tw/MySQL/Downloads/MySQL-5.6/mysql-5.6.36.tar.gz（此处填写正确的链接）
/bin/tar -zxvf mysql-5.6.31.tar.gz
cd mysql-5.6.31/
/usr/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DSYSCONFDIR=/etc -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci
make && make install
  
#修改/usr/local/mysql权限
mkdir -p /usr/local/mysql/data
/bin/chown -R mysql:mysql /usr/local/mysql
/bin/chown -R mysql:mysql /usr/local/mysql/data
  
#执行初始化配置脚本，创建系统自带的数据库和表
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
  
#配置my.cnf
cat > /usr/local/mysql/my.cnf << EOF
[client]
port = 3306
socket = /usr/local/mysql/mysql.sock
  
[mysqld]
port = 3306
socket = /usr/local/mysql/mysql.sock
  
basedir = /usr/local/mysql/
datadir = /usr/local/mysql/data
pid-file = /usr/local/mysql/data/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1
sync_binlog=1
log_bin = mysql-bin
  
skip-name-resolve
#skip-networking
back_log = 600
  
max_connections = 3000
max_connect_errors = 3000
##open_files_limit = 65535
table_open_cache = 512
max_allowed_packet = 16M
binlog_cache_size = 16M
max_heap_table_size = 16M
tmp_table_size = 256M
  
read_buffer_size = 1024M
read_rnd_buffer_size = 1024M
sort_buffer_size = 1024M
join_buffer_size = 1024M
key_buffer_size = 8192M
  
thread_cache_size = 8
  
query_cache_size = 512M
query_cache_limit = 1024M
  
ft_min_word_len = 4
  
binlog_format = mixed
expire_logs_days = 30
  
log_error = /usr/local/mysql/data/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /usr/local/mysql/data/mysql-slow.log
  
performance_schema = 0
explicit_defaults_for_timestamp
  
##lower_case_table_names = 1
  
skip-external-locking
  
default_storage_engine = InnoDB
##default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 1024M
innodb_write_io_threads = 1000
innodb_read_io_threads = 1000
innodb_thread_concurrency = 8
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 4M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
  
bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
  
interactive_timeout = 28800
wait_timeout = 28800
  
[mysqldump]
quick
max_allowed_packet = 16M
  
[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
  
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
port = 3306
EOF
  
#启动mysql服务
cd /usr/local/mysql
/bin/mkdir var
/bin/chown -R mysql.mysql var
cp support-files/mysql.server /etc/init.d/mysql
/sbin/chkconfig mysql on
service mysql start
  
#设置环境变量
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
  
#设置mysql登陆密码,初始密码为123456
/bin/mkdir -p /var/lib/mysql
ln -s /usr/local/mysql/mysql.sock /var/lib/mysql/mysql.sock
mysql -e "SET PASSWORD = PASSWORD('123456');"
mysql -p123456 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"
mysql -p123456 -e "FLUSH PRIVILEGES;"