function [data] = saccadesSpentInCluster(clipno,group)
%   Generate discrete histograms for each subject in how often they focus 
%   on each of the components of the Expert model for that clip

    homepath = '/Users/liam/Projects/Final-Year-Project';
%   get the Expert model for the clip
    load(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
%   subject can either be Expert, novice, or lay
    if strcmp(group,'Lay')
        n_subjects = 7;
    else
        n_subjects = 8;
    end
    
%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    
    mnGz = [];
    num_seg = 15;
    sacc_per_cluster = zeros(n_subjects,num_seg);
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
%       UNCOMMENT BELOW WHEN USING RANDOM CLASS
%         filename = strcat(homepath,'/Working Directory/Data/Clip',int2str(clipno),'NewExpert',int2str(subject),'.mat');
%         load(filename,'exp','-mat');
%         mnGz = exp;
%       find posterior of each gaussian for each point 
        P = gmmpost(mix, mnGz);
%       label each gaze point by it's most likely gaussian
        [Val, Ind] = max(P');
        
%       for segSz clip segments of approx. equal length second each
        for t_step = 0:num_seg - 1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            
%           iterate through the segment data and find fixations
%           each value of fixationcnt is either the index of the cluster the
%           eye is currently in if a fixation is possibly occurring at this
%           frame, or 0 otherwise
            fixationcnt = 0;
            for gz = i+1:j
%               Calculate point-to-point velocity                
                velx = mnGz(gz,1) - mnGz(gz-1,1);
                vely = mnGz(gz,2) - mnGz(gz-1,2);                
%               convert velocity from px/s to deg/s
%               assuming 6px to 1 degree, given a 75dpi display
                vel = sqrt(velx^2 + vely^2)/6;
%               if velocity is under 25deg/s and subject is in the same cluster as previous frame
%               then count it as a potential fixation
                if vel < 25 && Ind(gz) == Ind(gz-1)
                    fixationcnt = [fixationcnt; Ind(gz)];
                else
                    fixationcnt = [fixationcnt; 0];
                end
            end
%           if a group of fixation points lasts for longer than 100ms,
%           approx. 5 frames at 52fps, then count this as a saccade
            saccade = [];
            cnt = 0;
            for gz = 2:j-i
                if fixationcnt(gz) == fixationcnt(gz-1) && fixationcnt(gz)~= 0
                    cnt = cnt + 1;
                else
                    if cnt >= 5
                        saccade = [saccade ; fixationcnt(gz-1)];
                    end
                    cnt = 0;
                end
            end
            if cnt >= 5
                saccade = [saccade ; fixationcnt(gz-1)];
            end
            sacc_in_cluster = zeros(1,mix.ncentres+1);
            for c = 1:mix.ncentres+1
                sacc_in_cluster(c) = sum(saccade==c);
            end
            sacc_per_cluster(subject,t_step+1) = sum(sacc_in_cluster);
        end
    end
    save(strcat('SaccadesPerCluster/',group,'Clip', int2str(clipno),'SaccadesPerCluster.mat'),'sacc_per_cluster');
end