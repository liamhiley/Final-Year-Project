
function [] = eightfold(clipno)
    for exclude = 1:8
        if ~exist('clipno','var')
            clipno = 2;
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

        load expert.net mix -mat

        %for each expert, add there average gaze points to the dataset
        for i = 1:8
            if i == exclude
                continue;
            end
            X =[];
            filename = strcat('AnaesExpert', int2str(i), 'VideoGZD.txt');
            data = dlmread(filename,'	',15, 0);
            data = data(start_ind:end_ind,:);

            for k = 1:size(data,1)

                %the aim of the below for loop is to cut the number of frames down to
                %the number of frames that the background video will show, this way 
                %record the fixations to be plotted over the video
                x = mean([data(k,3), data(k,10)]);
                y = mean([data(k,4), data(k,11)])* ratio_y;
                if x > 0 && y > 0 && x < 1281 && y < 720
                    X = [X;[x y]];
                end
            end
            
        end


        options = foptions; 
        options(14) = 1; % A single iteration
        options(1) = -1; % Switch off all messages, including warning

        for i = 1:2000
            [mix options] = gmmem(mix,X,options);
        end

        filename = strcat('AnaesExpert', int2str(exclude), 'VideoGZD.txt');
        data = dlmread(filename,'	',15, 0);
        data = data(start_ind:end_ind,:);
        j = 1;
        for k = 1:size(data,1)

            %the aim of the below for loop is to cut the number of frames down to
            %the number of frames that the background video will show, this way 
            %record the fixations to be plotted over the video
            x = mean([data(k,3), data(k,10)]);
            y = mean([data(k,4), data(k,11)])* ratio_y;
            if x > 0 && y > 0 && x < 1281 && y < 720
                X = [X;[x y]];
            end
        end

        error = -sum(log(gmmprob(mix,X)));

        save(strcat('expert',int2str(exclude),'.net'), 'mix', '-mat');
    end
end