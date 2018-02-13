function [] = videoClipper(filename)
    in_vid = VideoReader(filename);
    video = VideoWriter('EyeTrackingClip14');
    numFrames = in_vid.FrameRate * in_vid.Duration;
    open(video);
    start = false;
    for i = 1:numFrames
        frame = read(in_vid,i);
        rFrame = frame(:,:,1);
        gFrame = frame(:,:,2);
        bFrame = frame(:,:,3);
        r = mean(mean(rFrame));
        g = mean(mean(gFrame));
        b = mean(mean(bFrame));
        if r < 5 && g < 5 && b < 5
            if start
                break
            end
        else
            start = true;
            writeVideo(video,frame);
        end
    end
    close(video);
end