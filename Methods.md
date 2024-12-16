## Methods
The framework, modeled off of work by Yu et al. [1] consists of four main components: signal pre-processing, video pre-processing, the deep learning network, and heart rate calculation.

<img style="width:50% height:auto" alt="image" src="https://github.com/user-attachments/assets/386608fe-5ab6-4c43-9687-74492204fec0" />

<h6> Fig. 1. (a) Example of vPPG wave for one length-256 segment. (b) 81 landmarks (green dots) and the six ROIs (shaded regions). (c) Example of a video frame input. (d) Example of a PSD graph used to calculate HR. The frequency correpsonding to the peak of the graph is converted to bpm, which is an input in the MSTmap code. (e) The resulting MSTmap structure, with dimensions. <h6>

### Signal Pre-Processing
  Signal pre-processing converts the ground truth PPG signal into a virtual PPG (vPPG) signal. An example of a vPPG signal is depicted in Fig. 1a. When calculating heart rate from PPG data, the only points of importance are the peak locations. These peaks indicate maximum blood volume during the systolic phase of the cardiac cycle. Consequently, the distance between these peaks is the length of one heartbeat. However, some features of the PPG signal are unnecessary for calculating heart rate, such as the dicrotic notch (the inflection point on the wave indicating a transition from systole to diastole). By removing extraneous features and interpolating with a sinusoidal wave, the resulting signal will be easier for the model to replicate while still capturing necessary information for HR calculation. Equation (1) was used to connect the peaks of the reference PPG with cosine waves to generate vPPG data.

<img width="307" alt="Screenshot 2024-12-16 at 12 45 50 AM" src="https://github.com/user-attachments/assets/94bb025d-4f1d-4824-8124-35e164464396" />


where P is the peak location, x is any position from the current peak P(i) to the next peak, P(i+1). All signals were filtered with a first order Butterworth filter with a cutoff frequency range of [0.67- 4 Hz], which represents an approximate range of physiologically possible HRs (40.2 bpm to 240 bpm). 

### Video Pre-Processing
1)	Landmark Detection: We employed the Dlib-ml-machine learning toolkit to extract the facial region (indicated by a bounding box around the face) and generate and matrix of (x,y) coordinates for 81 predetermined landmarks [3]. The feature points had slight displacements in each frame that may degrade the extracted signal, so a 5-points moving average filter was added to reduce jitter and ensure signal quality was maintained. The resulting landmarks were used during the video pre-processing phase to generate the six regions of interest (ROI). Landmarks and ROIs are depicted in Fig. 1b.

2)	MST Map Creation: Multi-scale spatio-temporal maps are images that visually encode spatial and temporal data. In our case, the spatial data represents 2n – 1 = 63 possible combinations of ROI (i.e., all possible combinations excluding the zero combination). Each combination is represented by a row of data. To encode temporal data, each column of the map corresponds to one frame. A sliding window with a window size of 256 frames and a step size of 10 frames was used to increase the inputs fed into the model. Consequently, the dimension along the temporal axis of the MSTmap is 256. The map also includes 6 color channels: RGB and YUV. YUV refers to luminance and red/blue projection chrominance channels; it is commonly used in rPPG research. The resulting map size is 63x256x6, as depicted in Fig. 1e.
	To generate these maps, MATLAB code was adapted from Niu et al. [4]. Because the source code utilized a different method to determine landmarks, landmark indices were adjusted to match those produced by d-lib. The code creates masked versions of each frame for the six ROIs, generates the 64 combinations of these ROIs, standardizes and filters each ROI combination along the temporal axis, compiles the maps, and saves the maps in segments of 256 frames. For filtering, a first order Butterworth filter with a cutoff frequency of [0.67 – 4 Hz] was used. The code also performs the sliding window segmentation on the vPPG/PPG data, matching each wave segment to each map segment. The inputs for the MST map generation are depicted in Fig. 1a-d.

### Deep Learning Model

<img style="width:50% height:auto" alt="image" src="https://github.com/user-attachments/assets/e685cf1a-0a36-4032-bcc9-b6955efa9b62" />

<h6> Fig. 2. The Modified U-Net archetecture, including a color-coded legend and defintion of a double convolution block. MST Maps are input, and the vPPG or PPG signal is output. </h6>

   We implemented a modified U-Net model to predict vPPg/vPPG wave signals from the input MSTmaps. The architecture is depicted in Fig. 2. Meaningful features are extracted in the encoder and reconstructed in the decoder, forming a wave signal output. All max-pooling layers were swapped with average pooling layers in order to extract mean signals from the various ROIs, and a global average pooling layers was added at the end of the model to compress the output feature map into the 1D signal wave. The model features double convolution block with PReLU activation to allow the network to capture the complex spatial relationships in the map and extract features more effectively. Additionally, skip connections concatenate feature maps from encoder layers to decoder layers, enabling the model to maintain high level features that may have been lost during down-sampling. The hyperparameters used in the model are described in Table 1.

<img width="335" alt="Screenshot 2024-12-16 at 12 51 12 AM" src="https://github.com/user-attachments/assets/c0876601-4046-410e-a1ea-0202c972e701" />


   A custom loss function was used, combining the negative Pearson correlation coefficient between waves (L1), the Manhattan distance between heart rates (L2), and mean square error (MSE) between frequencies (L3). The negative Pearson Correlation coefficient (2) is used to optimize the predicted waves; it is negative so that the combined loss function may be reduced while maximizing correlation.
   
<img width="275" alt="Screenshot 2024-12-16 at 12 51 36 AM" src="https://github.com/user-attachments/assets/d32026db-9b4b-497d-8c5d-652330994b63" />

The Manhattan distance is to compare ground-truth heart rate to predicted heart rate, allowing the network to focus on heart rate estimation in addition to signal matching. A Fast Fourier Transform (FFT) was first used to extract the highest frequency, which was converted to beats per minute (bpm) (3). 


<img width="329" alt="Screenshot 2024-12-16 at 12 51 48 AM" src="https://github.com/user-attachments/assets/da9c43ea-1de5-4cef-9178-ebfcf4668c79" />

Finally, the mean square error of the power spectral density (5) was used to guide the model in predicting signals with accurate PSD distributions. 

<img width="290" alt="Screenshot 2024-12-16 at 12 52 01 AM" src="https://github.com/user-attachments/assets/bf16169c-087b-4079-8c24-37c501af8bc3" />

The combined loss function with experimental weights is described in equation (6). 

<img width="313" alt="Screenshot 2024-12-16 at 12 52 23 AM" src="https://github.com/user-attachments/assets/6ce8b136-4efd-4cc4-bb95-9beb9b815b42" />

The Manhattan distance and MSE are included in lower ratios, as they are more difficult to converge but still provide useful information about the desired heart rates and frequency distributions.

### Heart Rate Calculation
   Heat rate was calculated using power spectral density (PSD). Power spectral density utilizes a FFT to extract the power of each frequency. The welch method in SciPy was used with FFT length of 4096 (the signal was automatically padded). To calculate heart rate from PSD, the frequency with highest power is selected – this represents the most common frequency in the segment and corresponds to the heart rate in beats per minute. This is then multiplied by 60 to convert to beats per second. 
HR is calculated for both ground truth and predicted vPPG/PPG. When reporting metrics in results (Section III), mean absolute error (MAE), root-mean-square error (RMSE), and correlation coefficient (r) are calculated between ground truth and predicted HR values rather than between ground truth and predicted signals, since accurately estimating HR is the end goal.

### Dataset
This project utilized the UBFC-rPPG dataset collected by Bobbia et al. [2]. The realistic dataset was used, which included videos and ground truth PPG for 42 participants. Subject 41 was removed due to inaccurate facial detection with d-lib (potential remedies are discussed in Section IV). Participants were recorded as they participated in math games designed to increase their heart rate. A Logitech C920 HD Pro with resolution and frame rate of 640 x 480 and 30fps, respectively, was used. PPG data was collected on a CMS50E Pulse Oximeter.  Data from the first 30 subjects were used for training and data from the last 12 subjects were used for testing. As noted, a sliding window segmentation with length 256 was used to increase the number of training samples.  

### References
[1] Yu SN, Wang CS, Yu Ping Chang. Heart Rate Estimation From Remote Photoplethysmography Based on Light-Weight U-Net and Attention Modules.  IEEE access. 2023;11:54058-54069. doi:https://doi.org/10.1109/access.2023.3281898 

[2] S. Bobbia, R. Macwan, Y. Benezeth, A. Mansouri, and J. Dubois, ‘‘Unsupervised skin tissue segmentation for remote photoplethysmography,’’ Pattern Recognit. Lett., vol. 124, pp. 82–90, Jun. 2019.

[3] D. E. King, ‘‘Dlib-ml: A machine learning toolkit,’’ J. Mach. Learn. Res., vol. 10, pp. 1755–1758, Dec. 2009.

[4] X. Niu, Z. Yu, X. Li, S. Shan, and G. Zhao, “CVD-Physiological-Measurement,” GitHub, 2020. https://github.com/nxsEdson/CVD-Physiological-Measurement/blob/master/README.md (accessed Nov. 20, 2024).




