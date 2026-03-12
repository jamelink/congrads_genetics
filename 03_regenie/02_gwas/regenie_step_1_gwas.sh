#!/bin/sh
#$ -cwd
#$ -q fullnode15.q
#$ -S /bin/bash 
#$ -e /data/clusterfs/lag/users/jitame/logs/
#$ -o /data/clusterfs/lag/users/jitame/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -N congrads_st1_gwas_cmaps_final
#$ -m beas

### USAGE ###

#qsub /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_1_gwas.sh



workspace_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/
cfs_path=/data/clusterfs/lag/users/jitame/CONGRADS/pheno

#cp $workspace_path/regenie_covariates_65k.tsv $cfs_path

#define paths, edit this
base=/data/clusterfs/lag/users/jitame/CONGRADS
base_reg=${base}/geno/regenie/
in_path=$base_reg/step_1/st1_in
out_path=$base_reg/step_1/st1_out
#pheno_file=$base/pheno/congrads_pcs_N34554.tsv
pheno_file=$base/pheno/all_idps_congrads_new.tsv
#pheno_list="melodic_g1_pmap_lifg_oic_0,melodic_g1_pmap_lifg_oic_1,melodic_g1_pmap_lifg_oic_2,melodic_g1_pmap_lstg_oic_0,melodic_g1_pmap_lstg_oic_1,melodic_g1_pmap_lstg_oic_2,melodic_g2_pmap_lifg_oic_0,melodic_g2_pmap_lifg_oic_1,melodic_g2_pmap_lifg_oic_2,melodic_g2_pmap_lstg_oic_0,melodic_g2_pmap_lstg_oic_1,melodic_g2_pmap_lstg_oic_2"
pheno_list="melodic_g1_cmap_lifg_oic_1,melodic_g1_cmap_lstg_oic_1,melodic_g2_cmap_lstg_oic_1,melodic_g2_cmap_lifg_oic_1,melodic_g1_cmap_lstg_oic_0,melodic_g1_cmap_lstg_oic_2,melodic_g2_cmap_lstg_oic_2,melodic_g2_cmap_lifg_oic_0,melodic_g1_cmap_lifg_oic_2,melodic_g2_cmap_lstg_oic_0,melodic_g1_cmap_lifg_oic_0"
runname="CONGRADS_65k_ic_cmaps"

mkdir -p $out_path/temp
cd $out_path/temp

echo "Run regenie for $pheno_file" 

#load + run regenie
module load regenie/3.6.0
#regenie_path=/home/jitame/bin/software/regenie/3.6.0
regenie \
--step 1 \
--bed $in_path/CONGRADS_merged_regenie_step1 \
--covarFile $base/pheno/regenie_final_covs.tsv \
--catCovarList "Genetic_sex,geno_array_dummy,site_dummy_11025,site_dummy_11026,site_dummy_11027" \
--covarExcludeList "site_dummy_11028" \
--phenoFile $pheno_file \
--phenoColList $pheno_list \
--bsize 1000 \
--threads 12 \
--apply-rint \
--lowmem \
--lowmem-prefix temp \
--out $out_path/${runname}_st1_cmap

### Creating tar

#Scanner_lateral_(X)_brain_position_|_Instance_2,Scanner_transverse_(Y)_brain_position_|_Instance_2,Scanner_longitudinal_(Z)_brain_position_|_Instance_2"
#out_file=$base/step_1_sent_all.tar.gz
#cd $out_path
#tar cfz $out_file *.loco
