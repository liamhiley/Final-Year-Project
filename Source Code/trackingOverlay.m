function [] = trackingOverlay(clipno,subject,group)
%   plots eye tracking data for each frame from a subject over the video
%   the subject is watching
%   clipno - the clip number
%   subject - e.g. subject = 1 for Expert1videoGZD.txt
%   group - 'Expert' or 'Lay'

%   define path to project folder
    homepath = '/Users/liam/Projects/Final-Year-Project';
    
%   initialise video reader to read video in frame by frame
    rdr = VideoReader(strcat(homepath,'/Media/EyeTrackingClip',int2str(clipno),'.mp4'));
%   video writer will write the new video with the overlay included
    wrtr = VideoWriter(strcat(homepath,'/Media/Overlayed',group,int2str(subject),'TrackingClip',int2str(clipno)));
    open(wrtr);
    
%   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 50, 70, 90, 110, 130, 155, 175, 195, 215, 235; 45, 65, 85, 105, 125, 145, 170, 190, 210, 230, 250];
    
%   read in gaze data for subject
    data = dlmread(strcat(homepath,'/Source Code/Data/',group,int2str(subject),'videoGZD.txt'),'	',15, 0);
%   select data relevant to the clip
    data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
    data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
    if clipno > 6
        data(:,3) = data(:,3) * 720/1280;
        data(:,10) = data(:,10) * 720/1280;
        data(:,4) = data(:,4) * 368/1024;
        data(:,11) = data(:,11) * 368/1024;
    else
        data(:,4) = data(:,4) * 720/1024;
        data(:,11) = data(:,11) * 720/1024;
    end
    prevframe = [];
    size(data,1);
    i = 1;
    
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
        i = i + 1;
    end
    
    close(wrtr);
end