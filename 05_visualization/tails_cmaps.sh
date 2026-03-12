#!/bin/bash

module purge
module load fsl/6.0.3

ws_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/
base_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data

mkdir -p $ws_path/tails

for fn in $(ls ${ws_path}/tails_cmaps/melodic_g1_cmap_*.txt); do
    mask=$(basename "$fn" .txt | cut -c 17-20)
    base_fn=$(basename "$fn" .txt)
    new_fn_file=${ws_path}/tails_cmaps/${base_fn}_files.txt
    rm $new_fn_file

    for sub in $(cat $fn); do
        sub=$(echo "$sub" | tr -d '\n\r' | xargs)
        sub=$(basename "$sub" | cut -d'/' -f1)
        cmap_new=${base_dir}/CONGRADS_rest/out/${sub}/${mask}/roi_${mask}_aligned_1_cmap_new.nii.gz
        echo $cmap_new >> $new_fn_file
    done

    fslmerge -t ${ws_path}/tails_cmaps/${base_fn}.nii.gz $(cat ${new_fn_file})
    fslmaths ${ws_path}/tails_cmaps/${base_fn}.nii.gz -Tmean ${ws_path}/tails_cmaps/${base_fn}_mean.nii.gz
    fslmaths ${ws_path}/tails_cmaps/${base_fn}.nii.gz -Tmedian ${ws_path}/tails_cmaps/${base_fn}_median.nii.gz
    
done


for fn in $(ls ${ws_path}/tails_cmaps/melodic_g1_cmap_*.txt); do
    mask=$(basename "$fn" .txt | cut -c 17-20)
    base_fn=$(basename "$fn" .txt)
    new_fn_file=${ws_path}/tails/${base_fn}_files.txt
    rm $new_fn_file

    for sub in $(cat $fn); do
        sub=$(echo "$sub" | tr -d '\n\r' | xargs)
        sub=$(basename "$sub" | cut -d'/' -f1)
        cmap_new=${base_dir}/CONGRADS_rest/out/${sub}/${mask}/roi_${mask}_aligned_1_pmap_new.nii.gz
        echo $cmap_new >> $new_fn_file
    done

    fslmerge -t ${ws_path}/tails_cmaps/${base_fn}_pmap.nii.gz $(cat ${new_fn_file})
    fslmaths ${ws_path}/tails_cmaps/${base_fn}_pmap.nii.gz -Tmean ${ws_path}/tails_cmaps/${base_fn}_pmap_mean.nii.gz
    fslmaths ${ws_path}/tails_cmaps/${base_fn}_pmap.nii.gz -Tmedian ${ws_path}/tails_cmaps/${base_fn}_pmap_median.nii.gz
    
done



for fn in $(ls ${ws_path}/tails_cmaps/g2/melodic_g2_cmap_*.txt); do
    mask=$(basename "$fn" .txt | cut -c 17-20)
    base_fn=$(basename "$fn" .txt)
    new_fn_file=${ws_path}/tails_cmaps/g2/${base_fn}_files.txt
    rm $new_fn_file

    for sub in $(cat $fn); do
        sub=$(echo "$sub" | tr -d '\n\r' | xargs)
        sub=$(basename "$sub" | cut -d'/' -f1)
        cmap_new=${base_dir}/CONGRADS_rest/out/${sub}/${mask}/roi_${mask}_aligned_2_cmap_new.nii.gz
        echo $cmap_new >> $new_fn_file
    done

    fslmerge -t ${ws_path}/tails_cmaps/${base_fn}.nii.gz $(cat ${new_fn_file})
    fslmaths ${ws_path}/tails_cmaps/${base_fn}.nii.gz -Tmean ${ws_path}/tails_cmaps/${base_fn}_mean.nii.gz
    fslmaths ${ws_path}/tails_cmaps/${base_fn}.nii.gz -Tmedian ${ws_path}/tails_cmaps/${base_fn}_median.nii.gz
    
done


for fn in $(ls ${ws_path}/tails_cmaps/g2/melodic_g2_cmap_*.txt); do
    mask=$(basename "$fn" .txt | cut -c 17-20)
    base_fn=$(basename "$fn" .txt)
    new_fn_file=${ws_path}/tails_cmaps/g2/${base_fn}_pmap_files.txt
    rm $new_fn_file

    for sub in $(cat $fn); do
        sub=$(echo "$sub" | tr -d '\n\r' | xargs)
        sub=$(basename "$sub" | cut -d'/' -f1)
        cmap_new=${base_dir}/CONGRADS_rest/out/${sub}/${mask}/roi_${mask}_aligned_2_pmap_new.nii.gz
        echo $cmap_new >> $new_fn_file
    done

    fslmerge -t ${ws_path}/tails_cmaps/g2/${base_fn}_pmap.nii.gz $(cat ${new_fn_file})
    fslmaths ${ws_path}/tails_cmaps/g2/${base_fn}_pmap.nii.gz -Tmean ${ws_path}/tails_cmaps/g2/${base_fn}_pmap_mean.nii.gz
    fslmaths ${ws_path}/tails_cmaps/g2/${base_fn}_pmap.nii.gz -Tmedian ${ws_path}/tails_cmaps/g2/${base_fn}_pmap_median.nii.gz
    
done

for fn in $(ls ${ws_path}/tails_cmaps/g2/melodic_*_pmap.nii.gz ); do
    echo "Processing file: $fn"
    # Extract the base name without the path and extension
    base_name=$(basename "$fn" .nii.gz)
    
    # Apply the transformation using fslmaths
    fslmaths "$fn" -Tstd ${ws_path}/tails_cmaps/${base_name}_Tstd.nii.gz
    fslmaths "$fn" -Tmin ${ws_path}/tails_cmaps/${base_name}_Tmin.nii.gz
    fslmaths "$fn" -Tmax ${ws_path}/tails_cmaps/${base_name}_Tmax.nii.gz
    
done