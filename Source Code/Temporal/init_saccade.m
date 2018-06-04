function [] = init_saccade(clipno, group)
%   Generate discrete histograms for each subject in how often they fit 
%   into each of the components of the Lay model for that clip

    homepath = '/Users/liam/Projects/Final-Year-Project';
%   get the Expert model for the clip
    load(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235, 255, 275, 295; 45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250, 270, 290, 310];
    
    %   subject can either be Expert, novice, or lay
    if strcmp(group,'Lay')
        n_subjects = 7;
    else
        n_subjects = 8;
    end
    
   num_seg = 15;
    init_saccs = zeros(1,n_subjects);
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
        
        
%       for segSz clip segments of approx. equal length each
        for t_step = 0:num_seg - 1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            
%           iterate through the segment data until the user saccades,
%           record the time taken until this point
            fixationcnt = [];
            for gz = i+1:j
%               Calculate point-to-point velocity                
                velx = mnGz(gz,1) - mnGz(gz-1,1);
                vely = mnGz(gz,2) - mnGz(gz-1,2);                
%               convert velocity from px/s to deg/s
%               assuming 7px to 1 degree, given a 75dpi display
                vel = sqrt(velx^2 + vely^2)/7;
%               if velocity is under 25deg/s and subject
%               then count it as a potential fixation
                if vel < 25
                    fixationcnt = [fixationcnt; 1];
                else
                    fixationcnt = [fixationcnt; 0];
                end
            end
%           if a group of fixation points lasts for longer than 100ms,
%           approx. 5 frames at 50fps, then count this as a saccade
            time_to_saccade = 0;
            cnt = 0;
            for gz = 2:j-i
                if fixationcnt(gz)
                    cnt = cnt + 1;
                else
                    if cnt >= 5
                        time_to_saccade = cnt/50;
                        cnt = 0;
                        break
                    end
                    cnt = 0;
                end
            end
            if cnt >= 5
                time_to_saccade = cnt/50;
            end
        end
        init_saccs(subject) = time_to_saccade;
    end
    save(strcat('TimeToInitialSaccade/',group,'Clip',int2str(clipno),'InitSaccade.mat'),'init_saccs');
end