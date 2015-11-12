#!/bin/bash
# Backup script for linux maschines with lvm2 tools
#
# This script creates a LVM2 Snapshot of LOCICAL_VOLUMEN from the VOLUME_GROUP.
# The size of this snapshot is LVM_SNAPSHOT_SIZE
# Then this snapshot is mounted on MOUNT_SNAPSHOT_TO path.
# After the mount the mount point is backed up with rsync to the BACKUP_TO path.

suexe=/bin/su
rsyncexe="/usr/bin/rsync -a --delete"
# Uncomment this line if you want a real backup. with this line
# rsync runs in 'dry run mode'.
rsyncexe="/usr/bin/rsync -n"
mountexe=/bin/mount
umountexe=/bin/umount
lvcreateexe=/sbin/lvcreate
lvremoveexe=/sbin/lvremove
MOUNT_SNAPSHOT_TO=/mnt/backup
VOLUME_GROUP=vgsystem
LOCICAL_VOLUMEN=root
LVM_SNAPSHOT_SIZE=10G
BACKUP_TO=/tmp

# Check and create if nessessary the mountpoint
# where the backups mounted later on.
if [[ ! -d ${MOUNT_SNAPSHOT_TO} ]]; then mkdir ${MOUNT_SNAPSHOT_TO}; fi

echo -e "\nStart Backup"

# LVM Snapshot of
echo -e "Create snapshot of ${LVM_SNAPSHOT_SIZE} on ${VOLUME_GROUP} ..."
$lvcreateexe -s /dev/${VOLUME_GROUP}/${LOCICAL_VOLUMEN} -n ${LOCICAL_VOLUMEN}-snap -L${LVM_SNAPSHOT_SIZE} || exit 1
# now mount the lvm snapshot to back them up
echo -e "Mount snapshot ${LOCICAL_VOLUMEN}-snap to ${MOUNT_SNAPSHOT_TO} ..."
$mountexe /dev/${VOLUME_GROUP}/${LOCICAL_VOLUMEN}-snap ${MOUNT_SNAPSHOT_TO} || exit 1
# Back them up
echo -e "Backup ${MOUNT_SNAPSHOT_TO}" to "${BACKUP_TO} ..."
$rsyncexe "${MOUNT_SNAPSHOT_TO}" "${BACKUP_TO}" || exit 1
# Then umount the lvm snapshot
echo -e "Umount snapshot ..."
sleep 3
$umountexe ${MOUNT_SNAPSHOT_TO} || exit 1
# Finaly remove the lvm snapshot
echo -e "Remove snapshot ..."
$lvremoveexe /dev/${VOLUME_GROUP}/${LOCICAL_VOLUMEN}-snap -f || exit 1

echo -e "Backup finished.\n"
