## Remote Photoplethosmyography & Deep Learning to Predict Heart Rate 
A U-Net deep learning model for estimation of HR, adapted from Yu et al.
BMME 575 Final Project.


## Description
The growth of telemedicine has resulted in a need for remote methods of measuring vitals. One such method is remote photoplethosmyography, in which HR can be estimated from a recorded video using a prediction algorithm. Yu et al. [1] proposed a U-Net structure and virtual PPG (vPPG) to achieve accurate HR estimation. The purpose of this project was to recreate the findings of this study and examine its advantages and shortcomings. The UBFC-rPPG dataset collected by Bobbia et al. [2] was used.  


## Navigating this Repository
### Python Dependencies:
- tensorflow
- keras
- numpy
- os
- pandas
- scipy.io
- glob
- visualkeras
- matlplotlib.pyplot
- scipy.stats
- scipy signal
- tqdm
- sklearn.metrics
- argparse
- imutils
- time
- dlib
- cv2

### Notes:
- Filepaths/directories must be tweaked depending on where video files and ground truth PPG are saved (files do not need to be stored in the same manner as in this repository as long as path variables within the code are changed). Filepath variables that need to be changed are marked by comments. 
- The outputs of Landmarks_Loop.ipynb and signal_preprocess_loop.ipynb for each participant should be stored in the same subfolders. These outputs are used as inputs for MST Map generation
- The outputs of MST Map generation serve as inputs for training. Each MST Map represents a 256 frame segment of the data
- A more in depth description of methods can be found in [Methods.md](https://github.com/leaklissouras/UNet-rPPG/blob/main/Methods.md)

## Support
Please email lklissouras@unc.edu with any questions or concerns.

## Authors and Acknowledgment
This code was developed by Lea Klissouras, Virginie Ruest, Kabir Dewan, and Joshua Stansell. We thank Dr. Arian Azarang for his invaluable guidance and support– this project would not have been possible without his expertise and mentorship.

## References
[1] Yu SN, Wang CS, Yu Ping Chang. Heart Rate Estimation From Remote Photoplethysmography Based on Light-Weight U-Net and Attention Modules.  IEEE access. 2023;11:54058-54069. doi:https://doi.org/10.1109/access.2023.3281898

[2] S. Bobbia, R. Macwan, Y. Benezeth, A. Mansouri, and J. Dubois, ‘‘Unsupervised skin tissue segmentation for remote photoplethysmography,’’ Pattern Recognit. Lett., vol. 124, pp. 82–90, Jun. 2019.

[3] D. E. King, ‘‘Dlib-ml: A machine learning toolkit,’’ J. Mach. Learn. Res., vol. 10, pp. 1755–1758, Dec. 2009.

[4] X. Niu, Z. Yu, X. Li, S. Shan, and G. Zhao, “CVD-Physiological-Measurement,” GitHub, 2020. https://github.com/nxsEdson/CVD-Physiological-Measurement/blob/master/README.md (accessed Nov. 20, 2024).

  

