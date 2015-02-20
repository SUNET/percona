#!/bin/sh

if [ "x${CLUSTER_NAME}" = "x" ]; then
   CLUSTER_NAME="mypxc"
fi

cat>/etc/mysql/my.cnf<<EOF
[MYSQLD]
user = mysql
default_storage_engine = InnoDB
basedir = /usr
datadir = /var/lib/mysql
socket = /var/run/mysqld/mysqld.sock
port = 3306
innodb_autoinc_lock_mode = 2
log_queries_not_using_indexes = 1
max_allowed_packet = 128M
binlog_format = ROW
wsrep_provider = /usr/lib/libgalera_smm.so
wsrep_node_address = ${CLUSTER_NODE_IP}
wsrep_cluster_name="${CLUSTER_NAME}"
wsrep_cluster_address = gcomm://${CLUSTER_NODES}
wsrep_node_name = ${CLUSTER_NODE_NAME}
wsrep_slave_threads = 4
wsrep_sst_method = xtrabackup-v2
wsrep_sst_auth = sstuser:${CLUSTER_SECRET}
[sst]
streamfmt = xbstream
[xtrabackup]
compress
compact
parallel = 2
compress_threads = 2
rebuild_threads = 2
EOF

case "$*" in
   bash)
      bash
   ;;
   start)
      mysqld_safe
   ;;
   bootstrap)
      /etc/init.d/mysql bootstrap-pxc
      sleep 5
      mysql<<EOF
CREATE USER 'sstuser'@'localhost' IDENTIFIED BY '${CLUSTER_SECRET}';
GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';
FLUSH PRIVILEGES;
EOF
   ;;
esac
