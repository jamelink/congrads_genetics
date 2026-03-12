#!/bin/bash

module load fsl/6.0.3

for roi in lifg lmtg rifg rmtg; do 
flirt -in roi_${roi}_glasser_1mm.nii.gz \
 -ref $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz \
 -applyxfm -usesqform -out roi_${roi}_glasser_temp.nii.gz

 fslmaths roi_${roi}_glasser_temp.nii.gz -thr 0.3 -bin -dilM -ero -mas /data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/mask/hcp_mask.nii.gz roi_${roi}_glasser.nii.gz

 done