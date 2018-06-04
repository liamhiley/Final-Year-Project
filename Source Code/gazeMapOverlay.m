function [] = gazeMapOverlay(clipno,is_image)
    if ~exist('is_image','var')
        is_image = true;
    end
    if ~exist('clipno','var')
        clipno = 1;
    end
    
    data = dlmread('/Data/AnaesExpert1videoGZD.txt','	',15, 0);
    start_sec = [30, 49, 69, 89, 109, 129, 154, 174, 194, 214, 234, 254, 275, 295];
    
    video = VideoReader(strcat('../Media/EyeTrackingClip', int2str(clipno), '.mp4'));
    if ~is_image
        writer = VideoWriter('Expert1Clip1');
    end    
    n = round(video.FrameRate * video.Duration);
    ratio_y = video.Height/1024;
    eye_frame = start_sec(clipno) * (data(end,2)/(data(end,1)/1000));
    i = floor(eye_frame);
    j = i;
    
    while true
        if i > size(data,1)
            break;
        end
        time = data(i,1);
        if (time / 1000 >= start_sec(clipno) + video.Duration)
            break;
        end
        i = i + 1;
    end 
    start_ind = j;
    end_ind = i;
    
    X =[0 0];
    for i = 1:8
        filename = strcat('AnaesExpert', int2str(i), 'VideoGZD.txt');
        data = dlmread(filename,'	',15, 0);
        data = data(start_ind:end_ind,:);
        j = 1;
        for k = 1:size(data,1)
                        
            %the aim of the below for loop is to cut the number of frames down to
            %the number of frames that the background video will show, this way 
            %record the fixations to be plotted over the video
            x = mean([data(k,3), data(k,10)]);
            y = mean([data(k,4), data(k,11)])* ratio_y;
            if x > 0 && y > 0 && x < 1281 && y < 1281
                X = [X;[x y]];
            end
        end
    end 
    
    
    
    
    
    
    
    %the second argument is k, when using new data, this should be set to
    %1, and then reset to the number of appropriate or visibly distinct
    %clusters as determined by the user
    dim = 4969
    mix = gmm(dim, 7, 'full');
    [idx, C] = kmeans(X,7,'Distance', 'sqeuclidean', 'Replicates', 50);
    if ~is_image
        open(writer);
        for i = 1:n 
            currentFrame = read(video,i);
            imshow(currentFrame);
            hold on;
            for j = 1:size(idx)
                scatter(X(idx==j,1),X(idx==j,2),'filled');
            end
            plot(C(:,1),C(:,2),'ks','MarkerFaceColor','k');
            eyeFrame = getframe(gca);
            writeVideo(writer,eyeFrame);
            hold off;
        end
        close(writer);
    else
        img = read(video,1);
        imshow(img);
        hold on;
        for j = 1:size(idx)
            scatter(X(idx==j,1),X(idx==j,2),'filled');
        end
        plot(C(:,1),C(:,2),'ks','MarkerFaceColor','k');
        hold off;
        saveas(gcf, strcat('Clip', int2str(clipno),'Cluster.jpg'));
        saveas(gcf, strcat('Clip', int2str(clipno),'Cluster.fig'));
    end
end