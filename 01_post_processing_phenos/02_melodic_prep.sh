#!/bin/sh
#$ -cwd
#$ -q fullnode15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs
#$ -o /home/jitame/bin/logs
#$ -M Jitse.Amelink@mpi.nl
#$ -m e

#usage: bash /home/jitame/bin/code/CONGRADS_language/01_post_processing_phenos/02_melodic_prep.sh <roi> <g> <map>

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
mkdir -p ${out_path}

file_list_out=${out_path}/file_list.txt
file_list_template=${out_path}/file_list_template.txt
file_list_non_template=${out_path}/file_list_non_template.txt

roi_dir=${base_dir}/mask
if [ ${map} == "cmap" ]; then
    mask_file=roi_${roi}.nii.gz
elif [ ${map} == "pmap" ]; then
    mask_file=roi_${roi}_pmap.nii.gz
fi

mask=${roi_dir}/${mask_file}
merged_file=${out_path}/all_data_${roi}_g${g}_${map}

rm ${file_list_out}
#get file_list
echo "Getting file list"
#echo "ls -1 ${base_dir}/out/*/${roi}/*_aligned_*_${map}_new.nii.gz > ${file_list_out}"
ls -1 ${base_dir}/out/1*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
ls -1 ${base_dir}/out/2*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
ls -1 ${base_dir}/out/3*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
ls -1 ${base_dir}/out/4*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
ls -1 ${base_dir}/out/5*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
ls -1 ${base_dir}/out/6*/${roi}/roi_${roi}_aligned_${g}_${map}_new.nii.gz  >> ${file_list_out}
#echo "find -type f -name "${base_dir}/out/*/${roi}/*_aligned_*_${map}_new.nii.gz" > ${file_list_out}"
echo "File list has length: $(cat ${file_list_out})"

shuf -n $(($(wc -l < ${file_list_out}) / 4)) ${file_list_out} | sort > ${file_list_template}
comm -23 <(sort ${file_list_out}) <(sort ${file_list_template}) > ${file_list_non_template}

echo "Number of files in template: $(wc -l < ${file_list_template})"
echo "Number of files in non-template: $(wc -l < ${file_list_non_template})"

#2. merge files
echo "2. Run fslmerge"
fslmerge -t ${merged_file}_raw_template.nii.gz $(cat ${file_list_template})
fslmerge -t ${merged_file}_raw_non_template.nii.gz $(cat ${file_list_non_template})

echo "3. Run fslmaths mean + std"
fslmaths ${merged_file}_raw_template.nii.gz -nan ${merged_file}_template
fslmaths ${merged_file}_raw_non_template.nii.gz -nan ${merged_file}_non_template
fslmaths ${merged_file}_template.nii.gz -Tmean ${merged_file}_mean
fslmaths ${merged_file}_template.nii.gz -Tstd ${merged_file}_std
