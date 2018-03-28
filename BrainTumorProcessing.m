clc;
clear;
% import square segmentation library
addpath('SqSegAlgo');
addpath('regionbased_seg');
addpath('BrainTumor'); % path to samples

nFiles = 200;
currAlgo = 'AC'; % square or RG or AC

% SqSeg options
options.threshold=31.0;%21.2; % 55.5 optimal for twomedegauss
options.level=27.4;%6.2; % 12.1 optimal
options.edgeSize=8;%10; % 10-5 optimal
options.minEdgeSize=2;

% RG params
distRG = 22.9; 

%AC params
alpha = 0.2;
nIterations = 60;
maskSize = 32;

timeCoef = 2.2; % time coeff

isVisualize=false; % vizualize images & masks
isSaveImages = true;
isSaveResults = true; 

results=[];
errorCount = 0;
failCount=0;
if (isVisualize)
    figure('units','normalized','outerposition',[0 0 1 1]);
end

for i= 1:nFiles
        % reading and setting start point
        sample = load([num2str(i) '.mat']);
        img = sample.cjdata.image;
        img = imnorm(img, 'norm255');
        mask=sample.cjdata.tumorMask;
        startPoint = GetStartPointByMask(mask); 
        
        %testing...
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
               sqMask = region_seg(img, mInit, nIterations, 0.2, false);
           end
        end
        
        %morphology
        se = strel('disk', 6);
        sqMask = imclose(sqMask, se); 
        time = toc() / timeCoef;
    
        % accuracy calculating 
        currAccuracy=CompareMasks(sqMask,mask);
        if (currAccuracy.dice > 0.5)   
            results(end+1,:)=[i, time, currAccuracy.dice];
        else
            failCount=failCount+1;
        end
        
        % additional blocks vizualization and save
        if(isVisualize)
            subplot(2,2,1);
            imshow(img/255);
            title('Image');
            
            subplot(2,2,2);
            imshow(mask);
            title('Original Mask');
            
            subplot(2,2,3);
            imshow(sqMask);
            title([currAlgo ' Mask']);
            pause(0.2);
        end
        
        if (isSaveImages)
            folderPath = ['SqSegResults\BrainTumor\' num2str(i)];
            if (exist(folderPath, 'dir') ~= 7)
                mkdir(folderPath);
            end
            imwrite(img / 255, [folderPath '\img.tiff']);
            imwrite(mask, [folderPath '\orig.tiff']);
            if (strcmp(currAlgo, 'square'))
               fileName = [currAlgo '_' num2str(options.edgeSize) '_' num2str(options.minEdgeSize) '.tiff']; 
            else
              fileName = [currAlgo '.tiff'];  
            end
            imwrite(sqMask, [folderPath '\' fileName]);
        end
end
total=sum(results(:,3));
totalCount=size(results,1);
total=total/totalCount;
total

failCount
errorCount
imhist(results(:,3));

% last string: nImages, 1square fail, acc < 0.5
results(end+1, :) = [total, 0, 0];
results(end+1, :) = [nFiles, errorCount, failCount];

if (isSaveResults)
    path = ['SqSegResults\BrainTumor'];
    if (strcmp(currAlgo, 'square'))
        fileName = [currAlgo '_' num2str(options.edgeSize) '_' num2str(options.minEdgeSize) '.mat']; 
    else
        fileName = [currAlgo '.mat'];  
    end
    save([path '\' fileName], 'results');
end
