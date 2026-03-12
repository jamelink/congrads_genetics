#!/bin/bash
#$ -cwd
#$ -q multi15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas
#$ -p -5

#usage: for roi in lifg rifg lstg rstg; do qsub -N "fslcc_${roi}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/run_cmaps.sh ${roi}; done


module purge
module load fsl/6.0.3
main_path=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest

roi=$1

echo "Running ${roi}..."

ref_maps=${main_path}/template/${roi}/roi_${roi}.cmaps.nii.gz  

for s in $(ls $main_path/out ); do
out_dir=$main_path/out/${s}/${roi}
cmaps_sub=${main_path}/out/${s}/${roi}/roi_${roi}.cmaps.nii.gz
cmap_sim=${out_dir}/cmap_sim.txt

if [ -f "${cmap_sim}" ]; then
echo "CMAP SIM exists for ${s} and ${roi}"

else
echo "Running CMAP SIM for ${s} and ${roi}"
fslcc  --noabs -p 5 -t -1 ${cmaps_sub} ${ref_maps} > ${cmap_sim}

fi

done