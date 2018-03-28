clc;
clear;
% import square segmentation library
addpath('SqSegAlgo');

currAlgo = 'RG'; % square or RG

% SqSeg options
options.threshold=10;%31.0;%21.2; % 55.5 optimal for twomedegauss
options.level=10;%27.4;%6.2; % 12.1 optimal
options.edgeSize=20;%8;%10; % 10-5 optimal
options.minEdgeSize=5;

distRG = 10; % RG params

timeCoef = 2.2; % time coeff

isVisualize=false; % vizualize images & masks
isSaveResults = true; 

results=[];
sizes = 500:250:2000; 

for sz = sizes 
        % reading and setting start point
        img = GetTestImage(sz);
        startPoint = [sz/2 sz/2]; 
        
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
           % RG testing
           sqMask = regiongrowing(img, startPoint(1), startPoint(2), distRG);
        end
        
        time = toc() / timeCoef;                 
        results(end+1,:)=[sz, time];
        % additional blocks vizualization and save
        if(isVisualize)
            close all;
            %figure('units','normalized','outerposition',[0 0 1 1])
            subplot(2,2,1);
            imshow(img/255);
            title('Image');
            
            subplot(2,2,2);
            imshow(sqMask);
            title([currAlgo ' Mask']);
            %pause(0.5);
        end
        
end
%%
plot(sizes, results(:,2));
if (isSaveResults)
    path = ['SqSegResults\TimeTest'];
    if (strcmp(currAlgo, 'square'))
        fileName = ['square_' num2str(options.edgeSize) '_' num2str(options.minEdgeSize) '.mat']; 
    else
        fileName = ['RG.mat'];  
    end
    save([path '\' fileName], 'results');
end
