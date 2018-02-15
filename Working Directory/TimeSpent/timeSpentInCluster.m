function [] = timeSpentInCluster(clipno)
%   Generate discrete histograms for each subject in how often they fit 
%   into each of the components of the Lay model for that clip


%   get the Expert model for the clip
    load(strcat('Expert',int2str(clipno),'.net'), 'mix', '-mat');
%   initialise figure
    figure('units','normalized','outerposition',[0 0 1 1]);
%   subject can either be Expert, novice, or lay
    for subject = 1:7
%       read in the gaze data for the subject, in the form
%       LayXVideoGZD.txt or AnaesExpertXVideoGZD.txt or NoviceXVideoGZD.txt
        filename = strcat('Lay', int2str(subject), 'VideoGZD.txt');
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

        
        hold on;
        n = size(X,1);
        clusters = [];
        k = 1;


       
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
         subplot(2,4,subject);
      
         totalTime = zeros(1,max(clusters));
         
         curr_cluster = clusters(1);
         num_con_frames = 0;
         for i = 2:size(clusters,2)
             if clusters(i) == curr_cluster
                 num_con_frames = num_con_frames + 1;
             elseif num_con_frames >= 16
                 totalTime(curr_cluster) = totalTime(curr_cluster) + 1;
             end
             curr_cluster = clusters(i);
         end


        bar(totalTime);
        xlabel('Cluster');
        ylabel('Total Saccades in Cluster');
        title(strcat('Lay', int2str(subject)));
    end

    saveas(gcf, strcat('LayClip', int2str(clipno),'Saccades','.jpg'));
    saveas(gcf, strcat('LayClip', int2str(clipno),'Saccades','.fig'));
    close(gcf);
end