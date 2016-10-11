function [error, output, pixelError] = runDemosaicing(imageName, method, display)
% RUNDEMOSAICING simulates mosaicing and demosaicing
%   [ERROR, OUTPUT, PIXELERROR] = RUNDEMOSAICING(IMAGENAME, METHOD,
%   DISPLAY) computes the ERROR, demosaiced image OUPUT and the PIXELERROR
%   by applying interpolation METHOD on the mosaiced images. The input RGB
%   image is read and sampled using the BAYER pattern using the function
%   MOSAICIMAGE. If DISPLAY is set then the outputs are shown as
%   visualization. 
%

% If no display is passed then set it to false
if nargin < 3
    display = false;
end

% Load ground truth image
srcImage = imread(imageName);

% Convert to double
gt = im2double(srcImage);

% Create a mosaiced image
input = mosaicImage(gt);

% Compute a demosaced image
output = demosaicImage(input, method);

% Sanity check
assert(all(size(gt) == size(output)));

% Compute error
pixelError = abs(gt - output);
error = mean(mean(mean(pixelError)));

% Visualize errors if display is set
if display
    figure(1); clf; 
    subplot(1,3,1); imagesc(gt)                  ; axis image off; title('Image');
    subplot(1,3,2); imagesc(output)              ; axis image off; title('Output');
    subplot(1,3,3); imagesc(max(pixelError,[],4)); axis image off; title('Error max');
    pause(1);
end