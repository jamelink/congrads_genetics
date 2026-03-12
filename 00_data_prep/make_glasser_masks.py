import os
from nilearn import plotting, image
from nilearn.maskers import NiftiLabelsMasker
import numpy as np
import scipy.stats as st
import matplotlib.pyplot as plt
import nibabel as nb
import pandas as pd
from subprocess import run

"""
This script creates masks for the left and right inferior frontal gyrus and superior temporal gyrus based on the Glasser atlas. 

Inputs:
- Glasser 2021 atlas in MNI space as provided by AFNI 
- NeuroSynth association atlas results

Steps:
1. Find significant parcels associated with language by parcellating the NeuroSynth language association results
2. Make masks of associated parcels by binarizing and smoothing.
3. Show process.

Outputs:
- 2 ROI masks (lIFG, lSTG)

Written by: Jitse S. Amelink

Last edited: 2024/12/17
"""

#paths
work_path = "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/mask/"
workspace_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/"

#save masks
save_all = True

def make_mask(parcels, atlas_file, all_parcels, mask, bin_thresh="50%"):
    """
    Defines mask based on parcel nos provided as input.
    Returns nifti img
    """
    #load atlas image
    atlas_img = image.load_img(atlas_file)
    
    #get data
    roi_mask = image.get_data(atlas_img)
    
    # get brain mask
    mask = image.load_img(mask)
    
    #set parcels to 1
    print("Including parcels in mask: ", parcels)
    for i in all_parcels: # range(1, int(no_parcels+1), 1):
        if i in parcels:
            roi_mask[roi_mask == i] = np.array([1])
        else:
            roi_mask[roi_mask == i] = 0
    
    #return image
    roi_mask_img = image.new_img_like(atlas_img, roi_mask, copy_header=True)
    
    #return binarized image
    return image.binarize_img(roi_mask_img, threshold=bin_thresh, mask_img=mask)


#inputs
atlas_in = os.path.join(workspace_path, "atlas", "MNI_Glasser_HCP_v1.0.nii.gz")
lang_map = os.path.join(workspace_path, "stat_maps", "language_association-test_z_FDR_0.01_231027.nii.gz")
mask_fn_1mm = os.path.join(work_path, "mask", "MNI_tight_mask_1mm.nii.gz")
mask_fn_2mm = os.path.join(work_path, "mask", "MNI_tight_mask_2mm.nii.gz")


#load language map
atlas_img = image.load_img(atlas_in)

#getting upper threshold
p_thresh = .99999999
z_thresh = st.norm.ppf(p_thresh)

# process association map
#load masker
masker = NiftiLabelsMasker(labels_img=atlas_img)

#apply mask
association_stats = masker.fit_transform(lang_map)

#threshold non-sig parcels
association_stats[association_stats < z_thresh] = 0
print(association_stats.shape)

#load image and put values in image data. i counts from 0 and atlas from 1, so i+1
association_stat_map = image.get_data(atlas_img)
for i in range(180):
    association_stat_map[ association_stat_map == i+1 ] = association_stats[0, i]

for i in range(180, 360, 1):
    association_stat_map[ association_stat_map == i+1+820 ] = association_stats[0, i]
    
association_stat_img = image.new_img_like(atlas_img, association_stat_map, copy_header=True)


# divide into left and right
l_ifg = [x+1 for x in sig_parcels[sig_parcels < 100]]
l_stg = [x+1 for x in sig_parcels[sig_parcels > 100]]
print("Left IFG parcels:")
print(l_ifg)
print("Left STG parcels:")
print(l_stg)
    
r_ifg = [x + 1000 for x in l_ifg]
r_stg = [x + 1000 for x in l_stg]

all_parcels = list(range(1, 181, 1))
all_parcels = all_parcels + [x+1000 for x in all_parcels]

#make masks
print("Making masks")
l_ifg_mask = make_mask(parcels = l_ifg, atlas_file = atlas_in, mask=mask_fn, smooth_mm = 0, bin_thresh = "50%", all_parcels = all_parcels)
l_stg_mask = make_mask(parcels = l_stg, atlas_file = atlas_in, mask=mask_fn, smooth_mm = 0, bin_thresh = "50%", all_parcels = all_parcels)
r_ifg_mask = make_mask(parcels = r_ifg, atlas_file = atlas_in, mask=mask_fn, smooth_mm = 0, bin_thresh = "50%", all_parcels = all_parcels)
r_stg_mask = make_mask(parcels = r_stg, atlas_file = atlas_in, mask=mask_fn, smooth_mm = 0, bin_thresh = "50%", all_parcels = all_parcels)

#save masks
if save_all:
    l_ifg_mask.to_filename(os.path.join(work_path, "roi_lifg_glasser_1mm.nii.gz"))
    l_stg_mask.to_filename(os.path.join(work_path, "roi_lstg_glasser_1mm.nii.gz")) 
    r_ifg_mask.to_filename(os.path.join(work_path, "roi_rifg_glasser_1mm.nii.gz"))
    r_stg_mask.to_filename(os.path.join(work_path, "roi_rstg_glasser_1mm.nii.gz"))

print("Register masks to 2 mm MNI space")

cmd = "module load fsl/6.0.3"
run(cmd, shell=True)

for roi in ["lifg", "lstg", "rifg", "rstg"]:
    cmd = "flirt -in {work_path}/roi_{roi}_glasser_1mm.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out {work_path}/roi_{roi}_glasser_temp.nii.gz"
    run(cmd, shell=True)

    cmd = "fslmaths {work_path}/roi_{roi}_glasser_temp.nii.gz -thr 0.3 -bin -dilM -ero -mas {mask_fn} {work_path}/roi_{roi}_glasser.nii.gz"
    run(cmd, shell=True)

print("Make figure")
#explain process in figures
fig_args = {"figsize":(10,16),"dpi":400}

fig, ax = plt.subplots(7, 1, gridspec_kw={'height_ratios': [1]*7}, **fig_args)

fig.suptitle("Mask derivation in steps", y=0.93, fontsize=24)

plotting.plot_roi(image.load_img(atlas_in), title="1. Glasser atlas", axes=ax[0])
plotting.plot_glass_brain(image.load_img(lang_map), display_mode='lyrz', colorbar=True, cmap='coolwarm',
                                        title="2. Language association map from NeuroSynth", axes=ax[1])
plotting.plot_glass_brain(association_stat_img, display_mode='lyrz', colorbar=True, cmap='coolwarm', plot_abs=False,
                                        title="3. Language-associated parcels of Glasser atlas", axes=ax[2])
plotting.plot_glass_brain(image.load_img(os.path.join(work_path, "roi_lifg_glasser.nii.gz")), display_mode='lyrz', colorbar=True, cmap='coolwarm', plot_abs=False,
                                        title="4a. ROI mask for left inferior frontal gyrus", axes=ax[3])
plotting.plot_glass_brain(image.load_img(os.path.join(work_path, "roi_lstg_glasser.nii.gz")), display_mode='lyrz', colorbar=True, cmap='coolwarm', plot_abs=False,
                                        title="4b. ROI mask for left superior temporal gyrus", axes=ax[4])
plotting.plot_glass_brain(image.load_img(os.path.join(work_path, "roi_rifg_glasser.nii.gz")), display_mode='lyrz', colorbar=True, cmap='coolwarm', plot_abs=False,
                                        title="4c. ROI mask for right inferior frontal gyrus", axes=ax[5])
plotting.plot_glass_brain(image.load_img(os.path.join(work_path, "roi_rstg_glasser.nii.gz")), display_mode='lyrz', colorbar=True, cmap='coolwarm', plot_abs=False,
                                        title="4d. ROI mask for right superior temporal gyrus", axes=ax[6])

if save_all:
    plt.savefig(fname="/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/results/mask_derivation_glasser.png", bbox_inches="tight")

print("Done")