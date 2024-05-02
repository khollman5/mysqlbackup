#!/bin/bash

mysqlsh icadmin@dbgsc-d-rtdb-01:3306 --log-file=mysql_backup_INITIAL.log --sqlc << EOF
-- create the backup user and add basic grants:
CREATE USER 'bkup'@'%' IDENTIFIED BY 'B4ckmeup!';
GRANT SELECT, BACKUP_ADMIN, RELOAD, PROCESS, SUPER, REPLICATION CLIENT  ON *.* TO 'bkup'@'%';
GRANT SELECT ON performance_schema.replication_group_members TO 'bkup'@'%';
GRANT ALL ON *.* TO 'bkup'@'%';
flush privileges;
-- create the internal db for backup history:
create database internal; 
grant all on internal.* to 'bkup'@'%'; 
flush privileges;
-- Create the log and history tables:
use internal;
drop table if exists backup_log;
SET sql_generate_invisible_primary_key=ON;
create table backup_log (bkid INT NOT NULL AUTO_INCREMENT,bkstart timestamp not null default CURRENT_TIMESTAMP,bkend timestamp,bktype enum('DI','DS') not null default 'DI',bksuccess enum('Y','N') not null default 'N',PRIMARY KEY (bkid));
create table backup_log_history as select * from backup_log where 1=1;
-- Grant permissions on the internal tables:
GRANT CREATE, INSERT, DROP, UPDATE ON internal.backup_log TO 'bkup'@'%';
GRANT CREATE, INSERT, SELECT, DROP, UPDATE, ALTER ON internal.backup_log_history TO 'bkup'@'%';
flush privileges;
EOF

