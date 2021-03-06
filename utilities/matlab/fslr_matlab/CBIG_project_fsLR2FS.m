function [lh_FS7_data,rh_FS7_data] = CBIG_project_fsLR2fsaverage(lh_fsLR_data,rh_fsLR_data,fsLR_mesh,type_of_data,folder_to_write)

% [lh_label_fsLR_32k,rh_label_fsLR_32k,lh_label_fsLR_164k,rh_label_fsLR_164k] = CBIG_project_fsaverage2fsLR(lh_FS_data,rh_FS_data,FS_mesh,type_of_data,folder_to_write)
%
% This function projects label/metric data in fs_LR_32k/fs_LR_164k to 
% fsaverage. The projection is performed in fs_LR_164k, therefore, if data 
% is in fs_LR_32k, the data will upsample to fs_LR_164k.
% Input:
%      -lh_fsLR_data, rh_fsLR_data:
%       a 1 x N vector, where N is the number of vertices. ?h_fsLR_data can
%       be metric data (float) or label data (integer) in 
%
%      -fsLR_mesh:
%       'fs_LR_32k'/'fs_LR_164k'. Mesh name of lh_fsLR_data, rh_fsLR_data.
%     
%      -type_of_data:
%       'metric' or 'label'. If ?h.fsLR_data is a metric data (float), then
%       type_of_data should be set to 'metric'. IF ?h.fsLR_data is a label 
%       data (integer), then type_of_data should be set to 'label'.
%
%      -folder_to_write:
%       output path. e.g. '/data/Mapping_FS_fsLR'.
% Output:
%      -lh_FS7_data, rh_FS7_data:
%       output data in fsaverage after projection.
%
% Example:
% folder_to_write='/data/users/rkong/storage/ruby/data/HCP_relevant/Mapping_fsLR2FS';
% [lh_FS7_data,rh_FS7_data]=CBIG_project_fsLR2fsaverage(lh_label_fsLR_32k,rh_label_fsLR_32k,'fs_LR_32k','label',folder_to_write);
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

if(nargin<5)% if you dont set your own write folder
    error('Not enough inputs')
end

%% Save input ?h_fsLR_data as a cifti file
% set gifti file extension
if(strcmp(type_of_data, 'label'))
    fsLR_extension = 'label.gii'; % if type_of_data is label, extension of gifti file is .label.gii
elseif(strcmp(type_of_data, 'metric'))% assuming float data
    fsLR_extension = 'func.gii'; % if type_of_data is metric, extension of gifti file is .func.gii
else
    error('unknown type of data')
end

% get cifti func file structure
lh_fsLR_target = gifti(fullfile(getenv('CBIG_CODE_DIR'), 'data', 'templates', 'surface', fsLR_mesh, 'example_func', 'Parcels_L.func.gii')); 
rh_fsLR_target = gifti(fullfile(getenv('CBIG_CODE_DIR'), 'data', 'templates', 'surface', fsLR_mesh, 'example_func', 'Parcels_L.func.gii')); 

lh_fsLR_target.cdata = lh_fsLR_data;
rh_fsLR_target.cdata = rh_fsLR_data;

% save as a gifti file
save(lh_fsLR_target, fullfile(folder_to_write, [type_of_data, '_L.',fsLR_mesh, '.', fsLR_extension]), 'Base64Binary');
save(rh_fsLR_target, fullfile(folder_to_write, [type_of_data, '_R.',fsLR_mesh, '.', fsLR_extension]), 'Base64Binary');

%% In CBIG_project_fsLR2fsaverage.sh, it will
%  1) If fsLR_mesh is 'fs_LR_32k', it will upsample to fs_LR_164k
%  2) project from fs_LR_164k to fsaverage
system([fullfile(getenv('CBIG_CODE_DIR'), 'utilities', 'matlab', 'fslr_matlab', 'CBIG_project_fsLR2fsaverage.sh'), ' ', folder_to_write, ' ',type_of_data, ' ', fsLR_mesh]);

%% Output fsaverage data
lh_FS7 = gifti(fullfile(folder_to_write, [type_of_data, '_L_gifti.gii']));
rh_FS7 = gifti(fullfile(folder_to_write, [type_of_data, '_R_gifti.gii']));

lh_FS7_data = lh_FS7.cdata;
rh_FS7_data = rh_FS7.cdata;
