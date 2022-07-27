function makerois_main(inp)


%% SPM init
spm_jobman('initcfg')


%% Get reference geometry
mnigeom_nii = which(inp.mnigeom_nii);


%% Copy files to working directory with consistent names and unzip
disp('File prep')
[tseg_nii,deffwd_nii,aparc_nii,periR_nii,periL_nii,at_nii,pm_nii] = prep_files(inp);


%% Warp/resample ROIs to MNI space
disp('Warping')
wtseg_nii = warp_images(tseg_nii,deffwd_nii,mnigeom_nii,0,inp.out_dir);
waparc_nii = warp_images(aparc_nii,deffwd_nii,mnigeom_nii,0,inp.out_dir);
wperiR_nii = warp_images(periR_nii,deffwd_nii,mnigeom_nii,0,inp.out_dir);
wperiL_nii = warp_images(periL_nii,deffwd_nii,mnigeom_nii,0,inp.out_dir);
wat_nii = reslice_images(at_nii,wtseg_nii,0);
wpm_nii = reslice_images(pm_nii,wtseg_nii,0);


%% Combine desired ROIs into single image
roi_nii = combine_rois(wtseg_nii,waparc_nii,wperiR_nii,wperiL_nii, ...
	wat_nii,wpm_nii,inp.out_dir);


%% Make output PDF
system([ ...
        'OUTDIR='   inp.out_dir ' ' ...
        'FSLDIR='   inp.fsl_dir ' ' ...
        'IMMAGDIR=' inp.immag_dir ' ' ...
        'PROJECT='  inp.project ' ' ...
        'SUBJECT='  inp.subject ' ' ...
        'SESSION='  inp.session ' ' ...
        'SCAN='     inp.scan ' ' ...
		'WSEG_NII=' roi_nii ' ' ...
        'WT1_NII='  inp.wt1_niigz ' ' ...
        'MNI_NII='  mnigeom_nii ' ' ...
         inp.src_dir '/make_pdf.sh' ...
        ]);


%% Zip output images
system(['gzip ' roi_nii]);


%% Clean up
%delete([inp.out_dir '/*.png']);
%delete([inp.out_dir '/*.nii']);


%% Exit
if isdeployed
	exit
end

