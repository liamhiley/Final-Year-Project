function [] = GazeGMM(clipno, mix)

    if ~exist('clipno','var')
        clipno = 3;
    end
    
    
    
    %read the gaze data file in the first time to get the range of rows
    %that will be used
    data = dlmread('AnaesExpert1videoGZD.txt','	',15, 0);
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
    %we now have the starting and ending index of the eye data, and the
    %time
    start_ind = j;
    end_ind = i;
    
    
    X =[];
    %for each expert, add there average gaze points to the dataset
    for i = 1:8
        if i==7
            continue;
        end
        filename = strcat('AnaesExpert', int2str(i), 'VideoGZD.txt');
        data = dlmread(filename,'	',15, 0);
        X = gzdprocess(filename,start_ind,end_ind);
    end
    
    img = read(video,1);
    imshow(img);
    hold on;
    
    %no of dimensions of matrix
    dim = 2;
    
    options = foptions;
    options(14) = 1; % A single iteration
    options(1) = -1; % Switch off all messages, including warning

    
    if ~exist('mix','var')
        switch clipno
            case 1
                ncentres = 7;
            case 2
                ncentres = 7;
            case 3
                ncentres = 7;
            case 4
                ncentres = 7;
            case 5
                ncentres = 8;
            case 6
                ncentres = 4;
%             case 1
%                 ncentres = 9;
%             case 2
%                 ncentres = 7;
%             case 3
%                 ncentres = 13;
%             case 4
%                 ncentres = 7;
%             case 5
%                 ncentres = 8;
%             case 6
%                 ncentres = 4;
        end
        
        %create mixture model, covariance set to full
        mix = gmm(dim,ncentres, 'diag');
        

        %set options struct to use for dispExperting error at each cycle later
        
        mix = gmminit(mix,X,options);
    end
    
    %the below line can be used to aid the model slightly by specifiying
    %the initial cluster centre points
    switch clipno
        case 1
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            mix.centres = [300 300; 300 500; 400 300; 450 500; 650 300; 650 200; 500 200; 350 200; 100 400; 900 400];
        case 2
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            mix.centres = [400 250; 100 550; 500 600; 650 600; 650 200; 300 200; 100 600];
        case 3
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            %mix.centres = [100 350; 400 50; 400 550; 450 350; 500 350; 750 450; 900 300]
        case 4
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            %mix.centres = [480 400; 480 100; 530 220];
        case 5
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            %mix.centres = [480 400; 480 100; 530 220];
        case 6
            %guess at  mix parameters (these are gathered from previous k means clustering) 
            %mix.centres = [480 400; 480 100; 530 220];
    end
    
    %iterate through EM algorithm to improve fit to data points
    for i = 1:20000
        [mix, options] = gmmem(mix, X, options);
    end
    fprintf(1,'Cycle %4d, Error %11.6f\n',i, options(8));

    axis('equal');
        
    hp = zeros(mix.ncentres,1);
    for i = 1:mix.ncentres
        hp(i) = plot(mix.centres(i,1), mix.centres(i,2), 'marker', '*', 'markersize', 30);
    end

    for i = 1 : mix.ncentres
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
    
    saveas(gcf,strcat('ExpertClip', int2str(clipno),'Cluster.jpg'));
    saveas(gcf,strcat('ExpertClip', int2str(clipno),'Cluster.fig'));
    save expert.net mix -mat;
    
    close gcf;
end