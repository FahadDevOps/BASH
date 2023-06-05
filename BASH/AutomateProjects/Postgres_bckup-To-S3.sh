#!/bin/bash

##########################################################################
###               Postgres Time & Log Details
##########################################################################

TIME_FORMAT='%d%m%Y-%H%M'
cTime=$(date +%Y-%m-%d_%Hh%Mm)
date=$(date '+%Y-%m-%d')
LOG_PATH=/backup/dbPostgres.log
VERBOSE=1         ### VERBOSE mode 0=disable, 1=enable

##########################################################################
###               Postgres Database Server Details
##########################################################################
USER=""
PASS=""
HOST=""
PORT="5432"
##########################################################################
###      Local Database Backup Path
##########################################################################

LOCAL_BACKUP_DIR=/backup/database
TMP_PATH=/tmp
BACKUP_RETAIN_DAYS=1   ## Number of days to keep local backup copy

##########################################################################
###               Postgres Databases Names to Backup
##########################################################################

# Type ALL or specifiy space seprated names. Use one of below settings

DB_NAMES="ALL"                             ### Backup all user databases
#DB_NAMES="dbname1 dbname2 dbname3"    ### Backup specified databases only

##########################################################################
###     Enable Amazon S3 Backup
##########################################################################

S3_ENABLE=1              # 0=disable, 1=enable
#AWS_ACCESS_KEY="***"
#AWS_SECRET_ACCESS_KEY="***"
S3_BUCKET_NAME=""
S3_UPLOAD_LOCATION="Database/FolderName"   ## Do not use start and end slash
ENCRYPT=1
PASSPHRASE=

##########################################################################
###      Local Executables Path
##########################################################################

GZIP="/bin/gzip"
RM="/bin/rm"
MKDIR="/bin/mkdir"
GREP="/bin/grep"
S3CMD="/usr/local/bin/s3cmd"
GPG="/usr/bin/gpg"


##########################################################################
###      Enable Email Alerts
##########################################################################

#SENDEMAIL= ( 0 for not to send email, 1 for send email )
SENDEMAIL=0
EMAILTO='name@email.com'


echo "" > ${LOG_PATH}
echo "<<<<<<   Database Dump Report :: `date +%D`  >>>>>>" >> ${LOG_PATH}
echo "" >> ${LOG_PATH}
echo "DB Name  :: DB Size   Filename" >> ${LOG_PATH}

### Make a backup ###

db_backup(){

        if [ "$DB_NAMES" == "ALL" ]; then
        DATABASES=`PGPASSWORD=$PASS psql -l -h$HOST -p$PORT -U$USER -w | awk '{print $1}' | grep -v "+" | grep -v "Name" | grep -v "List" | grep -v "(" | grep -v "template" | grep -v "postgres" | grep -v "rdsadmin" | grep -v "|" | grep -v "|"` > $LOG_PATH 
        else
                DATABASES=$DB_NAMES
        fi

        db=""
        [ ! -d $BACKUPDIR ] && ${MKDIR} -p $BACKUPDIR
                [ $VERBOSE -eq 1 ] && echo "*** Dumping PostgresSQL Database ***" >> ${LOG_PATH}
                mkdir -p ${LOCAL_BACKUP_DIR}/${date}
        
        for db in $DATABASES
        do
                FILE_NAME="${db}.${cTime}.gz"
                FILE_PATH="${LOCAL_BACKUP_DIR}/${date}/"
                FILENAMEPATH="$FILE_PATH$FILE_NAME"
                [ $VERBOSE -eq 1 ] && echo -en "Database> $db... \n" >> ${LOG_PATH}
                PGPASSWORD=$PASS pg_dump -h $HOST -U $USER -w $db | ${GZIP} -9  > $FILENAMEPATH
                echo "$db   :: `du -sh ${FILENAMEPATH}`"  >> ${LOG_PATH}
                                echo "Encrypting Backup"  >> ${LOG_PATH}
                                gpg --yes --batch --cipher-algo AES256  --passphrase=${PASSPHRASE} -c "$FILENAMEPATH"
                                echo "Encryption Done..."  >> ${LOG_PATH}
                                rm -rf  "$FILENAMEPATH"
                                echo "Removed plain backup" >> ${LOG_PATH}
                [ $S3_ENABLE -eq 1 ] && s3_backup
        done
        [ $VERBOSE -eq 1 ] && echo "*** Backup completed ***" >> ${LOG_PATH}
        [ $VERBOSE -eq 1 ] && echo "*** Check backup files in ${FILE_PATH} ***" >> ${LOG_PATH}


}

### close_on_error on demand with message ###
close_on_error(){
        echo "$@"
        exit 99
}

### Make sure bins exists.. else close_on_error
check_cmds(){
        [ ! -x $GZIP ] && close_on_error "FILENAME $GZIP does not exists. Make sure path is correct."
        [ ! -x $RM ] && close_on_error "FILENAME $RM does not exists. Make sure path is correct."
        [ ! -x $MKDIR ] && close_on_error "FILENAME $MKDIR does not exists. Make sure path is correct."
        [ ! -x $GREP ] && close_on_error "FILENAME $GREP does not exists. Make sure path is correct."
        if [ $S3_ENABLE -eq 1 ]; then
                [ ! -x $S3CMD ] && close_on_error "FILENAME $S3CMD does not exists. Make sure path is correct."
        fi
}

### Make sure we can connect to server ...
check_postgres_connection(){
   #      pg_isready -d <db_name> -h <host_name> -p <port_number> -U <db_user>
      [ $? -eq 0 ] || close_on_error "Error: Cannot connect to Postgres Server. Make sure username and password setup correctly"
}

s3_backup(){
        [ $VERBOSE -eq 1 ] && echo "Uploading backup file to S3 Bucket" >> ${LOG_PATH}
        cd ${FILE_PATH}
        $S3CMD put "$FILE_NAME.gpg" s3://${S3_BUCKET_NAME}/${S3_UPLOAD_LOCATION}/${date}/ >> ${LOG_PATH} 
}

send_report(){
        if [ $SENDEMAIL -eq 1 ]
        then
                cat ${LOG_PATH} | mail -vs "Database dump report for `date +%D`" ${EMAILTO}
        fi
}

delete_old_backups(){
  echo "Deleting $LOCAL_BACKUP_DIR/*.*.gz older than $BACKUP_RETAIN_DAYS days" >> ${LOG_PATH}
  find $LOCAL_BACKUP_DIR/* -type d -ctime +$BACKUP_RETAIN_DAYS -exec rm -rf {} \;
}

### main ####
check_cmds
#check_postgres_connection
db_backup
send_report
delete_old_backups
