#!/bin/bash
DATE=$(date +%F)
mkdir -p /home/backups
mysqldump --defaults-extra-file=/scripts/.my.cnf blogdb > /home/backups/blogdb_$DATE.sql
