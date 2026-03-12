#!/bin/bash

data_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/primary_data/genetic_data/snp/snp_release_v2
base_out_dir=/data/clusterfs/lag/users/jitame/CONGRADS
out_dir=${base_out_dir}/geno/regenie/step_1/st1_in
#sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N49345_plink.txt
sub_list=${base_out_dir}/pheno/congrads_final_subs_N46267_plink.txt

#duplicate sub column
#awk '{print $1" "$1}' congrads_final_subs_N46267.txt > $new_fn

mkdir -p $out_dir

for c in {1..22}; do 
qsub -N "regenie_filter_st1_c${c}" /home/jitame/bin/code/CONGRADS_language/04_regenie/01_prep/regenie_prepare_step1_select_variants.sh \
        -i ${data_dir}/cal/ukb_cal_chr${c}_v2.bed \
        -b ${data_dir}/snp/ukb_snp_chr${c}_v2.bim \
        -f ${data_dir}/cal/ukb1606_cal_chr1_v2_s488366.fam \
        -o ${out_dir} \
        -n "regenie_select_c${c}" \
        -s ${sub_list}
        
done












################################################################################

for i in {1..70}; do \
bash exome_genotype_variant_filtering_submit_c2_b${i}.sh done

awk '{print $0, $0}' /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N49345.txt > /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N49345_plink.txt

#data_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/derived_data/genetic_data/snp/subset_imagingT1_40k/v1_white_british_ancestry/with_rel_filter
#base_out_dir=/data/clusterfs/lag/users/jitame/SENT_CORE
#out_dir=${base_out_dir}/geno/regenie/step_2_sent_all/gwas/st2_in

#mkdir -p $out_dir

#for chr in {1..22}; do 
#awk 'NR>9' ${data_dir}/imagingT1_chr${chr}.snpstats.txt > $out_dir/imagingT1_chr_${chr}.snpstats.txt

#head -n -2 $out_dir/imagingT1_chr_${chr}.snpstats.txt > $out_dir/temp_chr${chr}.txt
#mv $out_dir/temp_chr${chr}.txt $out_dir/imagingT1_chr_${chr}.snpstats.txt
#done

data_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/primary_data/genetic_data/snp/snp_release_v3/data
base_out_dir=/data/clusterfs/lag/users/jitame/SENT_CORE
out_dir=${base_out_dir}/geno/regenie/step_2_sent_all/gwas/st2_in


for c in {1..22}; do 
qsub -N "CONGRADS_st2_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas.sh -c ${c}
done

qsub -N "CONGRADS_st2_cX" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas.sh -c "X"

qsub -N "CONGRADS_st2_cXY" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas.sh -c "XY"




for c in {1..22}; do 
qsub -N "regenie_st2_c${c}" /home/jitame/bin/code/AICHA/03_regenie/02_gwas/regenie_step_2_gwas.sh \
    -c ${c}
done

qsub -N "regenie_st2_cX" /home/jitame/bin/code/AICHA/03_regenie/02_gwas/regenie_step_2_gwas.sh\
    -c "X"
        
qsub -N "regenie_st2_cXY" /home/jitame/bin/code/AICHA/03_regenie/02_gwas/regenie_step_2_gwas.sh \
    -c "XY"
        
#qsub -N "regenie_filter_st2_cXY" /home/jitame/bin/code/AICHA/genetics/regenie/regenie_prepare_step2_GWAS_select_variants.sh \
#        -i ${data_dir}/imp/ukb_imp_chrXY_v3.bgen  \
#        -b ${data_dir}/imp/ukb16066_imp_chrXY_v3_s486429.sample \
#        -o ${out_dir} \
#        -n "regenie_select_gwas_c${c}" \
#        -s ${base_out_dir}/exome_subs_plink.txt
#######

base_path=/data/clusterfs/lag/users/jitame/CONGRADS/geno/regenie/st2_out_gwas/
workspace_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/
fn=${base_path}/c*/CONGRADS_gwas_g0_pmaps_65k_multiphen_c*.regenie
cat ${fn} > ${base_path}/CONGRADS_gwas_g0_pmaps_65k_multiphen.regenie

for roi in lifg lstg; do
for i in {0..2}; do
fn=${base_path}/c*/CONGRADS_gwas_g0_pmaps_65k_c*_melodic_g0_pmap_${roi}_oic_${i}.regenie
cat ${fn} > ${base_path}/CONGRADS_gwas_g0_pmaps_65k_melodic_g0_pmap_${roi}_oic_${i}.regenie
done
done

cp ${base_path}/CONGRADS_gwas_g0_pmaps_65k_melodic_g0_pmap_*.regenie ${workspace_path}

bash /home/jitame/bin/code/CONGRADS_language/04_regenie/01_prep/regenie_prepare_step1_merge_plink.sh \
-i ${out_dir} \
-n "CONGRADS"


#####

qsub -N "reg_st1_gwas" /home/jitame/bin/code/CONGRADS_language/04_regenie/02_gwas/regenie_step_1_gwas.sh
qsub -N "reg_st1_exome" /home/jitame/bin/code/AICHA/03_regenie/03_exome/01_01_regenie_step_1_exome.sh