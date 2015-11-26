#!/usr/bin/env bash
####################################
# Copyright (c) 2015 Phoenix Labs  #
# Licensed under The MIT Licensed  #
# See LICENSE for more information #
####################################

# Include a config file to house sensitive data.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/config.sh

SCRIPTNAME="[PhoenixPerforceBackup]"
LOGGER=/usr/bin/logger
TODAY=`date +%Y-%m-%d`

logs() {
        $LOGGER "$SCRIPTNAME $1"
        echo "$SCRIPTNAME $1"
}

logs "Starting backup... "
date

### Clean up old P4VERIFYOUT log

if [ -s $P4VERIFYOUT ]; then
	rm $P4VERIFYOUT
fi

### Verify the state of the depot
### THE MORE YOU KNOW: Verify checks every file in perforce and save the checksum for next time

logs "$SCRIPTNAME Verifying the depot..."

chmod a+w $BACKUPDIR
$P4 -p $P4HOST -u $P4USER verify -q //... > $P4VERIFYOUT
$P4 -p $P4HOST -u $P4USER verify -u -q //... >> $P4VERIFYOUT

#### Check
if [ -s $P4VERIFYOUT ]; then
        # Holy crap something bad happened - alert the troops and full stop
        logs "ERROR: Verify returned output - halting backup and alerting the troops"
        mailx -s "$SCRIPTNAME - Perforce Verify Output Errors - Backup failed [URGENT]" -t $ERRORRECIPIENT < $P4VERIFYOUT
        exit 1
fi


### Create a Checkpoint
logs "INFO: Creating a checkpoint... "
$P4 -p $P4HOST -u $P4USER admin checkpoint -z

### Move the Checkpoint and Journals to a backup folder
logs "INFO: Moving Backup Data... "

if ls $METADATADIR/journal.* > /dev/null 2>&1; then
	mv $METADATADIR/journal.* $BACKUPDIR
else
	logs "WARNING: No journal backups present"
fi

if ls $METADATADIR/checkpoint.* > /dev/null 2>&1; then
        mv $METADATADIR/checkpoint.* $BACKUPDIR
else
        logs "WARNING: No checkpoint backups present"
fi



### Move & compress the Logs to the backup folder

logs "Moving & compress the log file... "
mv $LOGFILE $BACKUPDIR
tar -cvzf $BACKUPDIR/p4d.log.$TODAY.gz $BACKUPDIR/p4d.log

### Cleanup the old stuff

logs "INFO: Cleaning up the old stuff... "

#### Remove old log file now that we gzip'd
if [ -s $BACKUPDIR/p4d.log.$TODAY.gz ]; then
	rm $BACKUPDIR/p4d.log
else
	logs "WARNING: Something went wrong in the Taring of the Logs"
fi

#### Clean up old journal checkpoint and p4d.log backups
find $BACKUPDIR/journal.* -mtime +$DAYSTOKEEP -exec rm -f {} \;
find $BACKUPDIR/checkpoint.* -mtime +$DAYSTOKEEP -exec rm -f {} \;
find $BACKUPDIR/p4d.log.* -mtime +$DAYSTOKEEP -exec rm -f {} \;

### Sync the Files

logs "Begining the sync process... "

# Sync full folder tree
$RSYNC -arzh --delete -e ssh $SERVERSDIR $BACKUPSERVER:$SERVERSDIR
$RSYNC -arzh --delete -e ssh $BACKUPDIR $BACKUPSERVER:$BACKUPDIR

logs "Copying server P4D configuration data..."
$RSYNC -arzh --delete -e ssh /etc/perforce/ $BACKUPSERVER:/opt/perforce/backup/etc/


logs "Sync Finished! Yay!"
date
