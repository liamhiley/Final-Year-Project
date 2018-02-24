function [] = varPerClip(clipno, group)
    if strcmp(group,'Expert')
        n_subjects = 8;
    else
        n_subjects = 7;
    end
    homepath = '/Users/liam/Projects/Final-Year-Project';
%   get the Expert model for the clip
    load(strcat('expert',int2str(clipno),'.net'), 'mix', '-mat');
%   initialise figure
    figure('units','normalized','outerposition',[0 0 1 1]);
%   subject can either be Expert, novice, or lay
    hold on;
    
    %   timestamps for beginning and ending of each clip within the whole
%   test video
    timestmps = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    mnFix = [];
    fixVar = zeros(n_subjects,2);
    for subject = 1:n_subjects
        data = dlmread(strcat(homepath,'/Working Directory/Data/',group,int2str(subject),'videoGZD.txt'),'	',15, 0);
        data = data(data(:,1)>(timestmps(1,clipno)*1000),:);
        data = data(data(:,1)<(timestmps(2,clipno)*1000),:);
        mnFix = [mnFix; [mean([data(:,3) data(:,10)],2) mean([data(:,4) data(:,11)],2)]];
        fixVar(subject,:) = var(mnFix);
    end
    x = 1:n_subjects;
    ylim([0 250000]);
    bar(fixVar);
    xlabel(group);
    title('Variance per Subject');
    saveas(gcf, strcat(group, 'Clip', int2str(clipno), 'Variance.jpg'));
    save(strcat(group, 'Clip', int2str(clipno), 'Variance.mat'),'fixVar');
    close(gcf);
end
