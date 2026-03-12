#!/bin/bash

for s in $(cat /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_N29612.txt); do
qsub -N new_tsm_${s} /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s ${s} -n 3 -f 6
done

for s in $(cat /data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_N29612.txt); do
qsub -N fslcc_${s} /home/jitame/bin/code/CONGRADS_language/00_data_prep/not_normal_ref.sh -s ${s} -n 3 -f 3
done

for s in 1355508 2588282 2998042 3890045 4158333 4267641 4833577 5093635 5305197 5404022 5850118 5879352 5925172; do
qsub -N con_mni_${s} /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s ${s} -n 3 -f 3
done

for s in $(cat /data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/UKB_template_N1000.txt); do
qsub -N con_mni_${s} /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s ${s} -n 3 -f 3
done    