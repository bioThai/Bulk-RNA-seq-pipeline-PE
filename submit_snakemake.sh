#!/usr/bin/bash
#SBATCH --time 35:00:00
#SBATCH --partition exacloud
#SBATCH --job-name workflow_submission
#SBATCH --output=logs/workflow_submission_%j.log

# provide absolute path to folder containing all raw sequencing data, index files for alignment
raw_data_path="/home/groups/MaxsonLab/input-data2/RNA-seq/PTSAMPLE/210723_A01058_0141_AHF7YFDRXY/LIB210714TB/"
index_files="/home/groups/MaxsonLab/indices/"

# if using cluster.json, run this command:
# snakemake -j 100 --use-conda --rerun-incomplete --latency-wait 20 --cluster-config cluster.json --cluster "sbatch -p {cluster.partition} -N {cluster.N}  -t {cluster.t} -o {cluster.o} -e {cluster.e} -J {cluster.J} -c {cluster.c} --mem {cluster.mem}" -s Snakefile 

# if using cluster.yaml (highly recommended), run this command instead:
# snakemake -j 100 --use-conda --profile slurm --cluster-config cluster.yaml

# if running pipeline inside Singularity container on Exacloud, run these commands instead:
# make sure you are on a compute node (not head node) when running Singularity
# srun --pty --time=24:00:00 -c 4 bash
module load /etc/modulefiles/singularity/current
snakemake -j 100 --use-singularity --singularity-args "--bind ../Bulk-RNA-seq-pipeline-PE:/Bulk-RNA-seq-pipeline-PE,$raw_data_path,$index_files" --use-conda --profile slurm_singularity --cluster-config cluster.yaml

exit