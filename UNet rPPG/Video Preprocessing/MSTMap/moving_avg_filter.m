function movingAvgData = moving_avg_filter(landmark_dir,landmark_num)

    %Step 1: Initialize 3D Array
    fileNames = {dir(fullfile(landmark_dir, 'frame_*.mat')).name};
    assignin('base','landmark_files_filter',fileNames);
    numericValues = cellfun(@(x) str2double(regexp(x, '\d+', 'match', 'once')), fileNames);
    [~, sortIndex] = sort(numericValues);  % Sort indices based on numeric values
    array_sorted = string(fileNames(sortIndex));
    dat = zeros(2, 81, length(array_sorted)); % Preallocate a 3D array

    for i = (1:length(array_sorted))
        pathname = strcat(landmark_dir,'/',array_sorted(i));
        array_i = load(pathname);
        landmarks = reshape(array_i.landmarks, [2, landmark_num]);
        dat(:, :, i) = landmarks;

    end

    % Step 2: Apply a 5-point moving average filter
    movingAvgData = zeros(size(dat)); 
    
    % Define moving average filter (above and below)
    filterSize = 5;
    halfFilter = floor(filterSize / 2);

    for i = 1:landmark_num
        % Calculate the moving average for each row (x and y coordinates)
        for row = 1:2  % 1 for x and 2 for y
            for k = (1:length(array_sorted)) 
                % Calculate the indices for the moving average
                startFrame = max(1, k - halfFilter); % Prevent index below 1
                endFrame = min(length(array_sorted), k + halfFilter); % Prevent index above numFrames
                
                % Calculate the moving average
                movingAvgData(row, i, k) = mean(dat(row, i, startFrame:endFrame));
            end
        end
    end




end
