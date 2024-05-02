**MySQL Backup**: Using MySQL Shell

This is a quick script that uses MySQL Shell instead of mysqldump to generate a backup, on disk, and use internal tables for backup status control.
OUTPUT: A single tarred & gzipped file.

This could easily be customized to run / stream backups to (any) cloud, for example, for OCI -> https://blogs.oracle.com/mysql/post/a-step-by-step-guide-to-take-your-mysql-instance-to-the-cloud.

Steps:
1.  Execute mysql_backup_initial.sh with your db and password.
    - Create the bkup user and perms and create the internal db schema and tables.
2.  Modify mysql_backup.sh to your liking:
    - Uses --login-path instead of user/pass
    - Will always connect to a Secondary instance
    - You can use DryRun mode or not. Uncomment as needed.
    - Meant for an InnoDB Cluster setup with GIPK
    - Compresses and tars at the end
3.  Execute mysql_backup.sh and check internal schema tables to see status.

Far from being the perfect backup script for mysqlsh but hopefully points someone in the right direction.

If you're looking for a complete instance backup'n'restore quick solution, don't over complicate and look at [mysql_clone](https://dev.mysql.com/doc/refman/8.0/en/clone-plugin.html).

ToDo:
 - Restore script: per db, per instance, etc.

**Restore:**
For a restore scenario, from a **mysqldump** format [from here](https://gist.github.com/lon-io/9067f746cd8cce10af4c52179c7e9b7e) I've added some restore scenarios (All db's, per-DB & From Pre2Pro) in mysqldump_backup_restore.tar that work on files with the naming convention of "db_name.hostname.domain.DD-MM-YYYY_HHMM".
