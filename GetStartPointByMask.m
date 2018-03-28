function [ startPoint ] = GetStartPointByMask( mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iSum = 0;
jSum = 0;
nPixels = 0;
for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        if (mask(i,j) > 0)
            nPixels = nPixels +1;
            iSum = iSum + i;
            jSum = jSum + j;
        end
    end
end
startPoint = [round(iSum / nPixels) round(jSum / nPixels)];
end