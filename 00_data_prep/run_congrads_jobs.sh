#!/bin/bash

# This script loops over all subjects run CONGRADS

#sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N51924.txt
sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N50056.txt


echo "Running Glasser"
echo "\n"

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out/${s}/rstg/roi_rstg.cmaps.nii.gz" ]; then
    echo "CONGRADS ran for ${s}"
else
qsub -N "con_mni_v2_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s ${s} -n 3 -f 3


sleep 1

fi

while [ $(qstat|wc -l) -gt 500 ]
do
	echo "submitted a batch of $(qstat|wc -l) jobs"
	sleep 180
done

done

echo "\n"
echo "\n"
echo "Running AICHA "
echo "\n"

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out_AICHA/${s}/rmtg/roi_rmtg.cmaps.nii.gz" ]; then
    echo "CONGRADS ran for ${s}"
else
qsub -N "con_mni_AICHA_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni_AICHA.sh -s ${s} -n 3 -f 3

sleep 1

fi

while [ $(qstat|wc -l) -gt 450 ]
do
	echo "submitted a batch of $(qstat|wc -l) jobs"
	sleep 180
done

done



sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N50056.txt

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out/${s}/rstg/roi_rstg_procrust.nii.gz" ]; then
    echo "Procrustes ran for ${s}"
else
qsub -N "proc_align_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/align_procrustes_wrap_sub.sh ${s}

sleep 1

fi

while [ $(qstat|wc -l) -gt 450 ]
do
	echo "submitted a batch of $(qstat|wc -l) jobs"
	sleep 180
done

done


sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N50056.txt

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out_AICHA/${s}/rmtg/roi_rmtg_procrust.nii.gz" ]; then
    echo "Procrustes ran for ${s}"
else
qsub -N "proc_align_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/align_procrustes_wrap_sub_AICHA.sh ${s}

sleep 1

fi

while [ $(qstat|wc -l) -gt 450 ]
do
	echo "submitted a batch of $(qstat|wc -l) jobs"
	sleep 180
done

done


# RUN ON GRIDMASTER

sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N50056.txt

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out/${s}/rstg/roi_rstg_procrust.tsm.trendcoeff.txt" ]; then
    echo "Procrustes ran for ${s}"
else
qsub -N "proc_tcs_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni_tcs_proc.sh -s ${s} -f 3

sleep 1

fi

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out_AICHA/${s}/rmtg/roi_rmtg_procrust.tsm.trendcoeff.txt" ]; then
    echo "Procrustes ran for ${s}"
else
qsub -N "proc_tcs__AICHA_${s}" /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni_tcs_proc_AICHA.sh -s ${s} -f 3

sleep 1

fi

while [ $(qstat|wc -l) -gt 450 ]
do
	echo "submitted a batch of $(qstat|wc -l) jobs"
	sleep 180
done

done


# RUN ON LUX

sub_list=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/participant_list_imaging_gen_check_65k_N50056.txt

for s in $(cat ${sub_list}); do

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out/${s}/rstg/roi_rstg_procrust.tsm.trendcoeff.txt" ]; then
    echo "Procrustes ran for ${s}"
else
bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni_tcs_proc.sh -s ${s} -f 3

fi

if [ -f  "/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/CONGRADS_rest/out_AICHA/${s}/rmtg/roi_rmtg_procrust.tsm.trendcoeff.txt" ]; then
    echo "Procrustes ran for ${s}"
else
bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni_tcs_proc_AICHA.sh -s ${s} -f 3

fi

done







