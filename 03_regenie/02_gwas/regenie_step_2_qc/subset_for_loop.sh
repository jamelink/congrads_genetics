ssh #!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -m eas
#$ -N subset_snpstats
#$ -q single15.q


for c in {1..22}; do
qsub -N "subset_50k_c${c}" /home/jitame/bin/code/CONGRADS_language/04_regenie/02_gwas/regenie_step_2_qc/imaging40k_subset_and_snpstats.sh -c ${c}
done

#/home/jitame/bin/code/AICHA/genetics/regenie/gwas/imaging40k_subset_and_snpstats.sh \
#-s /home/jitame/bin/code/AICHA/genetics/regenie/gwas/imaging40k_subset_and_snpstats_config.txt 

for c in {1..22}; do
qsub -N "variant_qc_65k_c${c}"  /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_qc/variant_qc_wrapper.sh -c ${c}
done

for c in {1..22}; do
qsub -N "CONGRADS_GWAS_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas.sh -c ${c}
done

for c in X XY; do
qsub -N "CONGRADS_GWAS_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas.sh -c ${c}
done



#G1 MULTIPHEN
for c in {1..22}; do
qsub -N "CONGRADS_GWAS_multi_cmap_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_cmap.sh  -c ${c}
done

c=X
qsub -N "CONGRADS_GWAS_multi_cmap_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_cmap.sh -c ${c}

c=XY
qsub -N "CONGRADS_GWAS_multi_cmap_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_cmap.sh  -c ${c}


#G2 MULITPHEN
for c in {1..22}; do
qsub -N "CONGRADS_GWAS_multi_g2_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_g2.sh -c ${c}
done

c=X
qsub -N "CONGRADS_GWAS_multi_g2_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_g2.sh -c ${c}

c=XY
qsub -N "CONGRADS_GWAS_multi_g2_c${c}" /home/jitame/bin/code/CONGRADS_language/03_regenie/02_gwas/regenie_step_2_gwas_multi_g2.sh -c ${c}