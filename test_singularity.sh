#!/bin/bash

singularity run \
--cleanenv --contain \
--home `pwd`/INPUTS \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
--bind freesurfer_license.txt:/usr/local/freesurfer/license.txt \
makerois-PMAT_v1.0.13.simg \
tseg_niigz /INPUTS/tseg.nii.gz \
subj_dir /INPUTS/SUBJECT \
deffwd_niigz /INPUTS/y_t1.nii.gz \
wt1_niigz /INPUTS/wmt1.nii.gz \
mnigeom_nii avg152T1.nii \
project TESTPROJ \
subject TESTSUBJ \
session TESTSESS \
scan TESTSCAN \
out_dir /OUTPUTS
