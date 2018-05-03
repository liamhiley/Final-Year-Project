%   read in gaze data for subject
    data = dlmread(strcat(homepath,'/Working Directory/Data/',group,int2str(subject),'videoGZD.txt'),' ',15, 0);
%   select data relevant to the clip
    data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
    data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
    if clipno > 6
        data(:,3) = data(:,3) * 720/1280;
        data(:,10) = data(:,10) * 720/1280;
        data(:,4) = data(:,4) * 368/1024;
        data(:,11) = data(:,11) * 368/1024;
    else
        data(:,4) = data(:,4) * 720/1024;
        data(:,11) = data(:,11) * 720/1024;
    end
