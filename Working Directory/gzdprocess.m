function [X] = gzdprocess(filename,start_ind,end_ind,cut)
%   Processes a Gaze Data text file into a matrix of X and Y points
%   filename - the text file to be processed
%   start_ind, end_ind - defines the range of frames from within the text
%   file to process
%   cut - set to True to trim data that falls outside of the video 
    if ~exist('cut','var')
        cut = false;
    end

    data = dlmread(filename,'	',15, 0);
    data = data(start_ind:end_ind,:);

%   retrieve the centre of vision for each pair of eye points
    X_M = mean([data(:,3) data(:,10)],2);
    Y_M = mean([data(:,4) data(:,11)], 2);

%   for better visualisation ignore all points that would fall off of
%   the screen, these will be 'clustered' as a false cluster in a
%   different function
    if cut
        X_M = X_M(720 > Y_M & Y_M > 0);
        Y_M = Y_M(720 > Y_M & Y_M > 0);
%       repeat for y values
        Y_M = Y_M(1281 > X_M & X_M >0);
        X_M = X_M(1281 > X_M & X_M > 0);
    end

%   X is the annotation for the data used in the netlab documentation
%   and in traditional formulae
%   in this case the mixtures will be 2-dimensional models
    X = [X_M Y_M];
end
