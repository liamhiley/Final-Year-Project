function [] = durationInCluster(clipno,group)
%   Generate discrete histograms for each subject in the average time spent focusing 
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
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235; 45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250];
    
    mnGz = [];
    numSeg = 15;
    durPerCluster = zeros(n_subjects,numSeg);
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
        
%       for segSz clip segments of approx. equal length each
        for t_step = 0:numSeg - 1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            
%           iterate through the segment data and find fixations
%           each value of fixationcnt is either the index of the cluster the
%           eye is currently in if a fixation is possibly occurring at this
%           frame, or 0 otherwise
            fixationcnt = [];
            for gz = i+1:j
%               if subject is in the same cluster as previous frame then 
%               count it as a potential fixation
                if Ind(gz) == Ind(gz-1)
                    fixationcnt = [fixationcnt; Ind(gz)];
                else
                    fixationcnt = [fixationcnt; 0];
                end
            end
%           if a group of fixation points lasts for longer than 100ms,
%           approx. 5 frames at 50fps, then count this as a focus
            focus = [];
            cnt = 0;
            if size(fixationcnt,1) > 1
                for gz = 2:j-i
                    if (fixationcnt(gz) == fixationcnt(gz-1)) && fixationcnt(gz)~= 0
                        cnt = cnt + 1;
                    else
                        focus = [focus ; fixationcnt(gz-1), cnt/50];
                        cnt = 0;
                    end
                end
                if ~cnt
                    focus = [focus ; fixationcnt(gz-1), cnt/50];
                end
            elseif size(fixationcnt,1) == 1 
                focus = [focus ; fixationcnt, cnt/50];
            else
                focus = [];
            end
            if isempty(focus)
                focus = [0 0];
            end
            durInCluster = zeros(1,mix.ncentres+1);
            for c = 1:mix.ncentres
                durInCluster(c) = mean(focus(focus(:,1)==c,2));
                if isnan(durInCluster(c))
                    durInCluster(c) = 0;
                end
            end
            durPerCluster(subject,t_step+1) = mean(durInCluster);
        end
    end
    save(strcat('DurationInCluster/',group,'Clip',int2str(clipno),'focusDuration.mat'),'durPerCluster');
end

