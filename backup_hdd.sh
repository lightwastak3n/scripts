#!/usr/bin/env bash
# Backup to other HDD and to external HDD
# Probably bad but it works for now

backup () {
	sudo rsync -aAXHv --info=progress2 /usr/local/ "$1"
	notify-send "/usr/local backed up to $1"
	sudo rsync -aAXHv --info=progress2 --exclude-from=/home/sasa/scripts/data/ignore.txt /home/sasa/ "$2"
	notify-send "home dir backed up to $2"
	notify-send "Backup finished."
}

if mount | grep "AlexLaptop1"; then
	echo "Laptop hdd mounted. Backing up."
	backup "/run/media/sasa/AlexLaptop1/Sasa/usr-local/" "/run/media/sasa/AlexLaptop1/Sasa/mj/"
    $HOME/scripts/ntfy.sh "💾 Finished backing up to laptop hdd."
else
	echo "Laptop hdd not mounted. Mounting."
	udisksctl mount -b /dev/sdb6
	backup "/run/media/sasa/AlexLaptop1/Sasa/usr-local/" "/run/media/sasa/AlexLaptop1/Sasa/mj/"
    $HOME/scripts/ntfy.sh "💾 Finished backing up to laptop hdd."
fi

if mount | grep "Backup"; then
	echo "External hdd mounted. Backing up."
	backup "/run/media/sasa/Backup/Sasa_Backup/usr-local/" "/run/media/sasa/Backup/Sasa_Backup/mj/"
    $HOME/scripts/ntfy.sh "💾 Finished backing up to external hdd."
else
	echo "External hdd not mounted. Skipping."
	notify-send "External hdd not mounted. Skipping."
fi

