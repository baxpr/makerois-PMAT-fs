function wseg_nii = warp_images( ...
	seg_nii,deffwd_nii,mnigeom_nii,interp,out_dir)

% SPM deformation job
clear job
job.comp{1}.def = {deffwd_nii};
job.comp{2}.id.space = {mnigeom_nii};
job.out{1}.pull.fnames = {seg_nii};
job.out{1}.pull.savedir.saveusr = {out_dir};
job.out{1}.pull.interp = interp;
job.out{1}.pull.mask = 0;
job.out{1}.pull.fwhm = [0 0 0];

spm_deformations(job);

% Figure out the output filename
[~,n,e] = fileparts(seg_nii);
wseg_nii = fullfile(out_dir,['w' n e]);

