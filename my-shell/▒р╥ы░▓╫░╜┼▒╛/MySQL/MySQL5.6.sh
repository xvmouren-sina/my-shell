#��ɫ���ָ����Լ�������������
#!/bin/bash
#ж��ϵͳ�Դ���Mysql
/bin/rpm -e $(/bin/rpm -qa | grep mysql|xargs) --nodeps
/bin/rm -f /etc/my.cnf
  
#��װ���������Ҫ�İ�
/usr/bin/yum -y install make gcc-c++ cmake bison-devel ncurses-devel
  
#���밲װmysql5.6
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -M -s /sbin/nologin
#ת��/usr/local/src�� 
cd /usr/local/src #����ֱ�Ӱ�tar�����ڸ�Ŀ¼��
#wget -c http://ftp.ntu.edu.tw/MySQL/Downloads/MySQL-5.6/mysql-5.6.36.tar.gz���˴���д��ȷ�����ӣ�
/bin/tar -zxvf mysql-5.6.31.tar.gz
cd mysql-5.6.31/
/usr/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DSYSCONFDIR=/etc -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci
make && make install
  
#�޸�/usr/local/mysqlȨ��
mkdir -p /usr/local/mysql/data
/bin/chown -R mysql:mysql /usr/local/mysql
/bin/chown -R mysql:mysql /usr/local/mysql/data
  
#ִ�г�ʼ�����ýű�������ϵͳ�Դ������ݿ�ͱ�
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
  
#����my.cnf
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
  
#����mysql����
cd /usr/local/mysql
/bin/mkdir var
/bin/chown -R mysql.mysql var
cp support-files/mysql.server /etc/init.d/mysql
/sbin/chkconfig mysql on
service mysql start
  
#���û�������
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
  
#����mysql��½����,��ʼ����Ϊ123456
/bin/mkdir -p /var/lib/mysql
ln -s /usr/local/mysql/mysql.sock /var/lib/mysql/mysql.sock
mysql -e "SET PASSWORD = PASSWORD('123456');"
mysql -p123456 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"
mysql -p123456 -e "FLUSH PRIVILEGES;"