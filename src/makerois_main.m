function makerois_main(inp)


%% SPM init
spm_jobman('initcfg')


%% Get reference geometry
mnigeom_nii = which(inp.mnigeom_nii);


%% Copy files to working directory with consistent names and unzip
disp('File prep')
[deffwd_nii,aparc_nii] = prep_files(inp);


%% Warp/resample ROIs to MNI space
disp('Warping')
waparc_nii = warp_images(aparc_nii,deffwd_nii,mnigeom_nii,0,inp.out_dir);


%% Combine desired ROIs into single image
roi_nii = combine_rois(waparc_nii,inp.out_dir);


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


%% Exit
if isdeployed
	exit
end

