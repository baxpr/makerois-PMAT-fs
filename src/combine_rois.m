function roi_nii = combine_rois(wtseg_nii,waparc_nii,wperiR_nii,wperiL_nii, ...
	at_nii,pm_nii,out_dir)

% ROIs are combined in a specific order - later ones overwrite earlier ones
% if there is any overlap.


%% ROI file info, verify geometry, load
Vtseg = spm_vol(wtseg_nii);
Vaparc = spm_vol(waparc_nii);
VperiR = spm_vol(wperiR_nii);
VperiL = spm_vol(wperiL_nii);
Vat = spm_vol(at_nii);
Vpm = spm_vol(pm_nii);
spm_check_orientations([Vtseg; Vaparc; VperiR; VperiL; Vat; Vpm]);

voxel_volume = abs(det(Vtseg.mat));

Ytseg = spm_read_vols(Vtseg);
Yaparc = spm_read_vols(Vaparc);
YperiR = spm_read_vols(VperiR);
YperiL = spm_read_vols(VperiL);
Yat = spm_read_vols(Vat);
Ypm = spm_read_vols(Vpm);


%% Initialize final label image and info file
% AT and PM spheres: 1-72
% Parahippocampus: 101-102
% Perirhinal: 103-104
% ALEC: 1001-1002
% PMEC: 1003-1004
% Hippocampus: 105-108
Ylabels = zeros(size(Ytseg));
label_info = table([],{},[],[],'VariableNames', ...
	{'Label','Region','Volume_before_overlap_mm3','Volume_mm3'});
warning('off','MATLAB:table:RowsAddedExistingVars');


%% Spheres
sph_labels = readtable(which('PMAT_labels.csv'));
for h = 1:height(sph_labels)
	if sph_labels.Label(h) > 72, continue; end  % Skip ALEC/PMEC for now
	Ylabels( (Yat(:)==sph_labels.Label(h)) | (Ypm(:)==sph_labels.Label(h)) ) ...
		= sph_labels.Label(h);
	label_info.Label(h,1) = sph_labels.Label(h);
	label_info.Region{h,1} = sph_labels.Region{h};
	label_info.Volume_before_overlap_mm3(h,1) = ...
		sum(Ylabels(:)==label_info.Label(h,1)) * voxel_volume;
end


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


%% Now ALEC, PMEC
for h = 1:height(sph_labels)
	if sph_labels.Label(h) > 72
		Ylabels( (Yat(:)==sph_labels.Label(h)) | (Ypm(:)==sph_labels.Label(h)) ) ...
			= sph_labels.Label(h);
		label_info.Label(end+1) = sph_labels.Label(h);
		label_info.Region{end} = sph_labels.Region{h};
		label_info.Volume_before_overlap_mm3(end) = ...
			sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;
	end
end


%% Temporal lobe
Ylabels(Ytseg(:)==4) = 105;
Ylabels(Ytseg(:)==1) = 106;
Ylabels((Ytseg(:)==5) | (Ytseg(:)==11)) = 107;
Ylabels((Ytseg(:)==2) | (Ytseg(:)==10)) = 108;

label_info.Label(end+1) = 105;
label_info.Region{end} = 'AT_L_Hippocampus_Anterior_lh_TLv3';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 106;
label_info.Region{end} = 'AT_R_Hippocampus_Anterior_rh_TLv3';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 107;
label_info.Region{end} = 'PM_L_Hippocampus_Posterior_lh_TLv3';
label_info.Volume_before_overlap_mm3(end) = ...
	sum(Ylabels(:)==label_info.Label(end)) * voxel_volume;

label_info.Label(end+1) = 108;
label_info.Region{end} = 'PM_R_Hippocampus_Posterior_rh_TLv3';
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
roi_nii = fullfile(out_dir,'rois_PMAT.nii');
Vlabels.fname = roi_nii;
spm_write_vol(Vlabels,Ylabels);

label_csv = fullfile(out_dir,'rois_PMAT-labels.csv');
writetable(label_info,label_csv);


