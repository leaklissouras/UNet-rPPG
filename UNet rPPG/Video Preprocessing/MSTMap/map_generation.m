%@inproceedings{niu2020CVD,
%title={Video-based Remote Physiological Measurement via Cross-verified Feature Disentangling.},
%author={Niu, Xuesong and Yu, Zitong and Han, Hu and Li, Xiaobai and Shan, Shiguang and Zhao, Guoying},
%booktitle= {European Conference on Computer Vision (ECCV)},
%year={2020}
%}

function map_generation(video_file,landmark_dir,gt_file,BVP_file,Target_path)
    
    %Initialization
    landmark_num = 81; 
    landmark_data = moving_avg_filter(landmark_dir,landmark_num); %apply moving average filter to landmarks, 3rd dimension k is a frame
    
    gt = readmatrix(gt_file);  % Reads the file as a numeric matrix
    
    BVP_whole_video = readtable(BVP_file, 'VariableNamingRule', 'preserve');  % Preserves the original column headers
    
    fps = 30; % constant fps
    
    clip_length = 256;
    
    obj = VideoReader(video_file);
    numFrames = obj.NumberOfFrames; 
    
    MSTmap_whole_video = zeros(63, numFrames, 6);
    for k = 1 : numFrames 
        frame = read(obj,k);
        frame = imresize(frame,[NaN 600]);
        landmarks = landmark_data(:,:,k);
        lmk_path = strcat(landmark_dir, '/frame_', num2str(k), '.mat');
        MSTmap_whole_video = GenerateSignalMap(MSTmap_whole_video, frame, k, landmarks, landmark_num);
    end

    MSTmap_Filtered = zeros(size(MSTmap_whole_video));
    for i = 1:size(MSTmap_whole_video,3)
        MSTmap_Filtered(:,:,i) = StandardizeAndBandpassFilter(MSTmap_whole_video(:,:,i));
    
    end

    % Save MSTmaps for the video clips
    idx = 1;
    idx = save_MSTmaps(Target_path, MSTmap_Filtered, BVP_whole_video, gt, fps, clip_length, idx);
    fprintf("Saved 1 Map")

end

