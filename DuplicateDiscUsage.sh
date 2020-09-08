#!/bin/bash
#****************************************************#
#Duplicate Disc Usage Script by Lindsey Fenderson August 2020
#Simple script to calculate md5 checksums recursively for all files in a directory and identify duplicates for removal to free up space.
#Time to run program will depend on the number of files to comb through and the current traffic on the compute node; when I ran it on the Premise login node for ~9.5T of data it took about 12-16 hours to complete.
#****************************************************#
#Script must be run from a directory where you have write permissions

#Set date & time stamp variable
current_time=$(date "+%Y.%m.%d-%H.%M")

#Remove old versions of files that don't get overwritten in the script:
rm DuplicateDiscUsage.txt 
#Find all regular files [-type f] in the absolute path directory listed, calculate md5 checksums [-exec md5sum] for all of those files (excluding the output file) and print results to output file.
find /mnt/lustre/mel/ -type f \( -not -name "MELmd5sum.txt" \) -exec md5sum '{}' \; > MELmd5sum.txt
cp MELmd5sum.txt MELmd5sum_$current_time.txt
#Sort the output based on the md5sum and print *all* duplicate lines to a new output file 
sort MELmd5sum.txt > MELmd5sumSORT.txt
cut -d" " -f1 MELmd5sumSORT.txt > md5.txt
cut -d" " -f3 MELmd5sumSORT.txt > path.txt
paste path.txt md5.txt > MELmd5List.txt
uniq --all-repeated=separate -f 1 MELmd5List.txt > MEL-DuplicateFiles.txt
#Extract the absolute file path of the duplicate files
cut -f1 MEL-DuplicateFiles.txt > DuplicateFiles.txt
#Print the file size of the potentially duplicate files
while read DuplicateFiles; do
	if [ -z "$DuplicateFiles" ]; then 
  		echo "* * ********** *** **** *** ** **** ********************************************** " >> DuplicateDiscUsage.txt
		else ls -lh $DuplicateFiles >> DuplicateDiscUsage.txt
	fi
done < DuplicateFiles.txt
#Make table pretty and readable
cut -d" " -f3- DuplicateDiscUsage.txt > DuplicateDiscUsage2.txt
awk '{$2=""; print $0}' DuplicateDiscUsage2.txt > DuplicateDiscUsage3.txt
echo "OWNER       FILE_SIZE   MM  DD  YYYY   FILE_PATH" > header
cat header DuplicateDiscUsage3.txt > DuplicateDiscUsage4.txt
column -t DuplicateDiscUsage4.txt > DuplicateDiscUsage5.txt
sed 's+/mnt/lustre/mel/++g' DuplicateDiscUsage5.txt > DuplicateDiscUsage6.txt
#Split out duplicate file groups by user
awk -v RS='*' -v ORS='\n' '/gvc1002/' DuplicateDiscUsage6.txt > Gemma
cat header Gemma > GemmaClucas-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/kwojtusik/' DuplicateDiscUsage6.txt > Kris
cat header Kris > KrisWojtusik-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/lmf53/' DuplicateDiscUsage6.txt > Logan
cat header Logan > LoganMaxwell-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/jdc1068/' DuplicateDiscUsage6.txt > Jon
cat header Jon > JonClark-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/bking/' DuplicateDiscUsage6.txt > Ben
cat header Ben > BenKing-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/kbarton/' DuplicateDiscUsage6.txt > Kayla
cat header Kayla > KaylaBarton-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/akw1030/' DuplicateDiscUsage6.txt > Andrew
cat header Andrew > AndrewWiegardt-DuplicateDiscUsage-$current_time.txt
awk -v RS='*' -v ORS='\n' '/leq29/' DuplicateDiscUsage6.txt > Lindsey
cat header Lindsey > LindseyFenderson-DuplicateDiscUsage-$current_time.txt

#Estimate how much space could be saved by removing duplicates (note the simple calculation is a conservative minimum estimate of the amount of space that could be freed up after removal of duplicates as the calculation assumes there is only 1 duplicate of each file, but more space will be freed if there was more than 1 copy made of any files and all of the duplicates were removed.)
MinDupDiscSpace=$(cat DuplicateDiscUsage6.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }' | numfmt --to=iec)
#Cleanup tmp files
rm MELmd5sumSORT.txt
rm md5.txt
rm path.txt
rm MELmd5List.txt
rm MEL-DuplicateFiles.txt
rm DuplicateDiscUsage2.txt
rm DuplicateDiscUsage3.txt
rm DuplicateDiscUsage4.txt
rm DuplicateDiscUsage5.txt
rm Gemma
rm Kris
rm Logan
rm Jon
rm Ben
rm Kayla
rm Andrew
rm Lindsey
#Notify yourself that the script is complete. (Change email address as needed).
echo -e "Identification of potentially duplicate files for deletion is complete. Over *$MinDupDiscSpace* of our lab's disc space quota could be freed up by deleting the extra copies of your files.\n\nYou will receive an email attachment shortly listing the directory paths of your duplicate files. Please refer to the Kovach Lab Data Management User Guide at Box -> KovachLab -> Protocols -> Data_Management_Protocols to review appropriate file storage locations on Premise and delete your duplicate files as soon as possible.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" | mailx -s "Premise Duplicate Files" Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

#Complete individual notifications of duplicate files
Lindsey2DupDiscSpace=$(cat LindseyFenderson-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
LindseyDupDiscSpace=$(printf "%.14f" $Lindsey2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Lindsey,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$LindseyDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a LindseyFenderson-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Gemma2DupDiscSpace=$(cat GemmaClucas-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
GemmaDupDiscSpace=$(printf "%.14f" $Gemma2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Gemma,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$GemmaDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a GemmaClucas-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Kris2DupDiscSpace=$(cat KrisWojtusik-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
KrisDupDiscSpace=$(printf "%.14f" $Kris2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Kris,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$KrisDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a KrisWojtusik-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Logan2DupDiscSpace=$(cat LoganMaxwell-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
LoganDupDiscSpace=$(printf "%.14f" $Logan2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Logan,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$LoganDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a LoganMaxwell-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Jon2DupDiscSpace=$(cat JonClark-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
JonDupDiscSpace=$(printf "%.14f" $Jon2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Jon,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$JonDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a JonClark-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Andrew2DupDiscSpace=$(cat AndrewWiegardt-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
AndrewDupDiscSpace=$(printf "%.14f" $Andrew2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Andrew,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$AndrewDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a AndrewWiegardt-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Kayla2DupDiscSpace=$(cat KaylaBarton-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
KaylaDupDiscSpace=$(printf "%.14f" $Kayla2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Kayla,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$KaylaDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a KaylaBarton-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

Ben2DupDiscSpace=$(cat BenKing-DuplicateDiscUsage-$current_time.txt | numfmt --field=2 --invalid=ignore --from=iec | awk '{ total += $2 }; END { print total/2 }')
BenDupDiscSpace=$(printf "%.14f" $Ben2DupDiscSpace | numfmt --to=iec)
echo -e "Hi Ben,\n\nPlease find attached a list of files you own that appear to be duplicated on Premise. You may help us free up *$BenDupDiscSpace* of our lab's shared disc space by removing your duplicate files.\n\nPlease review this list and remove duplicate copies of your files as appropriate (i.e. remove the copies in your personal folder if they already exist in the shared folder and may be useful to other lab members now or in the future - Refer to the Kovach Lab Data Management User Guide for more guidance if needed or ask if you are not sure which files to keep.\n\nN.B. - Symbolic links might show up in my script as duplicate files but they do NOT need to be deleted as they do not use up extra space (you should see '0' in the FileSize field next to any symbolic links you have set up, and obviously keep a single copy of the source file the link points to.\n\n*Also, ignore any hidden files that come up as duplicates like '.bashrc'; they're probably important and don't take up much space anyway.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" |mailx -s "Premise File Duplicates" -a BenKing-DuplicateDiscUsage-$current_time.txt Lindsey.Fenderson@unh.edu -c wildlifer1@gmail.com

#TODO: Stop being ridiculous and repeating code; use loop & vars for individual files etc.!
#sort groups by total size somehow, and maybe grep -c paths in order to ID whole directories that are likely duplicated?
