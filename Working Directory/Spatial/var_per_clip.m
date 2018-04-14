function [] = var_per_clip(clipno, group)
    if strcmp(group,'Expert')
        n_subjects = 8;
    else
        n_subjects = 7;
    end
    homepath = '/Users/liam/Projects/Final-Year-Project';
%   get the Expert model for the clip
    load(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
%   subject can either be Expert, or lay
    
%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    
    mn_gz = [];
    fix_var = [];
    for subject = 1:n_subjects
%       obtain data for subject
        data = dlmread(strcat(homepath,'/Working Directory/Data/',group,int2str(subject),'videoGZD.txt'),'	',15, 0);
%       extract data relevant to this clip
        data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
        data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
%       take mean of left and right gaze points
        mn_gz = [mean([data(:,3) data(:,10)],2) mean([data(:,4) data(:,11)],2)];
%       extract data within video frame
        mn_gz = mn_gz(mn_gz(:,1)>=0,:);
        mn_gz = mn_gz(mn_gz(:,1)<=1280,:);
        mn_gz = mn_gz(mn_gz(:,2)>=0,:);
        mn_gz = mn_gz(mn_gz(:,2)<=1024,:);
%       find posterior of each gaussian for each point 
        P = gmmpost(mix, mn_gz);
%       label each gaze point by it's most likely gaussian
        [Val, Ind] = max(P');
        
        numSeg = 15;
% %     for segSz clip segments of approx. equal length second each
        for t_step = 0:numSeg-1
            i = floor(size(mn_gz,1)*t_step/15)+1;
            j = floor(size(mn_gz,1)*(t_step+1)/15);
            cluster_x_var = zeros(mix.ncentres,1);
            cluster_y_var = zeros(mix.ncentres,1);
%           for each cluster calculate it's variance in the clip segment
            for c = 1:mix.ncentres
                seg_gz = mn_gz(i:j,:);
                seg_ind = Ind(i:j);
                x_var = var(seg_gz(seg_ind == c,1));
                y_var = var(seg_gz(seg_ind == c,2));
                if isnan(x_var)
                    x_var = 0;
                end
                if isnan(y_var)
                    y_var = 0;
                end
                cluster_x_var(c) = x_var;
                cluster_y_var(c) = y_var;
            end
%           average the variance per cluster
            fix_var(t_step+1,subject,1) = mean(cluster_x_var);
            fix_var(t_step+1,subject,2) = mean(cluster_y_var);           
        end
%       standardise matrices for use in classification
        x = fix_var(:,subject,1);
        x = (x-min(min(x)))/(max(max(x))-min(min(x)));
        if sum(isnan(x)) > 1
            x = zeros(size(x,1),1);
        end
        fix_var(:,subject,1) = x;
        y = fix_var(:,subject,2);
        y = (y-min(min(y)))/(max(max(y))-min(min(y)));
        if sum(isnan(y)) > 1
            y = zeros(size(y,1),1);
        end
        fix_var(:,subject,2) = y;
    end
    save(strcat('Variance/',group, 'Clip', int2str(clipno), 'Variance.mat'),'fix_var');
end
