base_dir=/data/clusterfs/lag/users/jitame/CONGRADS

out_path=/data/clusterfs/lag/users/jitame/CONGRADS/geno/pgs/prs_estim/


for input_ma in $(ls /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/gwas_summary/all_sums_pgs/*.ma); do
pheno_name=$(basename ${input_ma})
pheno_name=${pheno_name::-3}
echo $pheno_name

mkdir -p $out_path/$pheno_name

for i in {1..22};
do
qsub -N "prs_cs_${pheno_name}_${i}" /home/jitame/bin/code/CONGRADS_language/04_pgs/02_prs_1.sh -f /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/gwas_summary/all_sums_pgs/$pheno_name.ma -n $(cat /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/gwas_summary/all_sums_N/${pheno_name}_eff_N.txt) -o $out_path/${pheno_name}/${pheno_name} -c $i 
done

done



## ================================================================================== ##

#PRS 2

base_dir=/data/clusterfs/lag/users/jitame/CONGRADS

for input in adhd asd dyslexia ea hand read scz; do

mkdir -p $base_dir/geno/pgs/prs_out/${input}
for i in {1..22}; do
qsub -N "prs_2_${input}_${i}" /home/jitame/bin/code/CONGRADS_language/04_pgs/03_prs_2.sh -f ${base_dir}/geno/pgs/prs_estim/${input}/${input}_pst_eff_a1_b0.5_phi1e-02_chr${i}.txt -n ${base_dir}/geno/pgs/prs_out/${input}/${input}_prs_chr${i} -c $i 
done
done

