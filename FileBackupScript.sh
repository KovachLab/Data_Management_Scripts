#!/bin/bash
#****************************************************#
#File Backup Script by Lindsey Fenderson August 2020
#Simple script to backup data from remote cluster to 
#    local hard drives
#****************************************************#
#Note that this script assumes you have set up passwordless access to the remote machine, otherwise you will be asked to enter your password for every file or directory that gets copied which basically defeats the purpose of using a script. To set up passwordless access, complete the following steps:
##On a Mac:
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
##On a Windows machine:
#This assumes you have PuTTY installed to access the the remote cluster from a Windows computer.
#1.) Start PuTTYgen (i.e., this is a different program than the PuTTY you use to login to Premise, but is in the same application folder)
#2.) Click the 'Generate' button on the GUI and move the mouse to generate your random key.
#3.) Save both your public and private keys locally (give them unique names without extensions, e.g. winid_rsa and winprivateid_rsa) and when promted select 'YES' that you don't want to protect the keys with a password.
#4.) Copy the public key to your personal ssh folder on Premise. For example, if you have Premise mounted locally, just navigate to your personal folder in Windows (e.g., in my case it is leq29) and you will see a hidden folder called ssh. Copy the key to this folder.
#5.) Use PuTTY to now login to Premise and append the contents of that public key to your authorized_keys file. I.e.: From your home directory (cd ~) type 'ssh-keygen -i -f ~/.ssh/winid_rsa >> ~/.ssh/authorized_keys' (where you replace 'winid_rsa' with the name of your public key file that you just uploaded to this folder.)
#6.) Now close the Premise terminal in PuTTY and restart PuTTY. In the left sidebar in the PuTTY configuration window, expand the Connection tab and highlight 'Data' and enter your Premise username in the Auto-login username field (e.g., 'leq29')
#7.) Now expand the SSH tab and highlight 'Auth' Click the 'Browse' button and browse to select the private key you generated and saved locally above (e.g., winprivateid_rsa).
#8.) Click on 'Session' on the left and fill out the host name (premise.sr.unh.edu) and ensure that Port=22 and that the SSH radio button is selected. Type a name for these settings in the Saved Sessions field and click 'Save'. Now load that saved session, hit 'Open' and Voila! You should be logged into Premise without it asking for your password.
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

