function [] = ClusteringWithElbowMethod(clipno, group,mix)
%   Opens a sample video of the form EyeTrackingClipX.avi where X is given by
%   clipno
%   A predefined Gaussian Mixture Model can be passed as mix.
%   Uses the elbow method, with the error provided by the model, to decide
%   when to stop increasing the number of components in the model
%   Plots the gaze data onto the clip, clusters being colour coded
   
    %read the gaze data file in the first time to get the range of rows
    %that will be used
    wd = "/Users/liam/Projects/Final-Year-Project/"
    data = dlmread(strcat(wd,"Source Code/Data/",group,"1VideoGZD.txt"),"	",15, 0);
    %alternatively for Random class use
    %data = load(strcat('Random',int2str(1),'.mat');
    
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235;...
    45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250];
    
    %read in the clip to be used
    video = VideoReader(strcat('/Users/liam/Projects/Final-Year-Project/Media/EyeTrackingClip', int2str(clipno), '.mp4'));
    
    X = [];
    %for each expert, add there average gaze points to the dataset
    for i = 1:7
%       Uncomment below to leave an expert out, this is for n-fold
%       cross-validation
%       if i==7
%           continue;
%       end
        filename = strcat(wd, "Source Code/Data/", group, int2str(i), 'VideoGZD.txt');
        data = dlmread(filename,"	",15,0);
        %   select data relevant to the clip
        data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
        data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
        
        %for random class
        %X = data(start_ind:end_ind);
        %normalise data
        if clipno > 6
            data(:,3) = data(:,3) * 720/1280;
            data(:,10) = data(:,10) * 720/1280;
            data(:,4) = data(:,4) * 368/1024;
            data(:,11) = data(:,11) * 368/1024;
        else
            data(:,4) = data(:,4) * 720/1024;
            data(:,11) = data(:,11) * 720/1024;
        end
        X = [X;[mean([data(:,3),data(:,10)],2) mean([data(:,4),data(:,11)],2)]];
    end
    %an options struct for the mixture model
    options = foptions;
    options(14) = 1;
    options(1) = -1; % Switch off all messages, including warnings

    for num_centres = 1:9
        %for clips composed of static images only the first frame is really
        %needed to represent the entire clip
        img = read(video,1);
        imshow(img);
        hold on;
        
        if ~exist('mix','var');
            %create mixture model, covariance set to full
            mix = gmm(2,num_centres, 'diag');

            %set options struct to use for dispExperting error at each cycle later
            mix = gmminit(mix,X,options);
        end

        %iterate through EM algorithm to improve fit to data points
        for i = 1:2000
            [mix, options] = gmmem(mix, X, options);
        end

%       print out the error of the model at it's final iteration of the EM
%       algorithm
        fprintf(1,'Cycle %4d, Error %11.6f\n',i, options(8));
        
        axis('equal');

        hp = zeros(mix.ncentres,1);
        for i = 1:mix.ncentres
            hp(i) = plot(mix.centres(i,1), mix.centres(i,2), 'marker', '*', 'markersize', 30);
        end

        for i = 1 : mix.ncentres
%           plot circles around each component describing that components
%           range of influence
            theta = 0:0.02:2*pi;
            x = sqrt(mix.covars(i,1))*cos(theta) + mix.centres(i,1);
            y = sqrt(mix.covars(i,2))*sin(theta) + mix.centres(i,2);
            color = get(hp(i),'color');
            plot(x, y, 'color', color);
        end
        hold on;
        post = gmmpost(mix,X);
        [value comp] = max(post,[],2);

        coords = struct;

        for i = 1:mix.ncentres
           coords = setfield(coords, strcat('cluster',int2str(i)), X(comp==i,:)); 
        end

        for i = 1:mix.ncentres
            color = get(hp(i),'color');

            cluster = coords.(strcat('cluster',int2str(i)));
            s = scatter(cluster(:,1),cluster(:,2),15, color, 'filled');
            alpha(s,.3);
        end
        
        if num_centres ~= 1
            if options(8) - err > 1
                return;
            end 
        end
        err = options(8);
%         saveas(gcf,strcat(group,'Clip', int2str(clipno),'Cluster.jpg'));
%         save(strcat(group,int2str(clipno),'.net'), 'mix', '-mat');
        close gcf;
        clear mix;
    end  
end