function [] = timeBetweenSaccades(clipno, group)
%     This function calculates the total time spent not in a saccade, for
%     any given segment of an eye tracking exercise
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
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235, 255, 275, 295; 45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250, 270, 290, 310];
    mnGz = [];
    numSeg = 15;
    total_time = zeros(n_subjects,numSeg);
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
%       filename = strcat(homepath,'/Working Directory/Data/Clip',int2str(clipno),'NewExpert',int2str(subject),'.mat');
%       load(filename,'exp','-mat');
%       mnGz = exp;
        
%       for segSz clip segments of approx. equal length each
        for t_step = 0:numSeg - 1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            framecnt = 0;
            for gz = i+1:j
                fixation = false;
%               Calculate point-to-point velocity                
                velx = mnGz(gz,1) - mnGz(gz-1,1);
                vely = mnGz(gz,2) - mnGz(gz-1,2);                
%               convert velocity from px/s to deg/s
%               assuming 7px to 1 degree, given a 75dpi display
                vel = sqrt(velx^2 + vely^2)/7;
%               if velocity is under 25deg/s and subject is in the same cluster as previous frame
%               then count it as a potential fixation
                if vel < 25
                    fixation = true;
                end
%               If a fixation is not currently occurring begin timing
                if ~fixation
                    framecnt = framecnt + 1;
                end     
            end
            total_time(subject, t_step+1) = framecnt;
        end
    end
    save(strcat('TimeBetweenSaccades/',group,'Clip',int2str(clipno),'TimeBetweenSaccades.mat'),'total_time');
end