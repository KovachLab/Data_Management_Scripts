# Data_Management_Scripts
A general repository for our lab for managing little scripts useful for managing and backing up our data.

Repository includes:

1.) DuplicateDiscUsage.sh - A script to calculate md5 checksums recursively for all files in a directory and identify any file duplicates across directories for removal to free up space.

2.) FileBackupScript.sh - A script to backup data from the remote cluster to local hard drives. Also includes information on how to set up passwordless remote access to the cluster from your local computer.

3.) ChecksumCompareScript.sh - Script to calculate md5 checksums recursively for all files in 2 or 3 locations (such as a remote cluster directory and a local hard drive backup or cloud storage) and identify which files may be unique to one directory or the other, suggesting the files either have not been backed up in the second location or that the file(s) got corrupted during backup.

4.) rm - a simple script users can set up for themselves to generate a temporary recycle bin on Linux. If the script is invoked instead of the 'rm' command whenever you want to delete something, it will move the files to a temporary directory so they can be retrieved (for a short time) before being deleted, incase the files were deleted in error.
