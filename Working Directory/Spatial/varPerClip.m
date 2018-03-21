function [] = varPerClip(clipno, group)
    if strcmp(group,'Expert')
        n_subjects = 8;
    else
        n_subjects = 7;
    end
    homepath = '/Users/liam/Projects/Final-Year-Project';
%   get the Expert model for the clip
    load(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
%   initialise figure
    figure('units','normalized','outerposition',[0 0 1 1]);
%   subject can either be Expert, novice, or lay
    hold on;
    
%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    
    mnGz = [];
    fixVar = [];
    for subject = 1:n_subjects
%       obtain data for subject
        data = dlmread(strcat(homepath,'/Working Directory/Data/',group,int2str(subject),'videoGZD.txt'),'	',15, 0);
%       extract data relevant to this clip
        data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
        data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
%       take mean of left and right gaze points
        mnGz = [mean([data(:,3) data(:,10)],2) mean([data(:,4) data(:,11)],2)];
%       extract data within video frame
        mnGz = mnGz(mnGz(:,1)>=0,:);
        mnGz = mnGz(mnGz(:,1)<=1280,:);
        mnGz = mnGz(mnGz(:,2)>=0,:);
        mnGz = mnGz(mnGz(:,2)<=1024,:);
%       find posterior of each gaussian for each point 
        P = gmmpost(mix, mnGz);
%       label each gaze point by it's most likely gaussian
        [Val, Ind] = max(P');
        
        numSeg = 15;
% %     for segSz clip segments of approx. equal length second each
        for t_step = 0:numSeg-1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            clusterXVar = zeros(mix.ncentres,1);
            clusterYVar = zeros(mix.ncentres,1);
%           for each cluster calculate it's variance in the clip segment
            for c = 1:mix.ncentres
                segGz = mnGz(i:j,:);
                segInd = Ind(i:j);
                xVar = var(segGz(segInd == c,1));
                yVar = var(segGz(segInd == c,2));
                if isnan(xVar)
                    xVar = 0;
                end
                if isnan(yVar)
                    yVar = 0;
                end
                clusterXVar(c) = xVar;
                clusterYVar(c) = yVar;
            end
%           average the variance per cluster
            fixVar(t_step+1,subject,1) = mean(clusterXVar);
            fixVar(t_step+1,subject,2) = mean(clusterYVar);           
        end
%       standardise matrices for use in classification
        x = fixVar(:,subject,1);
        x = (x-min(min(x)))/(max(max(x))-min(min(x)));
        if sum(isnan(x)) > 1
            x = zeros(size(x,1),1);
        end
        fixVar(:,subject,1) = x;
        y = fixVar(:,subject,2);
        y = (y-min(min(y)))/(max(max(y))-min(min(y)));
        if sum(isnan(y)) > 1
            y = zeros(size(y,1),1);
        end
        fixVar(:,subject,2) = y;
    end
    save(strcat(group, 'Clip', int2str(clipno), 'Variance.mat'),'fixVar');
    close(gcf);
end
