% clear all    %this clears any made objects
% close all force % this should force any open figure to close

% see notes from the videoEyePlot.m 
% all additional notes specific to this program will be detailed here. Thus
% excluding any duplication between files.

% REDUCTION CODE - this code in practice could be used in the normal video
% plot however i have chosen to keep them seperate. furthermore i have
% allowed all plottable plot data to be accepted i.e. this means lines or
% gazes outside the video scope are visible with a line coming or going
% into that direction. run video to see.. you can change this by follwoing
% the normal code and setting an if statement to deny such data..

function [ ] = videoEyePlotReduced( data, gx, gy, reductionSize )
% INITALIZATION =============================================================
    data = dlmread('AnaesExpert004videoGZD.txt', '	', 15, 0 );
    % create a video writer object to write figures to. see matlab vide
    % writer for more details
    % DIFFERENT VIDEO NAME!!!
    writerObj = VideoWriter('videoPlotReduced.avi');
    open(writerObj);
    
%   getting a mp4 file and relevent details2
    videoObj = VideoReader('Eye tracking.mp4');
    vidObj = VideoReader('Eye tracking.mp4'); 
    vidWidth = videoObj.Width;   %get width
    vidHeight = videoObj.Height;     % get height
    frameRate = videoObj.FrameRate;     % get frame rate of video only
    vidDuration = videoObj.Duration;  % time length of video
    % line 42 will be obselete in future release, thus use line 43
%     numFrames = vidObj.NumberOfFrames; 
    NumberOfFrames = round(vidDuration * frameRate);    
   % assigns n to the num rows and m to num colums of the 'data' file 
    [n m] = size(data);
    % 1000 milsecond = 1 second
    secondConverter = 1000;
    
    % IMPORTANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % place the number which you have scaled down the movie to. i.e. if you
    % have scaled the video down by 2 times the original size then the do; 
    reductionSize =2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% SCREEN INITIALIZATION AND CALCULATION =============================================    
    gx = 1280/reductionSize; %gaze screen size x value 
    gy= 1024/reductionSize; %gaze screen size y value
    paddingX = (gx - vidWidth)/2; % half the padding value - padding that covers the X axis
    paddingY = (gy - vidHeight)/2; % half the padding value - padding that covers the Y axis
    lowestPointY = paddingY; 
    highestPointY = paddingY + vidHeight;
    lowestPointX = paddingX; 
    highestPointX = paddingX + vidWidth;
    
% SORT DATA FROM FILE =============================================================
    dataPoint = 1;
    for i = 1:n % for each record of data in the gazedata file
        inSeconds = data(i,1) / secondConverter; % convert miliseconds to seconds because video is in secons and framerate 
        frameLocation = floor ( inSeconds * (frameRate) ); % refer to the issue statament mentioned above
        pos = (frameLocation+1); % use floor- round down,  label it to the current frame, rather than the next one
        if pos < 1 || pos >  NumberOfFrames
            continue;
        end
        storeData(dataPoint,1) = pos;
        storeData(dataPoint,2) = round(data(i,3)/abs(reductionSize));
        storeData(dataPoint,3) = round(data(i,4)/abs(reductionSize));
        storeData(dataPoint,4) = round(data(i,10)/abs(reductionSize));
        storeData(dataPoint,5) = round(data(i,11)/abs(reductionSize));
        storeData(dataPoint,6) = round (( storeData(dataPoint,2)+ storeData(dataPoint,4) ) /2); 
        storeData(dataPoint,7) = round (( storeData(dataPoint,3) + storeData(dataPoint,5) ) /2); 
        dataPoint = dataPoint +1;
    end % end for storing and converting timestamp to its corresponding frame  


   
% INITALIZE FOR PLOTTING =============================================================    
    [c r] = size(storeData); % of the data we organized/ extracted from the data file we 
    % call each column using c and each row with r
    counter = 1; % Pointer to current gaze point row to be added
    
% DISPLAYING EACH FRAME =============================================================    
% NOTE: here you may change the frame range you wish to plot the gazes on the video  
    for iFrame=1: NumberOfFrames
        % reset and clear matrix - for new frame data, otherwise it will only
        % rewrite certain indexes (it will keep the the unchanged/ new indexes - which is wrong!)
        LX = []; LY = []; RX = []; RY = []; avgX = []; avgY   = [];
        v = 1;
        w = 1;
        plotit = false;
%         figure('Visible','off'); % invisible figure - store but don't display
        % get one RGB image fprintf('Frame %d\n', iFrame);
        indivFrame = read(vidObj,iFrame); % read each video frame as image
        imshow(indivFrame,[]); % Display image
        hold on;
        for k = counter:c % Go from current gaze point to end of array which is the length of the column in var storedata
%             sizePlot = storeData(counter,7); % size of the scatter plot type
            if storeData(counter,1) == iFrame
            % retrieve data from the the storeData variable - data extracted from file and then 
            % assign it to and individual variable. with v increasing in each iteration
            % of the loop - store to different row we must subtract the padding the black excess 
            % screen space that encompasses the video
                avgX (v,1) = storeData(counter,6) - paddingX;
                avgY (v,1) = storeData(counter,7) - paddingY;
                LX(v,1) = storeData(counter,2) - paddingX;
                LY(v,1) = storeData(counter,3) - paddingY;
                RX(v,1) = storeData(counter,4) - paddingX;
                RY(v,1) = storeData(counter,5) - paddingY;
                counter = counter + 1;
                v = v + 1;
                % if the frame location/ plot is more than the frame then the loop 
                % will be exited until the 'if' is true. 
            elseif storeData(counter,1) >= iFrame
                break;
% executed when user input when the frame location is less than the frame start point given
% counter will increase until correct gaze data for the right/ specified frame is found
            elseif storeData(counter,1) <= iFrame
                counter = counter + 1;
            end
        end
        w = 1;
        % only execute if there has been a previous plot on an existing frame.
        if iFrame > 1
            %retrive previous counter by subtracting the number of plots. v
            %gives us the number of plot for that frame. we can then use
            %the previous v to figure out the path of the previous plot and
            % draw the path 
            for lastPlotCol = 1:2
                if lastPlotCol == 1
                    changeCounter = (counter - 1);
                else
                    changeCounter = (counter - v);
                end
                lastAvgX(w,lastPlotCol) = storeData(changeCounter,6) - paddingX;
                lastAvgY(w,lastPlotCol) = storeData(changeCounter,7) - paddingY;               
                lastLeftX(w,lastPlotCol) = storeData(changeCounter,2) - paddingX;
                lastLeftY(w,lastPlotCol) = storeData(changeCounter,3) - paddingY;
                lastRightX(w,lastPlotCol) = storeData(changeCounter,4) - paddingX;
                lastRightY(w,lastPlotCol) = storeData(changeCounter,5) - paddingY;
            end
            % because its true, activate lock and then executes the plot
            % statements below
            plotit = true; 
        end
        % the average or middle between the both eyes, left and then righ eye gazes, entire index plotted
        scatter(avgX(1:end),avgY(1:end),80,'g','filled');  
        scatter(LX(1:end),LY(1:end),40,'r','filled'); %% display left eye gaze
        scatter(RX(1:end),RY(1:end),40,'b','filled'); %% display only right eye gaze
        if plotit == true
            % plots the lines of path of previous gazes
            plot(lastAvgX(1:end),lastAvgY(1:end),'g-', lastLeftX(1:end),lastLeftY(1:end),'r-',...
                lastRightX(1:end),lastRightY(1:end),'b-');
        end
        % display lines, travel distance from multipul gazes -> current gazes, not previous ones
        plot(avgX(1:end),avgY(1:end),'g-',LX(1:end),LY(1:end),'r-',RX(1:end),RY(1:end),'b-');
        thisFrame = getframe(gca);
        % Write this frame out to a new video file.
        writeVideo(writerObj, thisFrame);
        % pause after each, default with no parameters is on click, for
        % time place int in the paraenthesies
        
        hold off;
    end
    close(writerObj); %% close the file - storing frame to file, otherwise won't save as it
    % hasn't ended
     implay('videoEyePlotReduced.avi'); %% play the video file in video player - forward and reverse back
end % end entire function
