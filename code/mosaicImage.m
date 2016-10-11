function mosim = mosaicImage(im)
% MOSAICIMAGE computes the mosaic of an image.
%   MOSIM = MOSAICIMAGE(IM) computes the response of the image under a
%   Bayer filter. Given an image IM = NxMx3, the output is a NxM image
%   where the R,G,B channels are sampled according to RGRG on the top left.

[imageHeight, imageWidth, numChanels] = size(im);
assert(numChanels == 3); % Check that it is a color image

% Green channel. This will be overwritten by the red and blue.
mosim = im(:,:,2);

% Red channel (odd rows and columns)
mosim(1:2:imageHeight, 1:2:imageWidth) = im(1:2:imageHeight, 1:2:imageWidth,1);

% Blue channel (even rows and colums)
mosim(2:2:imageHeight, 2:2:imageWidth) = im(2:2:imageHeight, 2:2:imageWidth,3);