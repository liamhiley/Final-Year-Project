function [] = errorOfEachNet(vid_no)
    str_prob = '';
    start_sec = [30, 49, 69, 89, 109, 129, 154, 174, 194, 214, 234, 254, 275, 295];
    fid = fopen('experterr.txt', 'wt');
    for expert = 1:8
        load(strcat('expert', int2str(expert), '.net'),'mix','-mat');
        expert_file = dlmread(strcat('AnaesExpert', int2str(expert), 'videoGZD.txt'), '	', 15, 0);
        timestamps = expert_file(:,1) / 1000;
        video_data = expert_file(timestamps > start_sec(vid_no),:);
        timestamps = video_data(:,1) / 1000;
        video_data = video_data(timestamps < start_sec(vid_no+1),:);
        x = (video_data(:,3) + video_data(:,10))/2;
        y = (video_data(:,4) + video_data(:,11))* 0.7031/2;
        X = [x y];
        error = -sum(log(gmmprob(mix,X)));
        err = sprintf('Error is %0.10f for Expert %i\n', error, expert);
        str_prob = strcat(str_prob, '\n', err);
    end
    fprintf(fid, str_prob);
    fclose(fid);
end