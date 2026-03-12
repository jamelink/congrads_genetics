#!/bin/bash
#$ -cwd
#$ -q multi15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs
#$ -o /home/jitame/bin/logs
#$ -M Jitse.Amelink@mpi.nl
#$ -N split_cmaps
#$ -m e
# This script splits the cmaps and selects correct ones
# Last edit: Amelink, J.S., 2025-12-16

#for roi in lifg lstg; do for grad_no in 1 2; do
#qsub -N split_cmaps_${roi} /home/jitame/bin/code/CONGRADS_language/01_post_processing_phenos/split_cmaps.sh ${roi} ${grad_no}


# Load the modules
module load fsl/6.0.3
mask=$1
grad_no=$2
# Set the paths
base_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data
sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_new_65k_N46417.txt
i=0
qc_outputs=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/qc_outputs_${mask}_g${grad_no}.txt
zero_templates=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/zero_templates_${mask}_g${grad_no}.txt
missed_subs=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/missed_templates_${mask}_g${grad_no}.txt
mask_file=${base_dir}/CONGRADS_rest/mask/roi_${mask}.nii.gz

template=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/template/${mask}/roi_${mask}.cmaps.nii.gz

echo "Selecting cmaps for template for mask ${mask}"
for sub in $(cat $sub_list); do
    
        out_dir=$base_dir/CONGRADS_rest/out/${sub}/${mask}
        cmap=${out_dir}/roi_${mask}.cmaps.nii.gz
        cmap_sim=${out_dir}/cmap_sim_new.txt
        cmap_new=${out_dir}/roi_${mask}_aligned_${grad_no}_cmap_new.nii.gz

        fslcc -m ${mask_file} --noabs -p 5 -t -1 ${cmap} ${template} > ${cmap_sim}

        #if [[ -f ${cmap_new} ]]; then
            #echo "Aligned CMAP file already exists for ${sub} and ${mask}. Skipping..."
        #    continue
        #else 
        #    echo "${sub} ${mask}" >> $missed_subs
        #fi
    #done
#done 


    # split cmaps
        cd $out_dir

    # read which cmap most associated
        max_corr_abs=0
        best_template=""

        while read -r sub_map_num template_num corr; do
            if [[  $template_num -eq ${grad_no} ]]; then
                abs_corr=$(echo $corr | awk '{print ($1 >= 0) ? $1 : -$1}')
                if (( $(echo "$abs_corr > $max_corr_abs" | bc -l) )); then
                    max_corr_abs=$abs_corr
                    max_corr=$corr
                    best_template=$sub_map_num
                fi
            fi
        done < $cmap_sim

        #subtract 1 for cmap
        if (( $( echo "$max_corr_abs < 0.3" | bc -l) )); then
            echo "Max correlation too low for ${sub} and ${mask}. Skipping..."
            echo "${sub} ${mask}" >> $zero_templates
            continue
        elif [[ -z ${best_template} ]]; then
            echo "No best template found for ${sub} and ${mask}. Skipping..."
            echo "${sub} ${mask}" >> $zero_templates
            continue
        elif [[ ${best_template} -eq 0 ]]; then
            echo "No valid template found for ${sub} and ${mask}. Skipping..."
            ${sub} >> $zero_templates
            continue
        else
            best_no=$(($best_template-1))
        fi
        
        echo "Best matching cmap for ${sub} and ${mask} is number ${best_template} for gradient ${grad_no} with correlation ${max_corr}" >> ${qc_outputs}
        echo "Best matching cmap for ${sub} and ${mask} is number ${best_template} for gradient ${grad_no} with correlation ${max_corr}"

        rm -f vol000*.nii.gz

        #split cmaps
        fslsplit $cmap

        #rename and multiply with -1 if necessary
        if (( $( echo "$max_corr < 0" | bc -l) )); then
            fslmaths vol000${best_no}.nii.gz -mul -1 $cmap_new
        else
            mv vol000${best_no}.nii.gz $cmap_new
        fi

        rm -f vol000*.nii.gz  # Clean up split files

i=$(($i+1))

done
#done

echo "Selecting cmaps done. Good luck with the analyses!"
"""