#!/bin/sh
#$ -cwd
#$ -q fullnode15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs
#$ -o /home/jitame/bin/logs
#$ -M Jitse.Amelink@mpi.nl
#$ -N congrads_post_processing_pca_new
#$ -m beas

#command: qsub /home/jitame/bin/code/CONGRADS_language/01_post_processing_phenos/04_congrads_post_processing_wrap.sh

#python_path="/home/jitame/bin/anaconda3/envs/results_env/bin/python"
python_path="/usr/shared/apps/miniconda/3.2021.10/bin/python" 
file_name="/home/jitame/bin/code/CONGRADS_language/01_post_processing_phenos/CONGRADS_post_processing_v2.py"

output_path="/data/clusterfs/lag/users/jitame/CONGRADS/pheno"
cd $output_path

module purge
module load miniconda/3.2021.10
$python_path $file_name
