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
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    
%   read in gaze data for subject
    data = dlmread(strcat(homepath,'/Working Directory/Data/',group,int2str(subject),'videoGZD.txt'),'	',15, 0);
%   select data relevant to the clip
    data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
    data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
    data(:,4) = data(:,4) * 720/1024;
    data(:,11) = data(:,11) * 720/1024;
    prevframe = [];
    size(data,1)
    i = 1
    for gzframe = data'
        vidframe = readFrame(rdr);
        imshow(vidframe);
        hold on;
        if size(prevframe,1) > 0
            plot([prevframe(3) gzframe(3)],[prevframe(4) gzframe(4)],'b-');
            plot([prevframe(10) gzframe(10)],[prevframe(11) gzframe(11)],'r-');
            plot([prev_mn(1) mn_pnt(1)],[prev_mn(2) mn_pnt(2)],'k-');
        end
        plot(gzframe(3),gzframe(4),'bx');
        plot(gzframe(10),gzframe(11),'rx');
        mn_pnt = mean([gzframe(3) gzframe(4);gzframe(10) gzframe(11)],1);
        plot(mn_pnt(1),mn_pnt(2),'kx','MarkerSize',10);
        writeVideo(wrtr, getframe(gcf));
        prevframe = gzframe;
        prev_mn = mn_pnt;
        i = i + 1
    end
    
    close(wrtr);
end