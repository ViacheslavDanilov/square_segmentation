clc;
clear;

% import square segmentation library
addpath('SqSegAlgo');
addpath('regionbased_seg');
% loading sol data
fileNum=26;

currAlgo = 'AC'; % square or RG or AC

images=load(['YORK\Raw_data\sol_yxzt_pat' num2str(fileNum) '.mat']);
images=images.sol_yxzt;
contours=load(['YORK\Segmented_data\manual_seg_32points_pat' num2str(fileNum) '.mat']);
contours=contours.manual_seg_32points;
startPoints=load(['startPoints' num2str(fileNum) '.mat']);
startPoints=startPoints.startPoints;

[height, width, ~, ~]=size(images);
masks=GetMasks(contours,[height, width]);

% SqSeg options
options.threshold=30.7;%21.2; % 55.5 optimal for twomedegauss
options.level=21.7;%6.2; % 12.1 optimal
options.edgeSize=20;%10; % 10-5 optimal
options.minEdgeSize=5;

distRG = 22.4; % RG params

%AC params
alpha = 0.2;
nIterations = 75;
maskSize = 14;

timeCoef = 2.2; % time coeff

isVisualize = false; % vizualize images & masks
isSaveImages = true;
isSaveResults = true; 

results=[];
nImages = 0; % count of all images in file
errorCount = 0;
failCount=0;

if (isVisualize)
    figure('units','normalized','outerposition',[0 0 1 1]);
end

for slice=1:size(masks,1)
    for timeframe=1:size(masks,2)
        img=uint8(squeeze(images(:,:,slice,timeframe)));
        mask=masks{slice,timeframe};
        %imshow(img);
        if (mask~=-99999)
            nImages = nImages + 1;
            % starting test
            startPoint= startPoints{slice,timeframe};
            
            tic();
            error = 0;
            if (strcmp(currAlgo, 'square')) % square seg testing
                [splines, error]=SquareSegmentation(img,startPoint,options);
                if(error~=0)   
                    errorCount = errorCount + 1;
                    continue;
                end
                sqMask=Splines2Mask(splines,size(img));
            else
               if (strcmp(currAlgo, 'RG'))
                   % RG testing
                   sqMask = regiongrowing(img, startPoint(1), startPoint(2), distRG);
               else
                   % AC testing
                   mInit = zeros(size(img));
                   x = startPoint(1);
                   y = startPoint(2);
                   mInit(x-maskSize:x+maskSize, y-maskSize:y+maskSize) = 1;
                   sqMask = region_seg(img, mInit, nIterations, 0.2, true);
               end
            end
            time = toc() / timeCoef;
                        
            currAccuracy=CompareMasks(sqMask,mask);
            if (currAccuracy.dice > 0.5)   
                results(end+1,:)=[timeframe, slice, time, currAccuracy.dice];
            else
                failCount=failCount+1;
            end
            if(isVisualize)
                subplot(2,2,1);
                imshow(img);
                title('Image');

                subplot(2,2,2);
                imshow(mask);
                title('Original Mask');

                subplot(2,2,3);
                imshow(sqMask);
                title([currAlgo ' Mask']);

                subplot(2,2,4);
                pause(0.2);
            end
            
            if (isSaveImages)
                folderPath = ['SqSegResults\York\26\' num2str(timeframe) '_' num2str(slice)];
                if (exist(folderPath, 'dir') ~= 7)
                    mkdir(folderPath);
                end
                imwrite(img, [folderPath '\img.tiff']);
                imwrite(mask, [folderPath '\orig.tiff']);
                if (strcmp(currAlgo, 'square'))
                   fileName = [currAlgo '_' num2str(options.edgeSize) '_' num2str(options.minEdgeSize) '.tiff']; 
                else
                  fileName = [currAlgo '.tiff'];  
                end
                imwrite(sqMask, [folderPath '\' fileName]);
            end
        end
    end
end

total=sum(results(:,4));
totalCount=size(results,1);

total=total/totalCount;
total
failCount
errorCount
imhist(results(:,4));

% last string: nImages, 1square fail, acc < 0.5, 0
results(end+1, :) = [total, 0, 0, 0];
results(end+1, :) = [nImages, errorCount, failCount, 0];

if (isSaveResults)
    path = 'SqSegResults\York\26';
    if (strcmp(currAlgo, 'square'))
        fileName = [currAlgo '_' num2str(options.edgeSize) '_' num2str(options.minEdgeSize) '.mat']; 
    else
        fileName = [currAlgo '.mat'];  
    end
    save([path '\' fileName], 'results');
end
