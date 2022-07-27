function roi_nii = combine_rois(waparc_nii,out_dir)

% ROIs are combined in a specific order - later ones overwrite earlier ones
% if there is any overlap.


%% ROI file info, verify geometry, load
Vaparc = spm_vol(waparc_nii);
voxel_volume = abs(det(Vaparc.mat));
Yaparc = spm_read_vols(Vaparc);


%% Initialize final label image and info file
Ylabels = zeros(size(Yaparc));

label_info = readtable('rois-visual-a2009s.csv');
label_info.Properties.VariableNames = {'Label','Region'};
label_info.Volume_before_overlap_mm3(:) = nan;
label_info.Volume_mm3(:) = nan;

for h = 1:height(label_info)
	Ylabels(Yaparc(:)==label_info.Label(h)) = label_info.Label(h);
	label_info.Volume_before_overlap_mm3(h) = ...
		sum(Ylabels(:)==label_info.Label(h)) * voxel_volume;
end

%% Compute final volumes
for h = 1:height(label_info)
	label_info.Volume_mm3(h) = sum(Ylabels(:)==label_info.Label(h)) * voxel_volume;
end


%% Done - write label image and info CSV
Vlabels = Vaparc;
Vlabels.pinfo(1:2) = [1;0];
Vlabels.dt(1) = spm_type('uint16');
roi_nii = fullfile(out_dir,'rois_PMAT_fs.nii');
Vlabels.fname = roi_nii;
spm_write_vol(Vlabels,Ylabels);

label_csv = fullfile(out_dir,'rois_PMAT_fs-labels.csv');
writetable(label_info,label_csv);


