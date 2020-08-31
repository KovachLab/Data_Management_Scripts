#!/bin/bash
#****************************************************#
#File Backup Script by Lindsey Fenderson August 2020
#Simple script to backup data from remote cluster to 
#    local hard drives
#****************************************************#
#Note that this script assumes you have set up passwordless access to the remote machine, otherwise you will be asked to enter your password for every file or directory that gets copied which basically defeats the purpose of using a script. To set up passwordless access, complete the following steps:
#1.) Type 'ssh-keygen' on your local machine terminal. You will see something like 
    #"Generating public/private rsa key pair.
    #Enter file in which to save the key (/Users/Lindsey/.ssh/id_rsa): [Do not type anything in, just hit the Enter/Return key.]
#2.) You'll then be asked "Enter passphrase (empty for no passphrase):" [Just press enter key]
#3.) "Enter same passphrase again:" [Just press enter key]
#4.) You should then see something like 
#"Your identification has been saved in /home/jsmith/.ssh/id_rsa.
#Your public key has been saved in /home/jsmith/.ssh/id_rsa.pub.
#The key fingerprint is:
#33:b3:fe:af:95:95:18:11:31:d5:de:96:2f:f2:35:f9 jsmith@local-host"
#Now copy your public key to the remote host. Type: 'ssh-copy-id -i ~/.ssh/id_rsa.pub remote-host' where remote-host would be, for example, premise.sr.unh.edu.
#5.) The system will ask for your password one more time to confirm: 
#"jsmith@remote-host's password: [Enter your login password for the remote machine]
#Now try logging into the machine, with "ssh 'remote-host'", and check in:
#.ssh/authorized_keys
#to make sure we haven't added extra keys that you weren't expecting.
#6.) Double check that everything is working. Exit back to your local machine, then ssh to the remote machine, e.g.:
#ssh leq29@premise.sr.unh.edu [Enter]
#Now you should be all logged in without getting a password prompt!
##(T0 DO: Verify process on Windows/Putty setup)
#****************************************************#
#To run this script, you need to generate a list of files you want to copy. This can be done for example from the remote host, in the highest-level directory you want to copy, type 'ls > Files' then copy 'Files' to your local machine in the directory where you will be running the script.
# Update lines 32 and 35 with the name of the file list if you called it something other than 'Files'; update line 33 with your own login ID, change the remote host if needed, and enter the directory path you want to backup as well as the local path you want to backup to.
# Then Run this script from your local machine. 
while read Files; do
rsync -acv leq29@premise.sr.unh.edu://mnt/lustre/mel/shared/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/$Files /Volumes/TOSHIBA3_EX/GECOData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun
done <Files

#Above, line 33 is example for copying to an external hard drive on a Mac. Below is example syntax for copying data to your local (mac) hard drive. ##(TO DO: Add example for Windows machines)
#rsync -acv leq29@premise.sr.unh.edu://mnt/lustre/mel/shared/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/$Files ~/Documents/ModernSparrowGenomics/Data/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun

#current_time=$(date "+%Y.%m.%d-%H.%M")
#\n" > FilesCopied-$current_time.txt

#Change email address as needed so you will be alerted when the file backup is complete.
mailx -s "FilesCopied" Lindsey.Fenderson@unh.edu <<< "File backup complete"

