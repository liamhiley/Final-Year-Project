function [] = fixationsSpentInCluster(clipno)
%   Generate discrete histograms for each subject in how often they fit 
%   into each of the components of the Lay model for that clip


%   get the Expert model for the clip
    load(strcat('Expert',int2str(clipno),'.net'), 'mix', '-mat');
%   initialise figure
    figure('units','normalized','outerposition',[0 0 1 1]);
%   subject can either be Expert, novice, or lay
    hold on;
    for subject = 1:7
%       read in the gaze data for the subject, in the form
%       LayXVideoGZD.txt or AnaesExpertXVideoGZD.txt or NoviceXVideoGZD.txt
        filename = strcat('AnaesExpert', int2str(subject), 'VideoGZD.txt');
%       timestamps for beginning and ending of each clip within the whole
%       test video
        start_sec = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
%       read gaze data
        gzd = dlmread(filename,'	',15, 0);

%       the video has been scaled down so this normalises the y data
        ratio_y = 720/1024;

        data = [];
%       extract the gaze data relevant only to this clip
        for i = 1:size(gzd)
            timestamp = gzd(i,1)/1000;
            if timestamp >= start_sec(1,clipno) && timestamp <= start_sec(2,clipno)
                data = [data; gzd(i,:)];
            end
        end

        X = []; 

        time = [];
        %       retrieve x values for left and right eyes
        X_L = data(:,3); X_R = data(:,10);
%       retrieve y values for left and right eyes/
        Y_L = data(:,4); Y_R = data(:,11);
%       retrieve the centre of vision for each pair of eye points
        X_M = mean([X_L X_R],2);
        Y_M = mean([Y_L Y_R], 2);
        
%       X is the annotation for the data used in the netlab documentation
%       and in traditional formulae
%       in this case the mixtures will be 2-dimensional models
        X = [X_M Y_M];
        time = (data(:,1)/1000) - start_sec(clipno);

        
        n = size(X,1);
        clusters = [];
        
%       The following algorithm is the definition for finding saccades in
%       eye tracking data as stated by O. Le Meur et al. in Overt Visual
%       Attention for free-viewing and quality assessment tasks, Impact of
%       the regions of interest on a video quality metric.

        numFrames = 0;
        clusters = [];
        for i = 1:n
             point = X(i,:);
             x = point(1); y = point(2);
             if x < 0 || x > 1280 || y < 0 || y > 720
                 clusters = [clusters mix.ncentres + 1];
             else
                 post = gmmpost(mix, point);
 
 
                 [val ind] = min(post);
 
                 clusters = [clusters ind];
             end 
        end
        
%       each value of fixationcnt is either the index of the cluster the
%       eye is currently in if a fixation is possibly occurring at this
%       frame, or 0 otherwise
        fixationcnt = [0];
        for i = 2:n
%           Calculate point-to-point velocity
            velx = abs(X(i,1) - X(i-1,1))*52;
            vely = abs(X(i,2) - X(i-1,2))*52;
            vel = sqrt((velx^2+vely^2));
%           convert velocity from px/s to deg/s
%           assuming 33px to 1 degree, given a 75dpi display
            vel = vel/33;
%           if velocity is under 25deg/s then count it as a potential
%           fixation
            if vel < 25 && clusters(i) == clusters(i-1)
                fixationcnt = [fixationcnt; clusters(i)];
            else
                fixationcnt = [fixationcnt; 0];
            end
        end
%       if a group of fixation points lasts for longer than 100ms,
%       approx. 5 frames at 52fps, then count this as a saccade
        saccade = [];
        cnt = 0;
        for i = 2:n
            if fixationcnt(i) == fixationcnt(i-1) && fixationcnt(i)~= 0
                cnt = cnt + 1;
            else
                if cnt >= 5
                    saccade = [saccade ; fixationcnt(i-1)];
                end
            end
        end
        totalSacc = [];
        for i = 1:mix.ncentres+1
            totalSacc(i) = sum(saccade==i);
        end
        subplot(2,4,subject);
        bar(totalSacc);
        xlabel('Cluster');
        ylabel('Total Saccades in Cluster');
        title(strcat('Expert', int2str(subject)));
    end

    saveas(gcf, strcat('ExpertClip', int2str(clipno),'Saccades','.jpg'));
    saveas(gcf, strcat('ExpertClip', int2str(clipno),'Saccades','.fig'));
    close(gcf);
end