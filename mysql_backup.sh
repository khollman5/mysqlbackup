#!/bin/bash

DATE=`date "+%Y%m%d%H%M%S"`
BKUPBASEDIR=/mnt/backup/db-backup
DIR=$BKUPBASEDIR/$DATE

cd $BKUPBASEDIR
echo "Start of backup `date`" > mysql_backup_$DATE.log

# Backup starting, hence insert a control row:
mysqlsh --login-path=backup -hdbgsc-d-rtdb-01  --sql -D internal << EoF >> mysql_backup_$DATE.log
 insert into backup_log_history (bkstart,bkend,bktype,bksuccess) select bkstart,bkend,bktype,bksuccess from backup_log;
 truncate table backup_log;
 insert into backup_log (bkstart,bkend,bktype,bksuccess) values (CURRENT_TIMESTAMP,NULL,'DI','N');
# test:
 select bkid into @bkid from backup_log where bksuccess='N' and datediff(date_format(curdate(),'%Y-%m-%d %H'),date_format(bkstart,'%Y-%m-%d %H'))<24;
 select * from backup_log where bkid=@bkid
EoF

# Execute backup:
#echo "Dry run enabled" >> mysql_backup_$DATE.log
#mysqlsh --login-path=backup -hdbgsc-d-rtdb-01 --nw --redirect-secondary -- util dump-instance "$DIR" --consistent=true --dryRun=true --showProgress=true --dialect='csv' --threads=6 --chunking=true --excludeUsers=['root','icadmin','routerAdmin'] --excludeSchemas=['mysql_innodb_cluster_metadata'] --compatibility='create_invisible_pks','strip_invalid_grants' >> mysql_backup_$DATE.log
# touch $DIR
echo "Dry run disabled" >> mysql_backup_$DATE.log
mysqlsh --login-path=backup -hdbgsc-d-rtdb-01 --nw --redirect-secondary -- util dump-instance "$DIR" --consistent=true --dryRun=false --showProgress=true --dialect='csv' --threads=6 --chunking=true --excludeUsers=['root','icadmin','routerAdmin'] --excludeSchemas=['mysql_innodb_cluster_metadata'] --compatibility='create_invisible_pks','strip_invalid_grants' >> mysql_backup_$DATE.log

echo “Compress and tar backup directory:” >> mysql_backup_$DATE.log
cd $BKUPBASEDIR
tar cvfz $BKUPBASEDIR/$DATE.tar.gz $DATE

# Backup finishing, hence update the status in the database table:
echo “Updating backup_log table:” >> mysql_backup_$DATE.log
mysqlsh --login-path=backup -hdbgsc-d-rtdb-01 --sqlc -D internal >> mysql_backup_$DATE.log << EOF >> mysql_backup_$DATE.log
 update backup_log t1 left join backup_log t2 on t2.bkid=t1.bkid set t1.bkend=CURRENT_TIMESTAMP,t1.bksuccess='Y' where t1.bksuccess='N' and datediff(date_format(curdate(),'%Y-%m-%d %H'),date_format(t1.bkstart,'%Y-%m-%d %H'))<24;
 select * from backup_log;
EOF

echo "End of backup `date`" >> mysql_backup_$DATE.log


