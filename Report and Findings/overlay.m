%   for each frame in the video
    while hasFrame(rdr)
        vidframe = readFrame(rdr);
        imshow(vidframe);
        hold on;
%       get the corresponding frame in the eye tracking data
        gzframe = data(i,:);
%       for every frame after the first
        if size(prevframe,1) > 0
%           plot the trace from the last left,right and centre gazepoints
%           to the current ones
            plot([prevframe(3) gzframe(3)],[prevframe(4) gzframe(4)],'b-');
            plot([prevframe(10) gzframe(10)],[prevframe(11) gzframe(11)],'r-');
            plot([prev_mn(1) mn_pnt(1)],[prev_mn(2) mn_pnt(2)],'k-');
        end
%       plot the current gazepoints on top of the trace to emphasise where
%       the gaze is travelling
        plot(gzframe(3),gzframe(4),'bx');
        plot(gzframe(10),gzframe(11),'rx');
        mn_pnt = mean([gzframe(3) gzframe(4);gzframe(10) gzframe(11)],1);
        plot(mn_pnt(1),mn_pnt(2),'kx','MarkerSize',10);
%       write the frame to the tracking video
        writeVideo(wrtr, getframe(gcf));
        prevframe = gzframe;
        prev_mn = mn_pnt;
        i = i + 1
    end
