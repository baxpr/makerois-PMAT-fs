function makerois(varargin)


%% Parse inputs
P = inputParser;

% Freesurfer aparc
addOptional(P,'aparc_mgz','../INPUTS/aparc.a2009s+aseg.mgz');

% Forward SPM deformation field from native to atlas, cat12 DEF_FWD
addOptional(P,'deffwd_niigz','../INPUTS/y_t1.nii.gz');

% Already-warped subject T1, cat12 BIAS_NORM
addOptional(P,'wt1_niigz','../INPUTS/wmt1.nii.gz');

% Output geometry ('avg152T1.nii' or 'TPM.nii')
addOptional(P,'mnigeom_nii','avg152T1.nii')

% Subject info if on XNAT
addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

% Output location
addOptional(P,'out_dir','../OUTPUTS');

% Change paths to match test environment if needed
addOptional(P,'fs_dir','/usr/local/freesurfer');
addOptional(P,'fsl_dir','/usr/local/fsl');
addOptional(P,'src_dir','/opt/makerois/src');
addOptional(P,'immag_dir','/usr/bin');


%% Parse and process
parse(P,varargin{:});
disp(P.Results)

makerois_main(P.Results)

