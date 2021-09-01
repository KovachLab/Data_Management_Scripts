# Data_Management_Scripts
A general repository for our lab for managing little scripts useful for managing and backing up our data.

Repository includes:

1.) DuplicateDiscUsage.sh - A script to calculate md5 checksums recursively for all files in a directory and identify any file duplicates across directories for removal to free up space.

2.) FileBackupScript.sh - A script to backup data from the remote cluster to local hard drives. Also includes information on how to set up passwordless remote access to the cluster from your local computer.

3.) ChecksumCompareScript.sh - Script to calculate md5 checksums recursively for all files in 2 or 3 locations (such as a remote cluster directory and a local hard drive backup or cloud storage) and identify which files may be unique to one directory or the other, suggesting the files either have not been backed up in the second location or that the file(s) got corrupted during backup.

4.) rm - a simple script users can set up for themselves to generate a temporary recycle bin on Linux. If the script is invoked instead of the 'rm' command whenever you want to delete something, it will move the files to a temporary directory so they can be retrieved (for a short time) before being deleted, incase the files were deleted in error.

5.) A copy of the cron jobs set up by LEF for monitoring and managing the lab's data and disc usage. This is an automatic scheduler for running the below scripts, as well as for emptying the group's "RecycleBin" on a weekly basis.

6.) Copy2Box.sh - I (LEF) have set this script to run as a regular bi-weekly cron job to ensure all Kovach Lab data are backed up to the cloud regularly.

7.) DiscUsageMonitoring.sh - I (LEF) run this script as a daily cron job to keep tabs on our cluster storage usage so I have an idea of where we're at storage-wise, if/how long we've been over-quota, how much space needs to be freed up, and generally monitor our disc space usage. The script starts sending me a daily email as we approach our quota threshold.

8.) GroupDiscUsageMonitoring.sh - I (LEF) run this script twice daily; if our disc usage reaches a critical threshold (currenlty set for 104% of our quota) the entire premise-using lab starts getting twice-daily emails to encourage immediate disc cleanup so we don't run out of space or trigger a hard limit which prevents us from being able to write any new data. *Requires keeping the associated 'MEL-UserEmailList' file up to date with the emails of current users in our group.
