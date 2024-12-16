clear all;

%Retrieve sorted Array of Video File Paths
path_vid = 'UNet rPPG';
vidFilePaths = arrayfun(@(x) fullfile(x.folder, x.name), dir(fullfile(path_vid, '*', 'subject*', 'vid.avi')), 'UniformOutput', false);
subjectNumbers = regexp(vidFilePaths, 'subject(\d+)', 'tokens'); % Extract subject number
subjectNumbers = cellfun(@(c) str2double(c{1}), [subjectNumbers{:}]); % Convert the cell array of subject numbers to a numeric array for sorting
[~, sortIdx] = sort(subjectNumbers); % Get sorted indices
vidFilePaths = vidFilePaths(sortIdx); % Sort the file paths

%Retrieve sorted Array of Heart Rate Outputs
path_HR = 'UNet rPPG/Heart Rate Output';
HRFilePaths = arrayfun(@(x) fullfile(x.folder, x.name), dir(fullfile(path_HR, '*.csv')), 'UniformOutput', false);
subjectNumbers = regexp(HRFilePaths, 'subject(\d+)', 'tokens'); % Extract subject number
subjectNumbers = cellfun(@(c) str2double(c{1}), [subjectNumbers{:}]); % Convert the cell array of subject numbers to a numeric array for sorting
[~, sortIdxHR] = sort(subjectNumbers); % Get sorted indices
HRFilePaths = HRFilePaths(sortIdxHR); % Sort the file paths


%Retrieve sorted Array of Landmark Folders (includes landmark
%arrays,frames, and vPPG
path_Landmarks = 'UNet rPPG/Landmarks';
LandmarkFilePaths = dir(fullfile(path_Landmarks, '*'));
LandmarkFilePaths = LandmarkFilePaths(~strcmp({LandmarkFilePaths.name}, '..') & ~strcmp({LandmarkFilePaths.name}, '.DS_Store') & ~strcmp({LandmarkFilePaths.name}, '.'));
LandmarkFilePaths = arrayfun(@(x) fullfile(x.folder, x.name), LandmarkFilePaths, 'UniformOutput', false);

subjectNumbers = regexp(LandmarkFilePaths, 'Landmarks/(\d+)', 'tokens'); % Extract subject number
subjectNumbers = cellfun(@(c) str2double(c{1}), [subjectNumbers{:}]); % Convert the cell array of subject numbers to a numeric array for sorting
[~, sortIdx] = sort(subjectNumbers); % Get sorted indices
LandmarkFilePaths = LandmarkFilePaths(sortIdx); % Sort the file paths


%Retrieve sorted Array of Arrays folders 
path_landmark_dir = cell(size(LandmarkFilePaths));
for i = 1:length(LandmarkFilePaths)
    path_landmark_dir{i} = fullfile(LandmarkFilePaths{i},"arrays");
    
end

%Retrieve sorted Array of BVP file (vPPG)
BVPFilePaths = cell(size(LandmarkFilePaths));
for i = 1:length(LandmarkFilePaths)
    BVPFilePaths{i} = fullfile(LandmarkFilePaths{i},"PPG.csv");
    
end

%Generate Save Folders and Retrieve Sorted Array of Target Paths
save_path = "UNet rPPg/Video Preprocessing/MST Map Output/";
save_folder_names = strcat(save_path, "subject", string(subjectNumbers),'/');
cellfun(@(name) mkdir(name), save_folder_names);

subjectNumbers = regexp(save_folder_names, 'subject(\d+)', 'tokens'); % Extract subject number
subjectNumbers = cellfun(@(c) str2double(c{1}), [subjectNumbers{:}]); % Convert the cell array of subject numbers to a numeric array for sorting
[~, sortIdxTarget] = sort(subjectNumbers); % Get sorted indices
TargetPaths = save_folder_names(sortIdxTarget); % Sort the file paths



%% Run Map Generation
for j = 1:length(LandmarkFilePaths)
    map_generation(vidFilePaths{j},path_landmark_dir{j},HRFilePaths{j},BVPFilePaths{j},strcat(TargetPaths{j},"Map"));

end
