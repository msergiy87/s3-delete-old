#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH
#set -x

DUMP_DIR="/tmp/dump"
COMPRESS_DIR="/tmp/zip"
S3BUCKET="fallsbackup"
cdata=$(date +%d-%m-%Y)

# Number of days to store backup
OLDER_DATE="7 days"
CUR_DATE=$(date +%u)

# Specify the day of the week you want to create weekly backup
WEEKLY_BACKUP_DATE="7"

mkdir "$DUMP_DIR"
mkdir "$COMPRESS_DIR"
mongodump --out "$DUMP_DIR" -u backupadmin -p 'PASSWD' --authenticationDatabase admin

if [[ "$WEEKLY_BACKUP_DATE" -eq "$CUR_DATE" ]]		# if equal, success
then
	tar -zcvf "$COMPRESS_DIR"/MongoBackUp-"$cdata"-weekly.tar.gz "$DUMP_DIR"
	/usr/bin/aws s3 cp "$COMPRESS_DIR/MongoBackUp-$cdata-weekly.tar.gz" s3://"$S3BUCKET"
else
	tar -zcvf "$COMPRESS_DIR"/MongoBackUp-"$cdata"-daily.tar.gz "$DUMP_DIR"
	/usr/bin/aws s3 cp "$COMPRESS_DIR/MongoBackUp-$cdata-daily.tar.gz" s3://"$S3BUCKET"
fi

rm -R "$DUMP_DIR"
rm -R "$COMPRESS_DIR"

# Cleanup old backups
aws s3 ls s3://"$S3BUCKET" | while read -r line;

do
	file_info=$(echo "$line"|awk '{print $1" "$2}')
	createDate=$(date -d"$file_info" +%s)		# date file in unix time
	olderThan=$(date -d"-$OLDER_DATE" +%s)		# older date delete in unix time

	if [[ "$createDate" -lt "$olderThan" ]]		# less than
	then
		fileName=$(echo "$line"|awk '{print $4}')
		echo "$fileName"

		if [[ "$fileName" != "" ]]
		then
			echo "$fileName" | grep "daily" > /dev/null 2>&1
			if [ $? -eq 0 ]			# if equal, success
			then
				aws s3 rm s3://"$S3BUCKET"/"$fileName"
			fi
		fi
	fi
done
