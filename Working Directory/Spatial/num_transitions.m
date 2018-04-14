function [] = num_transitions(clipno,group)
%   Generate discrete histograms for each subject in how often they transition 
%   from one component to another of each of the components of the Expert model for that clip

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
    
    mn_gz = [];
    num_seg = 15;
    num_trans = zeros(n_subjects,num_seg);    
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
        [val, ind] = max(P');
%       for segSz clip segments of approx. equal length each
        for t_step = 0:num_seg - 1
            i = floor(size(mn_gz,1)*t_step/15)+1;
            j = floor(size(mn_gz,1)*(t_step+1)/15);
            trans = 0;
            for frame = i:2:j-1
                if ind(frame) ~= ind(frame+1)
                    trans = trans + 1;
                end
            end
            num_trans(subject, t_step+1) = trans;
        end
    end
    save(strcat('numTransitions',group,'Clip',int2str(clipno),'numTransitions.mat'),'num_trans');
end