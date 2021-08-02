#!/bin/bash
lfs quota -h -g mel /mnt/lustre > DiscUsage

lfs quota -h -g mel /mnt/lustre | tail -1 | grep /mnt/lustre | awk '{print $2 }' | while read output;
do
  echo $output
  used=$(echo $output | cut -d'T' -f1)
  echo $used
  if (( $(echo "$used > 10.4" |bc -l) )); then
  grep -v "#" /mnt/lustre/mel/shared/Scripts/MEL-UserEmailList | awk '{$1=""; $3=""; print $0}' > CurrentUserEmailList
  while read line; do
    echo -e "The group has used $output as of $(date). Be aware that as we approach our grace usage limit of 11T, any currently running analyses may fail. Moreover, if we continue to remain over our 10T disc usage limit, our grace limit becomes a hard limit, meaning you will start to get i/o errors and be unable to run analyses and we will not even have the extra grace terabyte capacity to be able to compress files. \n\nNote that this program will double check the disc usage every 12 hours and will continue to send this email until the problem has been rectified. Please take any steps you can immediately to e.g., bzip compress any processed files, remove unnecessary and duplicate files, and free up space on Premise.\n\n***This email was automatically generated and replies to this email address may not be reviewed. Please direct all questions to Lindsey.Fenderson@unh.edu" | mail -s "Premise disk space alert - $output of 10T used" $line
  done < CurrentUserEmailList
  rm CurrentUserEmailList
  fi
done
