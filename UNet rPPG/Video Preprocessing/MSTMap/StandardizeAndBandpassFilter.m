function SignalMapOut = StandardizeAndBandpassFilter(SignalMap)
    % SignalMap: The input data (signal values for each ROI and channel)
    % filter_order: Order of the Butterworth filter (e.g., 2 or 3)
    % cutoff_range: A two-element array specifying [low_cutoff, high_cutoff] frequencies in Hz
    % sample_rate: Sampling rate of the signal (in Hz)

    filter_order = 1;
    cutoff_range = [0.67, 4];
    sample_rate = 30;
    Nyq = sample_rate/2;
    Wn = cutoff_range./Nyq;
    

    
    % Standardize the signal
    SignalMapStd = (SignalMap - mean(SignalMap, 2) ./ std(SignalMap, 0, 2));  % Standardize each ROI
    
    % Design a Butterworth bandpass filter
    %Wn = cutoff_range / (sample_rate / 2);  % Normalize the cutoff frequencies
    [b, a] = butter(filter_order, Wn, 'bandpass');  % Design the bandpass filter

    % Initialize the filtered output signal
    SignalMapFiltered = zeros(size(SignalMapStd));
    
    % Apply the bandpass filter to each signal in each ROI
    for i = 1:size(SignalMapStd, 1)
           SignalMapFiltered(i,:) = filtfilt(b, a, squeeze(SignalMapStd(i,:)));
    end
    
    SignalMapOut = SignalMapFiltered;  % Output the standardized and filtered signal map
end

