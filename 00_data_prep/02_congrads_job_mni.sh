#!/bin/bash
#$ -cwd
#$ -q multi15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas

usage(){
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   echo "This script is the resting state pipeline for deriving subject-specific connectopic map in data that has been warped to MNI-space."
   echo " "
   echo " "
   echo "Usage: bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh  -s <subid> -n 3 -f 3"
   echo -e "\t-s Subject ID."
   echo -e "\t-n Nummber of connectopic maps to be derived."
   echo -e "\t-f Spatial order for trend surface models."
   echo -e "\t-h Show help."
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N con_mni_<sub> /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s <subid>  -n 3 -f 3"
   echo " "
   echo "Last update: Jitse Amelink. Oct 31 2023"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}


while getopts "s:n:f:"  opt
do
   case "$opt" in
	  s ) sub="$OPTARG" ;;
      n ) n_grads="$OPTARG" ;;
      f ) spat_ord="$OPTARG" ;;
      ? ) usage ;; 
   esac
done

module unload python
module load fsl/6.0.3

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 

printf "Start CONGRADS MNI pipeline for subject: ${sub} \n"

#specify directories
base_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/
rs_data=${base_dir}/FLICA_multimodal/fMRI/${sub}/filtered_func_data_clean_standard_s2_5.nii.gz
mni_mask=/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
congrads_wrap=/home/jitame/bin/software/congrads/congrads

#specify paths
base_path="/data/clusterfs/lag/projects/lg-ukbiobank/primary_data/imaging_data"
rs_out_path="/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/fMRI/${sub}"

#data
cleaned_rs_data=${base_path}/${sub}/fMRI/rfMRI.ica/filtered_func_data_clean.nii.gz
mni_mask="/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask.nii.gz"
mni="/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain.nii.gz"

#warps
rs2mni_mat=${base_path}/${sub}/fMRI/rfMRI.ica/reg/example_func2standard.mat
rs2mni_warp=${base_path}/${sub}/fMRI/rfMRI.ica/reg/example_func2standard_warp.nii.gz
example_rs_ref=${base_path}/${sub}/fMRI/rfMRI.ica/reg/example_func2standard.nii.gz

#naming
symlink_rs_data=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/rfMRIreg/${sub}/fMRI/rfMRI.ica/reg/filtered_func_data_clean_standard.nii.gz
mni_rs_data=${rs_out_path}/filtered_func_data_clean_standard.nii.gz

#preprocessing settings
sigma=2.5

#tr_value = 0.735
#hp_freq = 0.01
#hp_sigma = round(1/(2*hp_freq*tr_value), 0)
#smoothing_in_mm = 5
#round(smoothing_in_mm/2.3548, 4)

# --------------------------- #
### PIPELINE ###
# ---------------------------#


### PREP DATA ###
#make path
printf "0. Making path. \n"
mkdir -p $rs_out_path

#WARPING
if [ -f "${mni_rs_data}" ]; then
    printf "1. Warped data: ${mni_rs_data} already exists. \n"
elif [ -f "${symlink_rs_data}" ]; then
   printf "1. Warped data already exists elsewhere: ${symlink_rs_data} already exists. Symlinking to earlier data. \n"
    ln -s ${symlink_rs_data} ${mni_rs_data}
else
    printf "1. Applying warp. \n"
    applywarp --ref=${mni} --in=${cleaned_rs_data} --warp=${rs2mni_warp} --out=${mni_rs_data}
fi

#SMOOTHING
if [ -f "${rs_data}" ]; then
    printf "2. Smoothed data: ${rs_data} already exists. \n"
else
    printf "2. Smoothing with sigma: ${sigma}. \n"
    fslmaths ${mni_rs_data} -kernel gauss ${sigma} -fmean ${rs_data}
fi


if [ ! -f ${rs_data} ]; then
echo "Resting state data does not exist for ${sub}. Exiting."
#exit 1
fi


cd /home/jitame/bin/software/congrads/

#TODO:
for mask in lifg lstg rifg rstg; do

#set files:
mask_file=roi_${mask}.nii.gz
roi=${base_dir}/CONGRADS_rest/mask/${mask_file}
out_dir=$base_dir/CONGRADS_rest/out/${sub}/${mask}/
cmaps=${out_dir}/roi_${mask}.cmaps.nii.gz

#mkdir -p $out_dir

#1. RUN CONMAP
#cd /home/jitame/bin/software/congrads/
#congrads_wrap -i ${rs_data} -r ${roi} -m ${mni_mask} -o $out_dir -n $n_grads -s -p

#4. trend surface models
#congrads_wrap -i ${cmaps} -r ${roi} -o ${out_dir} -F ${spat_ord}

done

now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Total time is ${runtime} minutes.\n\n"


