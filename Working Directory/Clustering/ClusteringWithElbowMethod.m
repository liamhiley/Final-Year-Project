function [] = ClusteringWithElbowMethod(clipno, mix)
%   Opens a sample video of the form EyeTrackingClipX.avi where X is given by
%   clipno
%   A predefined Gaussian Mixture Model can be passed as mix.
%   Uses the elbow method, with the error provided by the model, to decide
%   when to stop increasing the number of components in the model
%   Plots the gaze data onto the clip, clusters being colour coded
   
    %read the gaze data file in the first time to get the range of rows
    %that will be used
    data = dlmread('AnaesExpert1videoGZD.txt','	',15, 0);
    
    %these are the timestamps of the clips within the test video in seconds
    start_sec = [30, 49, 69, 89, 109, 129, 154, 174, 194, 214, 234, 254, 275, 295];
    
    %read in the clip to be used
    video = VideoReader(strcat('EyeTrackingClip', int2str(clipno), '.avi'));
    
    %n is the number of frames for the clip
    n = round(video.FrameRate * video.Duration);
    %the video is dispExperted at a different resolution to that which it was
    %recorded at
    ratio_y = video.Height/1024;
    %get the range (first and last frame no.) of the clips corresponding
    %eye frames, clip_no starting sec * average framerate for eye data
    eye_frame = start_sec(clipno) * (data(end,2)/(data(end,1)/1000));
    i = floor(eye_frame);
    %record starting frame
    j = i;
    
    %get the index of the last frame in the clip
    while true
        %if EOF is reached, break
        if i > size(data,1)
            break;
        end
        time = data(i,1);
        %if the time in seconds is greater than the start of the clip in
        %the test video, + the duration, then this must be the final frame
        %relevant to the clip
        if (time / 1000 >= start_sec(clipno)+ video.Duration)
            break;
        end
        i = i + 1;
    end 
    
    %we now have the starting and ending index of the eye data
    start_ind = j;
    end_ind = i;
    
    
    X =[];
    %for each expert, add there average gaze points to the dataset
    for i = 1:8
%         Uncomment below to leave an expert out, this is for n-fold
%         cross-validation
%         if i==7
%             continue;
%         end
        filename = strcat('AnaesExpert', int2str(i), 'VideoGZD.txt');
        data = dlmread(filename,'	',15, 0);
        data = data(start_ind:end_ind,:);
        j = 1;
        
%       retrieve x values for left and right eyes
        X_L = data(:,3); X_R = data(:,10);
%       retrieve y values for left and right eyes/
        Y_L = data(:,4); Y_R = data(:,11);
%       retrieve the centre of vision for each pair of eye points
        X_M = mean([X_L X_R],2);
        Y_M = mean([Y_L Y_R], 2);
%       for better visualisation ignore all points that would fall off of
%       the screen, these will be 'clustered' as a false cluster in a
%       different function
        X_M = X_M(720 > Y_M & Y_M > 0);
        Y_M = Y_M(720 > Y_M & Y_M > 0);
%       repeat for y values
        Y_M = Y_M(1281 > X_M & X_M >0);
        X_M = X_M(1281 > X_M & X_M > 0);
        
%       X is the annotation for the data used in the netlab documentation
%       and in traditional formulae
%       in this case the mixtures will be 2-dimensional models
        X = [X; X_M Y_M];
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
            if options(8) - err > 10
                return;
            end 
        end
        err = options(8);
        saveas(gcf,strcat('ExpertClip', int2str(clipno),'Cluster.jpg'));
        saveas(gcf,strcat('ExpertClip', int2str(clipno),'Cluster.fig'));
        save(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
        close gcf;
        clear mix;
    end  
end