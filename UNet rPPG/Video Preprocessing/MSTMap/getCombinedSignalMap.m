function SignalMapOut = getCombinedSignalMap(SignalMap, ROInum)

All_idx = ff2n(size(ROInum,1)); %generates all possible combinations of ROIs in a logical matrix

SignalMapOut = zeros(size(All_idx,1)-1, 1, size(SignalMap,2)); %initialize Signal Map Out
% SignalMapStd = zeros(size(All_idx,1)-1, size(SignalMap,2), size(SignalMap,3));

for i = 2:size(All_idx,1) %starts from 2 combination (skips all-zero combination)
    tmp_idx = find(All_idx(i,:)==1); %find idices of ROIs included in the ROI combo (index=1)
    
    tmp_signal = SignalMap(tmp_idx, :); %extracts temp value
    tmp_ROI = ROInum(tmp_idx); %normalizes using ROI weights
    tmp_ROI = tmp_ROI./sum(tmp_ROI);
    tmp_ROI = repmat(tmp_ROI, [1,6]); %repeats 
    
    SignalMapOut(i-1,:,:) = sum(tmp_signal.*tmp_ROI,1);

end

% Map = SignalMap;
% [m,n,channel] = size(Map);
% std_window = 20;

% for c = 1:channel
%     for i = 1:m
%         sig_temp = Map(i,:,c);
%         SignalMapStd(i,:,c) = movstd(sig_temp, std_window);
%     end
% end

end