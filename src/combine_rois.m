function roi_nii = combine_rois(waparc_nii,wperiR_nii,wperiL_nii,out_dir)

% ROIs are combined in a specific order - later ones overwrite earlier ones
% if there is any overlap.


%% ROI file info, verify geometry, load
Vaparc = spm_vol(waparc_nii);
VperiR = spm_vol(wperiR_nii);
VperiL = spm_vol(wperiL_nii);
spm_check_orientations([Vaparc; VperiR; VperiL]);

voxel_volume = abs(det(Vaparc.mat));

Yaparc = spm_read_vols(Vaparc);
YperiR = spm_read_vols(VperiR);
YperiL = spm_read_vols(VperiL);


%% Initialize final label image and info file
% Region: 1
% Region: 2
% ...
Ylabels = zeros(size(Yaparc));
label_info = table([],{},[],[],'VariableNames', ...
	{'Label','Region','Volume_before_overlap_mm3','Volume_mm3'});
warning('off','MATLAB:table:RowsAddedExistingVars');


%% Parahippocampus, perirhinal (Freesurfer)
Ylabels(Yaparc(:)==1016) = 101;  % L parahipp
Ylabels(Yaparc(:)==2016) = 102;  % R parahipp
Ylabels(YperiL(:)>0)     = 103;  % L perirhinal, overwrites parahipp
Ylabels(YperiR(:)>0)     = 104;  % R perirhinal, overwrites parahipp

label_info.Label(end+1) = 101;
label_info.Region{end} = 'PM_L_Parahippocampus_lh_FS';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 102;
label_info.Region{end} = 'PM_R_Parahippocampus_rh_FS';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 103;
label_info.Region{end} = 'AT_L_Perirhinal_lh_FS';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 104;
label_info.Region{end} = 'AT_R_Perirhinal_rh_FS';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;



%% Compute final volumes
for h = 1:height(label_info)
	label_info.Volume_mm3(h) = sum(Ylabels(:)==label_info.Label(h)) * voxel_volume;
end


%% Done - write label image and info CSV
Vlabels = Vat;
Vlabels.pinfo(1:2) = [1;0];
Vlabels.dt(1) = spm_type('uint16');
roi_nii = fullfile(out_dir,'rois_PMAT_fs.nii');
Vlabels.fname = roi_nii;
spm_write_vol(Vlabels,Ylabels);

label_csv = fullfile(out_dir,'rois_PMAT_fs-labels.csv');
writetable(label_info,label_csv);


