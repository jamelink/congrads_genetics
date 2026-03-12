#!/bin/bash

module purge
module load fsl/6.0.3

cfs_path=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/melodic/
ws_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/

#mask_file=/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

#concatenate all subjects pmaps for a gradient
#g1_lifg=$cfs_path/g1/pmap/lifg/melodic_oIC.nii.gz
#g1_lstg=$cfs_path/g1/pmap/lstg/melodic_oIC.nii.gz
#g2_lifg=$cfs_path/g2/pmap/lifg/melodic_oIC.nii.gz
#g2_lstg=$cfs_path/g2/pmap/lstg/melodic_oIC.nii.gz

#fslmerge -t ${ws_path}/g1_pmap_oIC.nii.gz ${g1_lifg} ${g1_lstg}
#fslmerge -t ${ws_path}/g2_pmap_oIC.nii.gz ${g2_lifg} ${g2_lstg}

# Correlate pmaps with templates
#fslcc -m ${mask_file} --noabs -p 5 -t -1 ${ws_path}/g1_pmap_oIC.nii.gz ${ws_path}/g1_pmap_oIC.nii.gz > ${ws_path}/fslcc_g1_pmap.txt
#fslcc -m ${mask_file} --noabs -p 5 -t -1 ${ws_path}/g2_pmap_oIC.nii.gz ${ws_path}/g2_pmap_oIC.nii.gz > ${ws_path}/fslcc_g2_pmap.txt
#fslcc -m ${mask_file} --noabs -p 5 -t -1 ${ws_path}/g1_pmap_oIC.nii.gz ${ws_path}/g2_pmap_oIC.nii.gz > ${ws_path}/fslcc_g1_g2_pmap.txt


mask_lifg=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/mask/roi_lifg.nii.gz
mask_lstg=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/mask/roi_lstg.nii.gz

g1_lifg=$cfs_path/g1/cmap/lifg/melodic_oIC.nii.gz
g1_lstg=$cfs_path/g1/cmap/lstg/melodic_oIC.nii.gz
g2_lifg=$cfs_path/g2/cmap/lifg/melodic_oIC.nii.gz
g2_lstg=$cfs_path/g2/cmap/lstg/melodic_oIC.nii.gz


fslmerge -t ${ws_path}/lifg_oIC.nii.gz ${g1_lifg} ${g2_lifg}
fslmerge -t ${ws_path}/lstg_oIC.nii.gz ${g1_lstg} ${g2_lstg}

fslcc -m ${mask_lifg} --noabs -p 5 -t -1 ${ws_path}/lifg_oIC.nii.gz ${ws_path}/lifg_oIC.nii.gz > ${ws_path}/fslcc_lifg_cmap_all.txt
fslcc -m ${mask_lstg} --noabs -p 5 -t -1 ${ws_path}/lstg_oIC.nii.gz ${ws_path}/lstg_oIC.nii.gz > ${ws_path}/fslcc_lstg_cmap_all.txt

