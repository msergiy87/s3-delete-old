# s3-delete-old
Create mongodb dump and compress weekly and daily backups.
Cp dump to the S3 bucket.
Cleanup old backups at the S3 bucket.
Delete daily backups older than X days.

Requirements
------------
- mongodump
- aws s3

Distros tested
------------
Currently, this is only tested on ubuntu 14.04. It should theoretically work on older versions of Ubuntu or Debian based systems.

Usage
------------
```shell
./delete_old.sh
```
