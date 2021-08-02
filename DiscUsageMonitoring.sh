#!/bin/bash
lfs quota -h -g mel /mnt/lustre/ > DiscUsage

lfs quota -h -g mel /mnt/lustre | tail -1 | grep /mnt/lustre | awk '{print $2 }' | while read output;
do
  echo $output
  used=$(echo $output | cut -d'T' -f1)
  echo $used
  if (( $(echo "$used > 9.5" |bc -l) )); then
  echo "The group has used $output as of $(date)" | mail -s "Disk space alert $output used" Lindsey.Fenderson@unh.edu
  fi
done
