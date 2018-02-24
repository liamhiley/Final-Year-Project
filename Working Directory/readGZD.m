function [] = readGZD(filename)
    data = dlmread(filename,'	',15, 0);
    X =[]; Y = [];
    video = VideoReader('EyeTrackingClip001.mp4');
    writer = VideoWriter('Expert001Clip001');
    open(writer);
    n = round(video.FrameRate * video.Duration);
    ratio_y = video.Height/1024;
    fixationX = [];
    fixationY = [];
    fixation = 0;
    
    i =1;
    while true
        time = data(i,1);
        if time / 1000 >= video.Duration
            break;
        end
        i = i + 1;
    end 
    data = data(1:i,:);
    %j will be used to index the store matrix
    j = 1;
    %the aim of the below for loop is to cut the number of frames down to
    %the number of frames that the background video will show
    for i = 1:size(data,1)      
        
        
        j = round(i * video.FrameRate / (size(data,1)/video.Duration));
        X(j) = (data(i,3) + data(i,10))/2;
        Y(j) = (data(i,4) + data(i,11))*ratio_y / 2;
        
    end
    for i = 1:n
        currentFrame = read(video,i);
        imshow(currentFrame);
        hold on;
        %j = i;
        %if i == 1
        %    scatter(LX(i,1), LY(i,1), 'b', 'filled');
            
        %else
        %   if abs(LX(i,1) - LX(i - 1,1)) > 20 || abs(LY(i,1) - LY(i - 1,1)) > 20
        %        j = i;
        %    end
        %    scatter(LX(j,1), LY(j,1), 'b', 'filled');
        %    if i > 5
        %        plot(LX(j-5:j,1),LY(j-5:j,1),'b-');
        %    else
        %        plot(LX(1:j,1), LY(1:j,1), 'b-');
        %    end
        %end
        scatter(X(i), Y(i), 'b', 'filled');
        if i > 5
            plot(X(i-5:i),Y(i-5:i),'b-');
        else
            plot(X(1:i), Y(1:i), 'b-');
        end
        eyeFrame = getframe(gca);
        writeVideo(writer,eyeFrame);
        hold off;
    end
    close(writer);
end