function [] = dist_travelled(clipno, group)
%   This function calculates the total distance travelled by the eye in an
%   eye tracking session, using GZD files
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
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235, 255, 275, 295; 45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250, 270, 290, 310];
    
    mn_gz = [];
    num_seg = 15;
    total_dist = zeros(n_subjects,num_seg);    
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
        
%       for segSz clip segments of approx. equal length each
        for t_step = 0:num_seg - 1
            dist = 0;
            i = floor(size(mn_gz,1)*t_step/15)+1;
            j = floor(size(mn_gz,1)*(t_step+1)/15);
%           calculate the distance travelled in this time step as the sum
%           of the absolute differences between points
            total_dist(subject,t_step+1) = sum(abs(diff(mn_gz(i:j,1)))) + sum(abs(diff(mn_gz(i:j,2))));
        end
    end
    save(strcat('DistanceTravelled/',group,'Clip',int2str(clipno),'DistanceTravelled.mat'),'total_dist');
end