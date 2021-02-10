#!/bin/bash
#**************************************************************#
#Checksum Compare Script by Lindsey Fenderson February 9, 2021 #
# Version 1.0.1.0                                              #
#Script to calculate md5 checksums recursively for all files   #
#  in 2 locations (such as a remote cluster and a local hard   #
#  drive backup or cloud storage) and identify which files     #
#  may be unique to one directory or the other, suggesting     #
#  the files either have not been backed up in the second      #
#  location or that the file got corrupted during backup.      #
#**************************************************************#
#To use this script, you must have the remote cluster (and/or cloud drive and external hard drive) mounted on your local computer. This script is then run from your local computer bash shell, e.g., in your home directory (~) or you can change the working directory to wherever you want the output files to be, e.g., % cd /Users/Lindsey/Documents/ModernSparrowGenomics/BackupRecords (but see Note #3 below)
#For each directory comparison performed, the program outputs 3 files for your reference: UniqueSourceFilesNotIn[Backup]Drive-$Comparison_time (i.e., a list of files that are only in the Source location and are not backed up in the other location (or not backed up without corruption, so the md5 checksums do not match) timestamped with the date the comparison was performed and with a header that lists the 2 files that were compared),  Unique[Backup]DriveBackupFilesNotInSource-$Comparison_time (i.e., a list of files that are only in the Backup location and are not in the Source location), and CommonSourceAnd[Backup]DriveFiles-$Comparison_time (i.e., a list of files that are common to both the Source directory and Backup location -i.e., meaning they have been backed up successfully), where [Backup] will be either 'Cloud' and/or 'Hard' depending on which backup directory(s) were compared with the Source (i.e., Premise) directory.
#Before running the script, you will need to edit the following: 
#   1.) Set your source and backup data directories of the files you want to confirm were backed up properly in lines 34, 39 & 40 
#   2.) Set the filenames for the output md5 lists in each location on lines 37, 42 & 44 [I recommend a naming scheme with a prefix specifying the location of the files (e.g., 'Box', 'SparrowsHD', 'Premise', 'LacieDrive', etc.) - the folder name of the files that are being compared - and a suffix with the date/time stamp of when the directories are being compared (i.e., the $current_time variable)]

#Finally, when you run the script, stick around for a minute to answer the 6 questions about which modules you want to run (e.g., if you've  run the script once and just added some of the missing files to your backup directory, you don't need to calculate all the md5 checksums on your source directory again, you can choose to just run the program on your backup directory(s) and then compare your checksum files for your source and backups.)

#*** Note 1: If you plan to only run certain modules (e.g., if you want to skip running the program to calculate the md5 sums on your source directory but want to compare the md5s from a previously run output source file), make sure to change the $current_time variable in the source filename to the actual time stamp of when the program was last run (e.g., as in example in lines 36 & 43) so it matches the file you want to compare to.)
#***Note 2: This script could take several hours/days to complete depending on the total amount of data to check!
#***Note 3: Still, running this script on your local computer for premise may take TOO long (e.g., if it has run for more than 3 or 4 hours without outputting anything to the Premise MD5 textfile yet). In that case, it is recommended to run just let the program finish on the backup directory(s) (i.e., when you no longer see "Cloud (or Hard Drive) Backup MD5 calculation process is still active..." being printed to the screen) and while waiting on that, run the following code directly on premise (obviously swap out the path and filenames for whatever you are using): 

# current_time=$(date "+%Y.%m.%d-%H.%M")
# find /mnt/lustre/mel/shared/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/ -type f \( ! -path '*/.*' \) \( -not -name Premise-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-$current_time.txt \) -exec md5sum '{}' \; > Premise-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-$current_time.txt &

#Then kill the program (The Source process ID to kill the process is printed to the screen at the start of the program, so you'll want to record that before your stdout history gets too large) and restart the program, using the Premise output file location and filename in the SourceLocation and SourceFilename below and type 'n' for questions 1 as well as questions 2 and/or 3 depending on which backup you've finished above, and type Premise' for question #6.
#***Note 4: You'll want to double check your directory structures and make sure the program strips an appropriate number of levels from each source or backup location to get the file paths in both places to match. See info on line #106 and change the -f numbers as needed in lines #109 or #117, and/or lines #125 or #166 (increasing the number by 1 shortens the directory path by one level & vice versa, so for example, changing line 109 to 'cut -d"/" -f8- $SourceFilename > SourceFile' would change the output paths to SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun, changing line 109 to 'cut -d"/" -f4- $SourceFilename > SourceFile' would change the output paths to mel/shared/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/)
#***Note 5: This program currently works on Mac zsh shell; TODO - add Windows.

#Set date & time stamp variable
current_time=$(date "+%Y.%m.%d-%H.%M")
#Set source directory (i.e., the original directory of files you were backing up)
SourceLocation='/Users/Lindsey/Premise/shared/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/'
#Set the filename for the list of md5sums in the source directory you are checking:
#SourceFilename="Premise-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-2021.02.08-17.53.txt"
SourceFilename="Premise-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-$current_time.txt"
#Set backup directory(s) (i.e., the location(s) you have backed the files up to):
CloudBackupLocation='/Users/Lindsey/Box/KovachLab/Data/Sparrows/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/'
HardDriveBackupLocation='/Volumes/Sparrows/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun'
#Set the filenames for the list of md5sums in the backup directories you are checking:
CloudFilename="BOX-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-$current_time.txt"
#CloudFilename="BOX-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-2021.02.08-20.05.txt"
HardDriveFilename="SparrowsHD-20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun-md5sum-$current_time.txt"

echo "Program Configuration Question 1 of 6: Do you want to run the MD5 calculation program on your Source Location? (Type 'y' or 'n', without the apostrophes, followed by [ENTER]):"
read SourceAnswer
echo "Program Configuration Question 2 of 6: Do you want to run the MD5 calculation program on your Cloud Location? (Type 'y' or 'n', without the apostrophes, followed by [ENTER]):"
read CloudRunAnswer
echo "Program Configuration Question 3 of 6: Do you want to run the MD5 calculation program on your HardDrive Location? (Type 'y' or 'n', without the apostrophes, followed by [ENTER]):"
read HardDriveRunAnswer
echo "Program Configuration Question 4 of 6: Do you want to compare the MD5 checksums of the files in your Source Location with those in your Cloud Location? (Type 'y' or 'n', without the apostrophes, followed by [ENTER]):"
read CloudCompareAnswer
echo "Program Configuration Question 5 of 6: Do you want to compare the MD5 checksums of the files in your Source Location with those in your Hard Drive Location? (Type 'y' or 'n', without the apostrophes, followed by [ENTER]):"
read HardDriveCompareAnswer
echo "Program Configuration Question 6 of 6: Was the Source MD5 file generated by this program or was it generated manually on Premise? (Type 'Program' for the former, or if you typed 'y' for question #1), otherwise type 'Premise' for the latter, without the apostrophes, followed by [ENTER]):"
read SourceFileAnswer

#Find all regular files [-type f] in the absolute path directory listed, calculate md5 checksums [-exec md5] recursively for all of those files and print results to output file.

if  [ $SourceAnswer == "y" ]; then
  echo "Calculating source MD5 checksums for the directory $SourceLocation"
  find $SourceLocation -type f \( ! -path '*/.*' \) \( -not -name $SourceFilename \) -exec md5 '{}' \; > $SourceFilename &
  SourceMD5_PID=$!
  echo "Source process ID= $SourceMD5_PID"
  while kill -0 $SourceMD5_PID ; do
        echo "Source MD5 calculation process is still active..."
        sleep 3
    done &
    cp $SourceFilename $SourceLocation$SourceFilename
else
  echo "Skipping calculation of MD5 checksums from source directory."
fi

if  [ $CloudRunAnswer == "y" ]; then
  echo "Calculating cloud backup MD5 checksums for the directory $CloudBackupLocation"
  find $CloudBackupLocation -type f \( ! -path '*/.*' \) \( -not -name $CloudFilename \) -exec md5 '{}' \; > $CloudFilename &
  CloudBackupMD5_PID=$!
  echo "CloudBackup process ID= $CloudBackupMD5_PID"
  while kill -0 $CloudBackupMD5_PID ; do
        echo "Cloud Backup MD5 calculation process is still active..."
        sleep 3
    done &
    cp $CloudFilename $CloudBackupLocation$CloudFilename
else
  echo "Skipping calculation of MD5 checksums from cloud backup directory."
fi

if  [ $HardDriveRunAnswer == "y" ]; then
  echo "Calculating hard drive backup MD5 checksums for the directory $HardDriveBackupLocation"
  find $HardDriveBackupLocation -type f \( ! -path '*/.*' \) \( -not -name $HardDriveFilename \) -exec md5 '{}' \; > $HardDriveFilename &
  HardDriveBackupMD5_PID=$!
  echo "HardDriveBackup process ID= $HardDriveBackupMD5_PID"
  while kill -0 $HardDriveBackupMD5_PID ; do
        echo "HardDrive Backup MD5 calculation process is still active..."
        sleep 3
    done &
    cp $HardDriveFilename $HardDriveBackupLocation$HardDriveFilename
else
  echo "Skipping calculation of MD5 checksums from hard drive backup directory."
fi

wait $CloudBackupMD5_PID
wait $HardDriveBackupMD5_PID
wait $SourceMD5_PID

#Format the output files so they can be compared (***NB - this code strips the initial root directories so the absolute paths in both directories being compared are identical. In this instance, it removes 4 directory levels (e.g.,"/mnt/lustre/mel/shared/") from the file paths on Premise, and removes 6 directory levels (e.g., "/Users/Lindsey/Box/KovachLab/Data/Sparrows/") from the file paths on the mounted Box drive. It is not necessary to trim any deeper because I have maintained the same directory structure and folder names in both premise and my backup locations (i.e.,: "/GECO/Data/SparrowRawData/20200728_INVS-SP_LFe_SparrowWholeGenomeShotgun/" is the same everywhere.) If you have a different directory structure it may be necessary to change the field numbers used in lines 109, 117, 125 & 166):
if  [ $SourceFileAnswer == "Program" ]; then
    cut -d"/" -f6- $SourceFilename > SourceFile
    cut -d" " -f3 SourceFile > SourceMD5
    cut -d")" -f1 SourceFile > SourceFileA
    sed 's+//+/+g' SourceFileA > SourceFileList
    paste -d" " SourceMD5 SourceFileList > $SourceFilename-Formatted
    sort $SourceFilename-Formatted > $SourceFilename-Sorted-Formatted
else
    cut -d" " -f3 $SourceLocation$SourceFilename > SourceFile
    cut -d"/" -f6- SourceFile > SourceFileList
    cut -d" " -f1 $SourceFilename > SourceMD5
    paste -d" " SourceMD5 SourceFileList > $SourceFilename-Formatted
    sort $SourceFilename-Formatted > $SourceFilename-Sorted-Formatted
fi

Comparison_time=$(date "+%Y.%m.%d-%H.%M")
if  [ $CloudCompareAnswer == "y" ]; then
    cut -d"/" -f8- $CloudFilename > CloudFile
    cut -d" " -f3 CloudFile > CloudMD5
    cut -d")" -f1 CloudFile > CloudFileA
    sed 's+//+/+g' CloudFileA > CloudFileList
    paste -d" " CloudMD5 CloudFileList > $CloudFilename-Formatted
    sort $CloudFilename-Formatted > $CloudFilename-Sorted-Formatted

    comm -23 $SourceFilename-Sorted-Formatted $CloudFilename-Sorted-Formatted > UniqueSourceFilesNotInCloud
    sort -k 2 UniqueSourceFilesNotInCloud > UniqueSourceFilesNotInCloudNameSort

    comm -13 $SourceFilename-Sorted-Formatted $CloudFilename-Sorted-Formatted > UniqueCloudBackupFiles
    sort -k 2 UniqueCloudBackupFiles > UniqueCloudBackupFilesNameSort

    comm -12 $SourceFilename-Sorted-Formatted $CloudFilename-Sorted-Formatted > CommonSourceAndCloudFiles
    sort -k 2 CommonSourceAndCloudFiles > CommonSourceAndCloudFilesNameSort

    echo "Timestamp When Directory Files Were Compared:" $Comparison_time > SourceAndCloudHeader
    echo "Source Directory Files Compared:" $SourceFilename >> SourceAndCloudHeader
    echo "Backup Directory Files Compared:" $CloudFilename >> SourceAndCloudHeader
    cp SourceAndCloudHeader UniqueSourceFilesNotInCloudHeader
    echo "List of files that only exist in the source directory:" >> UniqueSourceFilesNotInCloudHeader
    cp SourceAndCloudHeader UniqueCloudBackupFilesHeader
    echo "List of files that only exist in the backup directory:" >> UniqueCloudBackupFilesHeader
    cp SourceAndCloudHeader CommonSourceAndCloudFilesHeader
    echo "List of files in common between the source and backup directories:" >> CommonSourceAndCloudFilesHeader
    cat UniqueSourceFilesNotInCloudHeader UniqueSourceFilesNotInCloudNameSort > UniqueSourceFilesNotInCloud-$Comparison_time
    cat UniqueCloudBackupFilesHeader UniqueCloudBackupFilesNameSort > UniqueCloudBackupFilesNotInSource-$Comparison_time
    cat CommonSourceAndCloudFilesHeader CommonSourceAndCloudFilesNameSort > CommonSourceAndCloudFiles-$Comparison_time
    #Cleanup temp files
    rm $CloudFilename
    rm $CloudFilename-Formatted
    rm UniqueSourceFilesNotInCloud
    rm CloudFile
    rm CloudMD5
    rm CloudFileA
    rm CloudFileList
else
  echo "Skipping comparison of MD5 checksums from source and cloud backup directories."
fi

if  [ $HardDriveCompareAnswer == "y" ]; then
    cut -d"/" -f8- $HardDriveFilename > HardDriveFile
    cut -d" " -f3 HardDriveFile > HardDriveMD5
    cut -d")" -f1 HardDriveFile > HardDriveFileA
    sed 's+//+/+g' HardDriveFileA > HardDriveFileList
    paste -d" " HardDriveMD5 HardDriveFileList > $HardDriveFilename-Formatted
    sort $HardDriveFilename-Formatted > $HardDriveFilename-Sorted-Formatted

    comm -23 $SourceFilename-Sorted-Formatted $HardDriveFilename-Sorted-Formatted > UniqueSourceFilesNotInHardDrive
    sort -k 2 UniqueSourceFilesNotInHardDrive > UniqueSourceFilesNotInHardDriveNameSort

    comm -13 $SourceFilename-Sorted-Formatted $HardDriveFilename-Sorted-Formatted > UniqueHardDriveBackupFiles
    sort -k 2 UniqueHardDriveBackupFiles > UniqueHardDriveBackupFilesNameSort

    comm -12 $SourceFilename-Sorted-Formatted $HardDriveFilename-Sorted-Formatted > CommonSourceAndHardDriveFiles
    sort -k 2 CommonSourceAndHardDriveFiles > CommonSourceAndHardDriveFilesNameSort

    echo "Timestamp When Directory Files Were Compared:" $Comparison_time > SourceAndHardDriveHeader
    echo "Source Directory Files Compared:" $SourceFilename >> SourceAndHardDriveHeader
    echo "Backup Directory Files Compared:" $HardDriveFilename >> SourceAndHardDriveHeader
    cp SourceAndHardDriveHeader UniqueSourceFilesNotInHardDriveHeader
    echo "List of files that only exist in the source directory:" >> UniqueSourceFilesNotInHardDriveHeader
    cp SourceAndHardDriveHeader UniqueHardDriveBackupFilesHeader
    echo "List of files that only exist in the backup directory:" >> UniqueHardDriveBackupFilesHeader
    cp SourceAndHardDriveHeader CommonSourceAndHardDriveFilesHeader
    echo "List of files in common between the source and backup directories:" >> CommonSourceAndHardDriveFilesHeader
    cat UniqueSourceFilesNotInHardDriveHeader UniqueSourceFilesNotInHardDriveNameSort > UniqueSourceFilesNotInHardDrive-$Comparison_time
    cat UniqueHardDriveBackupFilesHeader UniqueHardDriveBackupFilesNameSort > UniqueHardDriveBackupFilesNotInSource-$Comparison_time
    cat CommonSourceAndHardDriveFilesHeader CommonSourceAndHardDriveFilesNameSort > CommonSourceAndHardDriveFiles-$Comparison_time
    #Cleanup temp files
    rm $HardDriveFilename
    rm $HardDriveFilename-Formatted
    rm UniqueSourceFilesNotInHardDrive
    rm HardDriveFile
    rm HardDriveMD5
    rm HardDriveFileA
    rm HardDriveFileList
else
  echo "Skipping comparison of MD5 checksums from source and hard drive backup directories."
fi

#Cleanup temp files
rm $SourceFilename
rm $SourceFilename-Formatted
rm SourceFile
rm SourceMD5
rm SourceFileA
rm SourceFileList
rm Unique*BackupFiles
rm UniqueCloudBackupFilesNameSort
rm UniqueSourceFilesNotInCloudNameSort
rm Common*Files
rm Common*FilesNameSort
rm *Header

echo "Checksum Compare is complete."
