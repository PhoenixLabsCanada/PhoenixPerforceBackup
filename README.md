# PerforceRsyncBackupScripts

creates a checkpoint and backs up your perforce depots to an offsite location via rsync. 

Reqires a config.sh file that contains the following variables:
```
  DEPOTDIR=/location/of/your/depot/files/
  METADATADIR=/location/of/your/db/files/
  JOURNALDIR=/location/of/your/journal/file/
  BACKUPDIR=/directory/
  LOGFILE=/where/the/p4d/log/file/lives/p4d.log
  P4=/usr/bin/p4
  P4HOST=localhost:1666
  P4USER=p4user
  P4PASSWORD=p4password
  DAYSTOKEEP=5
  BACKUPSERVER="user@someaddress.someplace.com"
  P4VERIFYOUT=/opt/perforce/backup/P4D-Remote-Backup.log
  ERRORRECIPIENT="list@of.email, addresses@someaddress.com"
```
