#!/bin/bash
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
   echo "This script is the resting state pipeline for deriving subject-specific connectopic map in data that has been warped to MNI-space in the HCP dataset."
   echo " "
   echo " "
   echo "Usage: bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/congrads_grouphug_ukb.sh ${roi} 3 3"
   echo -e "\t-s Subject ID."
   echo -e "\t-n Nummber of connectopic maps to be derived."
   echo -e "\t-f Spatial order for trend surface models."
   echo -e "\t-h Show help."
   echo " "
   echo "-- Cluster use (fullnode15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N con_ukb_template_${roi} /home/jitame/bin/code/CONGRADS_language/00_data_prep/congrads_grouphug_ukb.sh ${roi} 3 3"
   echo " "
   echo "Last update: Jitse Amelink. Dec 18 2024"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}

now=$( date )
start=`date +%s`
echo "Start at ${start}" 

roi=$1
n_grads=$2
spat_order=$3

#while getopts "n:m:f:c"  opt
#do
#   case "$opt" in
#      n ) n_grads="$OPTARG" ;;
#      m ) roi="$OPTARG" ;;
#      f ) spat_ord="$OPTARG" ;;
#      c ) atlas="$OPTARG" ;;
#      ? ) usage ;; 
#   esac
#done

#for roi in lifg lstg; do
#qsub -N con_ukb_temp_${roi} /home/jitame/bin/code/CONGRADS_language/00_data_prep/congrads_grouphug_ukb.sh ${roi} 3 3"
#done

#specify directories
base_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/
rs_data=${base_dir}/FLICA_multimodal/fMRI/${sub}/filtered_func_data_clean_standard_s2_5.nii.gz
mni_mask=/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
congrads_wrap=/home/jitame/bin/software/congrads/congrads
out_dir=${base_dir}/CONGRADS_rest/template_eigv/${roi}/

mkdir -p $out_dir

module load fsl/6.0.3

cd /home/jitame/bin/software/congrads/

mkdir -p $out_dir

roi_mask=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/mask/roi_${roi}.nii.gz
subjectlist=${base_dir}/CONGRADS_rest/UKB_template_N1000.txt
#subjectlist=${base_dir}/CONGRADS_rest/UK_test.txt
command_file=${out_dir}/congrads_command.sh

mkdir -p $out_dir
    
    rm $command_file
    echo "$congrads_wrap \\" >> $command_file
    
while read -r sub; do
if [ -f ${base_dir}/FLICA_multimodal/fMRI/${sub}/filtered_func_data_clean_standard_s2_5.nii.gz ]; then
    echo "-i ${base_dir}/FLICA_multimodal/fMRI/${sub}/filtered_func_data_clean_standard_s2_5.nii.gz \\" >> $command_file
else
    echo "No resting state data for ${sub}"
    bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh  -s ${sub} -n 3 -f 3
    echo "${sub}" >> ${base_dir}/CONGRADS_rest/UK_new_missing.txt
fi
done < $subjectlist
echo "-r $roi_mask -m $mni_mask -o $out_dir -n $n_grads -s -p" >> $command_file

bash $command_file
#done


now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Total time is ${runtime} minutes.\n\n"


