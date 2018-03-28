clc;
clear;

addpath('SqSegAlgo');
addpath('C:\Users\ram8\Downloads\BrainTumor'); % path to samples

imgNum = 75;
nPoints = 5;

sample = load([num2str(imgNum) '.mat']);
img = sample.cjdata.image;
img = imnorm(img, 'norm255');
imshow(img / 255);
[x y button] = ginput(5);
x =round(x);
y = round(y);
results = [];
for i = 1: nPoints
    if (button(i) ==  118) % vertical line
        ray = squeeze(img(y(i) - 2 : y(i) + 2, x(i)))';
    else
        ray = squeeze(img(y(i), x(i) - 2 : x(i) + 2));
    end
    results(i) = abs(LSM(ray));
end
sum(results) / size(results,1)

