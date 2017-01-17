#!/bin/bash
set -e

echo "Disable Transparent Huge Paging"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

#jps_tokudb_admin --enable -uroot -pdbpas
#service mysql restart
#mysql --user=root --password=dbpass -e "update mysql.user set password=null where User='root';";  exit 0
#mysql --user=root --password=dbpass -e "flush privileges;";  exit 0

service mysql start && tail -F /var/log/mysql/error.log
