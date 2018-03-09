function [] = transitionsOverTime(clipno,group)
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
    data = dlmread(strcat(homepath,'/Working Directory/Data/',group,'1videoGZD.txt'),'	',15, 0);
%   UNCOMMENT BELOW WHEN USING RANDOM CLASS
%   data = load(filename)

%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    
    mnGz = [];
    numSeg = 15;
    saccPerCluster = zeros(n_subjects,numSeg);
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
        [val, ind] = max(P');
%       for segSz clip segments of approx. equal length each
        for t_step = 0:numSeg - 1
            i = floor(size(mnGz,1)*t_step/15)+1;
            j = floor(size(mnGz,1)*(t_step+1)/15);
            trans = zeros(mix.ncentres,mix.ncentres);
            for frame = i:2:j
                if ind(frame) ~= ind(frame+1)
                    trans(ind(frame),ind(frame+1)) = trans(ind(frame),ind(frame+1)) + 1;
                end
            end
        end
    end
end