#!/bin/sh

base_dir=/data/clusterfs/lag/users/jitame/CONGRADS
wrapper=/home/jitame/bin/code/CONGRADS_language/03_GCTA/01_run_heritability_new.sh

mkdir -p $base_dir/geno/gcta/final/
cd

#for fn in  ${base_dir}/pheno/congrads_tcs_pcs_N34545_resid_norm_N34529.tsv; do
#echo $fn

fn=${base_dir}/pheno/all_idps_congrads_new_resid_norm_N46267.tsv


for i in {1..96}; do
  out_hsq="$base_dir/geno/gcta//final/congrads_${i}.hsq"
  if [ -f ${out_hsq} ]; then
  echo "${out_hsq} exists"
  else
  echo "${out_hsq} does not exist"
qsub -q fullnode15.q -p -5 -N gcta_congrads_${i} $wrapper -f $fn -n $i -c $base_dir/geno/gcta/congrads_${i}
#bash $wrapper -f $fn -n $i -c $base_dir/geno/gcta/final/congrads_${i}
  fi
done
