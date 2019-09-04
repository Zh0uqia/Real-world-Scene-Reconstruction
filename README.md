# Real-world-Scene-Reconstruction
This is an implementation of an augmented reality viewer that displays artificial objects overlaid on images of a real 3D scene. 

Step 1:
- Collections of real-world images. Choose a scene with many features which can be found by the COLMAP application.

Step 2:
- Import the real-world images into COLMAP and get a 3D clouds of points.

Step 3:
- Read in the 3D point data in Matlab.

Step 4:
- Find the largest subset using RANSAC routine.

Step 5:
- Display the 3D point cloud and inlier points.

Step 6:
- 3D Euclidean transformation.

Step 7:
- Create a virtual object to put in the scene.

Step 8:
- Read in the camera parameters.

Step 9:
- Projection of 3D points into 2D pixel locations.

Step 10:
- Projection of 3D points into 2D pixel locations.

Step 11:
- Project the 3D box into the images.

Test:
- ``` main.m ```
- The output images are saved in ```img_output```.
