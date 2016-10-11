function output = demosaicImage(im, method)
% DEMOSAICIMAGE computes the color image from mosaiced input
%   OUTPUT = DEMOSAICIMAGE(IM, METHOD) computes a demosaiced OUTPUT from
%   the input IM. The choice of the interpolation METHOD can be
%   'baseline', 'nn', 'linear', 'adagrad'.
%


switch lower(method)
    case 'baseline'
        output = demosaicBaseline(im);
    case 'nn'
        output = demosaicNN(im);         % Implement this
    case 'linear'
        output = demosaicLinear(im);     % Implement this
    case 'adagrad'
        output = demosaicAdagrad(im);    % Implement this
end

%--------------------------------------------------------------------------
%                          Baseline demosacing algorithm.
%                          The algorithm replaces missing values with the
%                          mean of each color channel.
%--------------------------------------------------------------------------
function mosim = demosaicBaseline(im)
mosim = repmat(im, [1 1 3]); % Create an image by stacking the input
[imageHeight, imageWidth] = size(im);

% Red channel (odd rows and columns);
redValues = im(1:2:imageHeight, 1:2:imageWidth);
meanValue = mean(mean(redValues));
mosim(:,:,1) = meanValue;
mosim(1:2:imageHeight, 1:2:imageWidth,1) = im(1:2:imageHeight, 1:2:imageWidth);

% Blue channel (even rows and colums);
blueValues = im(2:2:imageHeight, 2:2:imageWidth);
meanValue = mean(mean(blueValues));
mosim(:,:,3) = meanValue;
mosim(2:2:imageHeight, 2:2:imageWidth,3) = im(2:2:imageHeight, 2:2:imageWidth);

% Green channel (remaining places)
% We will first create a mask for the green pixels (+1 green, -1 not green)
mask = ones(imageHeight, imageWidth);
mask(1:2:imageHeight, 1:2:imageWidth) = -1;
mask(2:2:imageHeight, 2:2:imageWidth) = -1;
greenValues = mosim(mask > 0);
meanValue = mean(greenValues);
% For the green pixels we copy the value
greenChannel = im;
greenChannel(mask < 0) = meanValue;
mosim(:,:,2) = greenChannel;

%--------------------------------------------------------------------------
%                           Nearest neighbour algorithm
%--------------------------------------------------------------------------
function dmosim = demosaicNN(im)
OH = size(im,1);
OW = size(im,2);
BluePixel = ones(OH,OW).*(-1);
BluePixel(2:2:OH, 2:2:OW) = im(2:2:OH, 2:2:OW);
BlueValues =  padarray(BluePixel,[1,1],'replicate');
Redcopy = ones(OH,OW).*(-1);
Redcopy(1:2:OH, 1:2:OW) = im(1:2:OH, 1:2:OW);
RedValues =  padarray(Redcopy,[1,1],'replicate');
imCopy  =  padarray(im,[1,1],'replicate');
mosim = repmat(imCopy, [1 1 3]);
[imageHeight, imageWidth] = size(imCopy);
for i = 2:imageHeight-1
    for j = 2:imageWidth-1
        % Begin: logic for even rows in  an image
        if(mod(i,2) == 0)
            %% Begin Missing Green Pixels: Even Row, Even column
            if(mod(j,2) == 0)   
                    mosim(i,j,2) = imCopy(i,j+1);
            end
            % End Missing Green Pixels: Even Row, Even column
        else
            %% Begin Missing Green pixel: Odd Row and old column.
            if(mod(j,2) == 1)
                mosim(i,j,2) = imCopy(i,j-1); 
            end
            % End Missing Green pixel: Odd Row and old column.
        end
         
        for x = -1:1
            for y = -1:1
               if(BlueValues(i+x,j+y) >= 0)
                  mosim(i,j,3) = imCopy(i+x,j+y); 
                  break
               end
            end
        end
        if(RedValues(i,j) == -1)
            if(RedValues(i-1,j-1) >=0)
                mosim(i,j,1) = imCopy(i-1,j-1);
            elseif (RedValues(i,j-1) >=0)
                mosim(i,j,1) = imCopy(i,j-1);
            end
        end
        
    end
end
dmosim = mosim(2:imageHeight-1,2:imageWidth-1,:);


%--------------------------------------------------------------------------
%                           Linear interpolation
%--------------------------------------------------------------------------
function dmosim = demosaicLinear(im)

mosim = repmat(padarray(im,[2,2],'replicate'), [1 1 3]);
%mosim = repmat(im, [1 1 3]);
imageHeight = size(mosim,1);
imageWidth = size(mosim,2);
%% Green channel
greenMask = repmat([0 1; 1 0], round(imageHeight/2),  round(imageWidth/2));
if mod(imageHeight,2) ==1
    greenMask(size(greenMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    greenMask(:,size(greenMask,2)-1) = [];
end
greenValues = mosim(:,:,2).*greenMask;

%Interpolation for green channel
mosim(:,:,2) =imfilter(greenValues,[0,1,0; 1,4,1;0,1,0]/4);
% Red channel (odd rows and columns);
redMask = repmat([1 0; 0 0], round(imageHeight/2), round(imageWidth/2));
if mod(imageHeight,2) ==1
    redMask(size(redMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    redMask(:,size(redMask,2)-1) = [];
end
redValues=mosim(:,:,1).*redMask;
mosim(:,:,1) = imfilter(redValues,[1,2,1; 2,4,2;1,2,1]/4);


% %Blue channel (even rows and colums);
blueMask = repmat([0 0; 0 1], round(imageHeight/2),  round(imageWidth/2));
if mod(imageHeight,2) ==1
    blueMask(size(blueMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    blueMask(:,size(blueMask,2)-1) = [];
end
blueValues=mosim(:,:,3).*blueMask;
mosim(:,:,3) = imfilter(blueValues,[1,2,1; 2,4,2;1,2,1]/4);
dmosim = mosim(3:imageHeight-2,3:imageWidth-2,:);
%--------------------------------------------------------------------------
%                           Adaptive gradient
%--------------------------------------------------------------------------
function dmosim = demosaicAdagrad(im)
mosim = repmat(padarray(im,[2,2],'symmetric'), [1 1 3]);
%[imageHeight, imageWidth] = size(im);
imageHeight = size(mosim,1);
imageWidth = size(mosim,2);
%mosim = repmat(im, [1 1 3]);
greenMask = repmat([0 1; 1 0], round(imageHeight/2),  round(imageWidth/2));
if mod(imageHeight,2) ==1
    greenMask(size(greenMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    greenMask(:,size(greenMask,2)-1) = [];
end
greenValues = mosim(:,:,2).*greenMask;
% %Blue channel (even rows and colums);
blueMask = repmat([0 0; 0 1], round(imageHeight/2),  round(imageWidth/2));
if mod(imageHeight,2) ==1
    blueMask(size(blueMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    blueMask(:,size(blueMask,2)-1) = [];
end
blueValues=mosim(:,:,3).*blueMask;

% Red channel (odd rows and columns);
redMask = repmat([1 0; 0 0], round(imageHeight/2), round(imageWidth/2));
if mod(imageHeight,2) ==1
    redMask(size(redMask,1)-1,:) = [];
end
if mod(imageWidth,2) ==1
    redMask(:,size(redMask,2)-1) = [];
end
redValues=mosim(:,:,1).*redMask;
for i = 3:2:imageHeight-2
    for j = 3:2:imageWidth-2
        Hdiff = abs((redValues(i,j-2)+redValues(i,j+2))/2 -redValues(i,j));
        Vdiff = abs((redValues(i-2,j)+redValues(i+2,j))/2 -redValues(i,j));
        if(Hdiff < Vdiff)
            mosim(i,j,2) = (greenValues(i,j-1)+greenValues(i,j+1))/2;
        elseif (Hdiff > Vdiff)
            mosim(i,j,2) = (greenValues(i-1,j)+greenValues(i-1,j))/2;
        else
            mosim(i,j,2) = (greenValues(i,j-1)+greenValues(i,j+1)+greenValues(i-1,j)+greenValues(i+1,j))/4;
        end
    end
end
for i = 4:2:imageHeight-2
    for j = 4:2:imageWidth-2
        Hdiff = abs((blueValues(i,j-2)+blueValues(i,j+2))/2 -blueValues(i,j));
        Vdiff = abs((blueValues(i-2,j)+blueValues(i+2,j))/2 -blueValues(i,j));
        if(Hdiff < Vdiff)
            mosim(i,j,2) = (greenValues(i,j-1)+greenValues(i,j+1))/2;
        elseif (Hdiff > Vdiff)
            mosim(i,j,2) = (greenValues(i-1,j)+greenValues(i-1,j))/2;
        else
            mosim(i,j,2) = (greenValues(i,j-1)+greenValues(i,j+1)+greenValues(i-1,j)+greenValues(i+1,j))/4;
        end
    end
end
%Interpolation of a blue pixel
mosim(:,:,3) = imfilter(blueValues,[1,2,1; 2,4,2;1,2,1]/4);

% missing red pixels
mosim(:,:,1) = imfilter(redValues,[1,2,1; 2,4,2;1,2,1]/4);

dmosim = mosim(3:imageHeight-2,3:imageWidth-2,:);
