clear;

% read input images
A = imread('images/A.jpg');
Aprime = imread('images/Aprime.jpg');
B = imread('images/B.jpg');

% RGB to YIQ color space
yiqA = rgb2ntsc(A);
yiqAprime = rgb2ntsc(Aprime);
yiqB = rgb2ntsc(B);

% get Y (luminance) channel
yA = yiqA(:,:,1);
yAprime = yiqAprime(:,:,1);
yB = yiqB(:,:,1);

% get luminance remapped A, Aprime
[ remapA, remapAprime ] = LuminanceRemapping( yA, yAprime, yB );

% compute Gaussian Pyramids for A, Aprime, B
gpA = ComputeGaussianPyramid(yA);
gpAprime = ComputeGaussianPyramid(yAprime);
gpB = ComputeGaussianPyramid(yB);

% compute features for A, Aprime, B
featuresA = ComputeFeatures(gpA);
featuresAprime = ComputeFeatures(gpAprime);
featuresB = ComputeFeatures(gpB);

% compute Bprime, pixel by pixel
gpBprime = cell(1,size(featuresB,2));
s = cell(1,size(featuresB,2));
for level = size(gpBprime,2):1
    for row = 1:size(yB,1)
        for col = 1:size(yB,2)
            q = gpBprime{level}(row, col);
            [ x, y ] = BestMatch(gpA, gpAprime, gpB, gpBprime, s, level, q);
            gpBprime{level}(row, col) = gpAprime{level}(x,y);
            s{level}(row, col) = [ x, y ];
        end
    end
end

% get Y channel of Bprime
yBprime = gpBprime{1};
% combine with original IQ channels
yiqBprime = cat(3, yBprime,yiqB(:,:,2),yiqB(:,:,3));

% YIQ to RGB
Bprime = ntsc2rgb(yiqBprime);
imwrite(Bprime, 'images/Bprime.jpg', 'jpg');