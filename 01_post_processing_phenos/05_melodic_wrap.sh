#!/bin/sh
#$ -cwd
#$ -q fullnode15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs
#$ -o /home/jitame/bin/logs
#$ -M Jitse.Amelink@mpi.nl
#$ -m e

#usage: bash /home/jitame/bin/code/CONGRADS_language/01_post_processing_phenos/05_melodic_wrap.sh <roi> <g> <map>

roi=$1
g=$2
map=$3

module purge
module load fsl/6.0.3
module load openblas
module load gcc

export FSLOUTPUTTYPE=NIFTI2_GZ
base_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest

out_path=${base_dir}/melodic/g${g}/${map}/${roi}

roi_dir=${base_dir}/mask
if [ ${map} == "cmap" ]; then
    mask_file=roi_${roi}.nii.gz
elif [ ${map} == "pmap" ]; then
    mask_file=roi_${roi}_pmap.nii.gz
fi

mask=${roi_dir}/${mask_file}
merged_file=${out_path}/all_data_${roi}_g${g}_${map}

melodic -i ${merged_file}_template.nii.gz \
    -o ${out_path}/ \
    --nobet \
    --verbose \
    -m ${mask} \
    --vn \
    --migpN=500 \
    --migp_factor=4 \
    --Opca \
    --Oall \
    -d 3


echo "4. Running fsl_glm ICA"
fsl_glm -i ${merged_file}_template.nii.gz -d $out_path/melodic_oIC -m $mask -o $out_path/oic_weights_template.txt
fsl_glm -i ${merged_file}_non_template.nii.gz -d $out_path/melodic_oIC -m $mask -o $out_path/oic_weights_non_template.txt

echo "5. Running fsl_glm PCA"
fsl_glm -i ${merged_file}_template.nii.gz -d $out_path/melodic_pca -m $mask -o $out_path/pc_weights_template.txt
fsl_glm -i ${merged_file}_non_template.nii.gz -d $out_path/melodic_pca -m $mask -o $out_path/pc_weights_non_template.txt

#concatenate
cat $out_path/oic_weights_template.txt $out_path/oic_weights_non_template.txt > $out_path/oic_weights_all.txt
cat $out_path/pc_weights_template.txt $out_path/pc_weights_non_template.txt > $out_path/pc_weights_all.txt