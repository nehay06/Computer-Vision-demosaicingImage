# Computer-Vision-demosaicingImage

Recall that in digital cameras the red, blue, and green sensors are interlaced in the Bayer pattern (Figure 2).
The missing values are interpolated to obtain a full color image. In this part you will implement several
interpolation algorithms. The input to the algorithm is a single image im, a NxM array of numbers between
0 and 1. These are measurements in the format shown in Figure 2, i.e., top left im(1,1) is red, im(1,2)
is green, im(2,1) is green, im(2,2) is blue, etc. Included code creates a single color image C from these
measurements.

The code loads images from the data directory (in data/demosaic), artificially mosaics them (mosaicImage.m file), and provides them
as input to the demosaicing algorithm (demosaicImage.m file). By comparing the result with the input
we can also compute the reconstruction error measured as the distance between the reconstructed image
and the true image. This is what the algorithm reports. 

demosaicImage(im, ’baseline’) is implemented which simply replaces all
the missing values for a channel with the average value of that channel. Following functions  are implemented in the file:

- demosaicImage(im, ’nn’) – nearest-neighbour interpolation.
 - demosaicImage(im, ’linear’) – linear interpolation.
- demosaicImage(im, ’adagrad’) – adaptive gradient interpolation.

**run the evalDemosaic.m and you should see the output.**
