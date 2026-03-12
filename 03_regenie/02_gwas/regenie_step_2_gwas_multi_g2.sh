#!/bin/sh
#$ -cwd
#$ -q fullnode15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas

usage()
{
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

   echo "Script for runninng regenie step 2 on local GWAS data"
   echo " "
   echo " "
   echo "Usage: bash /home/jitame/bin/code/CONGRADS_language/04_regenie/02_gwas/regenie_step_2_gwas.sh -c <chrom_number>"
   echo -e "\t-c chromosome number - REQUIRED "
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N regenie_step2_sent regenie_step2_sent.sh -c <chrom_number>"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}

### EVALUATE SOFTWARE AND SET INPUT ###

while getopts "c:" opt
do
   case "$opt" in
	 c ) chr="$OPTARG" ;;
	 ? ) usage ;; # Print usage in case parameter is non-existent
   esac
done

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 

#define paths
base=/data/clusterfs/lag/users/jitame/CONGRADS
pred_path=$base/geno/regenie/step_1/st1_out
in_path=$base/geno/regenie/st2_in_gwas
out_path=$base/geno/regenie/st2_out_gwas/c${chr}
pheno_list="melodic_g2_pmap_lifg_oic_0,melodic_g2_pmap_lifg_oic_1,melodic_g2_pmap_lifg_oic_2,melodic_g2_pmap_lstg_oic_0,melodic_g2_pmap_lstg_oic_1,melodic_g2_pmap_lstg_oic_2"
pheno_file=$base/pheno/all_idps_congrads_new.tsv

#Set up path and move to path
mkdir -p $out_path 
cd $out_path

#create list
awk -F " " '{print $2 }' $in_path/CONGRADS_chr${chr}.snpstats_mfi_hrc.compact.snps2keep > $in_path/CONGRADS_chr${chr}.snplist

#load + run regenie
module load regenie/3.6.0
regenie \
--step 2 \
--bgen $in_path/CONGRADS_chr${chr}.bgen \
--sample $in_path/CONGRADS_chr${chr}.sample \
--covarFile $base/pheno/regenie_final_covs.tsv \
--phenoFile $pheno_file \
--phenoColList $pheno_list \
--pred $pred_path/CONGRADS_65k_ic_pmaps_st1_pred_g2.list \
--extract $in_path/CONGRADS_chr${chr}.snplist \
--catCovarList "Genetic_sex,geno_array_dummy,site_dummy_11025,site_dummy_11026,site_dummy_11027" \
--covarExcludeList "site_dummy_11028" \
--minMAC 462 \
--bsize 500 \
--threads 4 \
--apply-rint \
--ref-first \
--verbose \
--lowmem \
--strict \
--multiphen \
--lowmem-prefix temp \
--par-region b37 \
--out $out_path/CONGRADS_gwas_g2_pmaps_65k_multi_c${chr}

# Store current date and time in variable and calculate the runtime
now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Elapsed time is "${runtime}" minutes.\n\n"

#,Scanner_lateral_(X)_brain_position_|_Instance_2,Scanner_transverse_(Y)_brain_position_|_Instance_2,Scanner_longitudinal_(Z)_brain_position_|_Instance_2