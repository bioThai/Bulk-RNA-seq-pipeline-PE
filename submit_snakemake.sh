#!/usr/bin/bash
#SBATCH --time 35:00:00
#SBATCH --partition exacloud
#SBATCH --job-name workflow_submission
#SBATCH --output=logs/workflow_submission_%j.log

# provide number of active cluster jobs to run, absolute path to folder containing all raw sequencing data, and absolute path to index files for alignment
# here, number of jobs and absolute paths are specified by command-line arguments passed to this script
num_active_jobs=$1
raw_data_path=$2
index_files=$3

# If running pipeline inside Singularity container on Exacloud, run these commands instead:
# Make sure you are on a compute node (not head node) before executing submit_snakemake.sh:
# srun --pty --time=24:00:00 -c 4 bash

# activate Singularity module
module load /etc/modulefiles/singularity/current

# run pipeline
snakemake -j $num_active_jobs --use-singularity --singularity-args "--bind ../Bulk-RNA-seq-pipeline-PE:/Bulk-RNA-seq-pipeline-PE,$raw_data_path,$index_files" --use-conda --profile slurm_singularity --cluster-config cluster.yaml

exit