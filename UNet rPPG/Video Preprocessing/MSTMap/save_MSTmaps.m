function dir_idx = save_MSTmaps(HR_train_path, SignalMap, BVP_all, gt, fps, clip_length, dir_idx)

img_num = size(SignalMap, 2)
channel_num = size(SignalMap, 3)
step_size = 10;
clip_num = floor(img_num/ step_size);

for i = 1:clip_num
    begin_idx = (i - 1)*step_size + 1;
    
    if (begin_idx + clip_length - 1 > img_num)
        continue;
    end
    
    if floor(begin_idx / fps) >= height(gt) 
        continue;
    end
    
    gt_temp = mean(gt(max(1, floor(begin_idx / fps)):min(height(gt), floor((begin_idx + clip_length) / fps)))); % Updated to use height(gt)
    final_signal = SignalMap(:, begin_idx: begin_idx + clip_length - 1, :);
    judge = mean(final_signal, 1);
    
    if ~isempty(find(judge(1, :, 2) == 0))
        continue;
    else
        dir_name = strcat(HR_train_path, num2str(dir_idx), '/');
        if ~exist(dir_name, 'dir')  
            mkdir(dir_name)
        end
        
        bpm = gt_temp * clip_length / fps / 60;
        bvp_begin = floor(begin_idx / img_num * height(BVP_all));  
        bvp_len = round(clip_length / img_num * height(BVP_all)); 
        if (bvp_begin + bvp_len > height(BVP_all))  
            continue;
        end
        bvp = BVP_all{bvp_begin + 1:bvp_begin + bvp_len, :};  
        
        x = 1:height(bvp);  
        xx = 1:clip_length;
        xx = xx * height(bvp) / clip_length;
        bvp = interp1(x, bvp, xx);

        label_path = strcat(dir_name, 'gt.mat');
        fps_path = strcat(dir_name, 'fps.mat');
        bpm_path = strcat(dir_name, 'bpm.mat');
        bvp_path = strcat(dir_name, 'bvp.mat');

        save(label_path, 'gt_temp');  
        save(fps_path, 'fps'); 
        save(bpm_path, 'bpm'); 
        save(bvp_path, 'bvp');  

        final_signal1 = final_signal;
        for idx = 1:size(final_signal, 1)
            for c = 1:channel_num
                temp = final_signal(idx, :, c);
                temp = movmean(temp, 3);
                final_signal1(idx, :, c) = (temp - min(temp)) / (max(temp) - min(temp)) * 255;
            end
        end
        
        img1 = final_signal1(:, :, [1 2 3]);
        img2 = final_signal1(:, :, [4 5 6]);
        img_mat = final_signal;

        img1_path = strcat(dir_name, 'img_rgb.png');
        img2_path = strcat(dir_name, 'img_yuv.png');

        imwrite(uint8(img1), img1_path);
        imwrite(uint8(img2), img2_path);

        dir_idx = dir_idx + 1;
    end
end

end
