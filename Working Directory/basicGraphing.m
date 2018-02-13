function [ ] = basicGraphing(files )   
%     files = {'AnaesExpert001videoGZD.txt','AnaesExpert003videoGZD.txt','AnaesExpert004videoGZD.txt', 'AnaesExpert005videoGZD.txt'} ;
%     files = {'Lay001_videoGZD.txt','Lay002videoGZD.txt', 'Lay003-RecordingVideoGZD.txt', 'Lay004VideoGZD.txt'};
    
    % different durations of media - capture gazes at these times
    timeRange = [ 9990 24900; 29900 44900; 49900 64900; 69900 84900; 89900 104900; 109900 124900;
    129900 144900; 154900 169900; 174900 189900; 194900 209900; 214900 229900; 
    234900 249900; 254900 269900; 274900 289900; 294900 309900];
    lowestPoint = 152;
    highestPoint = 872;
    sequence = cell(1,length(files));
    gx = 1280; %gaze screen size x value 
    gy= 1024; %gaze screen size y value
    videoHeight = 720;
    videoWidth = 1280;
    paddingX = (gx - videoWidth)/2; % actual video size without the padding 
    paddingY = (gy - videoHeight)/2; % height or y of video size without the padding 
    
    % go throught every file
    for f = 1 : length(files)
        name = files{f}; 
        storeData = []; % clears and initilise the matrix
        data = dlmread(name, '	', 15, 0 ); % as usual skips and reads file
        [n m] = size(data);
        [c r] = size(timeRange);
        
        newIndex = 1;
    
        for dataIndex = 1:n % for eahc record of data in the gazedata file
            if data(dataIndex,3) < 0 || data(dataIndex,3) > 1280 || data(dataIndex,10) < 0 ... 
                    || data(dataIndex,10) > 1280 || data(dataIndex,4) < lowestPoint || data(dataIndex,4) > highestPoint || ...
                    data(dataIndex,11) < lowestPoint || data(dataIndex,11) > highestPoint
                continue
            else
                storeData(newIndex,1) = data(dataIndex,1);
                storeData(newIndex,2) =round (( data(dataIndex,3)+ data(dataIndex,10) ) /2); 
                storeData(newIndex,3) = round ( videoHeight -( (( data(dataIndex,4) + data(dataIndex,11)) /2)-152 ));
                
                newIndex = newIndex + 1;
            end         
            
        end % end for finding the average co-ordinate
        
        
        [rows, cols] = size(storeData);
        for time = 1:c
           tempArray = []; 
            s= 1;
            for i = 1: rows 
               
                if storeData(i,1) >= timeRange(time,1) && storeData(i,1) <= timeRange(time,2)
                   tempArray(s,1) = storeData(i,2);
                   tempArray(s,2) = storeData(i,3); 
                   sequence {time, f} =  tempArray;
                   s = s+1;
                end % end if
                
%                 sequence {time, f} =  tempArray;
            
            end % end for each row in file
            
        end % end for each time range

    end % end for each file
  
    for collate = 1: c
        sequence {collate,1} = vertcat (sequence {collate,1:length(files)}); %% see vertcat docs - collates all row data      
    end

    [numSeq, numSubject] = size(sequence);
for scene = 1: 1%numSeq
    figure;
    for subject =1 :numSubject
        t = cell2mat(sequence(scene,subject));

        plot(t(:,1),t(:,2));
        hold on;
    end
%     scene
%     subject
    hold off;
end

end









