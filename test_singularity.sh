#!/bin/bash

singularity run \
--cleanenv --contain \
--home `pwd`/INPUTS \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
--bind freesurfer_license.txt:/usr/local/freesurfer/license.txt \
makerois-PMAT-fs_v1.0.0-beta1.sif \
aparc_mgz /INPUTS/aparc.a2009s+aseg.mgz \
deffwd_niigz /INPUTS/y_t1.nii.gz \
wt1_niigz /INPUTS/wmt1.nii.gz \
mnigeom_nii avg152T1.nii \
project TESTPROJ \
subject TESTSUBJ \
session TESTSESS \
scan TESTSCAN \
out_dir /OUTPUTS
