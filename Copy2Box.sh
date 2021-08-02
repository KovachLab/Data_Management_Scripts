#!/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 24
#SBATCH --job-name Copy2Box
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Lindsey.Fenderson@unh.edu
module load linuxbrew/colsa
export https_proxy=http://premise.sr.unh.edu:3128
rclone copy -P Premise:/mnt/lustre/mel  Box:/AKLabBi-WeeklySnapshot

