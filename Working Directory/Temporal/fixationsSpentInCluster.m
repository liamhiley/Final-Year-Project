function [] = fixationsSpentInCluster(clipno)
%   Generate discrete histograms for each subject in how often they fit 
%   into each of the components of the Lay model for that clip


%   get the Expert model for the clip
    load(strcat('Expert',int2str(clipno),'.net'), 'mix', '-mat');
%   initialise figure
    figure('units','normalized','outerposition',[0 0 1 1]);
%   subject can either be Expert, novice, or lay
    hold on;
    
    %read in the clip to be used
    video = VideoReader(strcat('EyeTrackingClip', int2str(clipno), '.avi'));
    
    data = dlmread('/Users/liam/Projects/Final-Year-Project/Working Directory/Data/AnaesExpert1videoGZD.txt','	',15, 0);
%   UNCOMMENT BELOW WHEN USING RANDOM CLASS
%   data = load(filename)

%       timestamps for beginning and ending of each clip within the whole
%       test video
        start_sec = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];


        %n is the number of frames for the clip
        n = round(video.FrameRate * video.Duration);

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
    for subject = 1:8
%       read in the gaze data for the subject, in the form
%       LayXVideoGZD.txt or AnaesExpertXVideoGZD.txt or NoviceXVideoGZD.txt
        filename = strcat('/Users/liam/Projects/Final-Year-Project/Working Directory/Data/AnaesExpert', int2str(subject), 'VideoGZD.txt');

        X = gzdprocess(filename, start_ind, end_ind);

        
        n = size(X,1);
        
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
    close(gcf);
end