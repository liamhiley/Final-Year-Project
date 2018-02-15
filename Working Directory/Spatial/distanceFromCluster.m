function [] = distanceFromCluster(expertno, clipno)
    filename = strcat('Expert', int2str(expertno), 'Clip', int2str(clipno), '.fig');
    fig = openfig(filename);
    plots = findall(fig, 'Color', 'k');
    means = [plots(1).XData;plots(1).YData];
    close(gcf);
    filename = strcat('AnaesExpert', int2str(expertno), 'VideoGZD.txt');
    start_sec = [30, 49, 69, 89, 109, 129; 42, 63, 83, 103, 123, 137];
    gzd = dlmread(filename,'	',15, 0);
    
    ratio_y = 720/1024;
    
    data = [];
    for i = 1:size(gzd)
        timestamp = gzd(i,1)/1000;
        if timestamp >= start_sec(1,clipno) && timestamp >= start_sec(2,clipno)
            data = [data; gzd(i,:)];
        end
    end
    
    X = []; 
    
    time = [];
    for i = 1:size(data)
        x = mean([data(i,3), data(i,10)]);
        y = mean([data(i,4), data(i,11)])* ratio_y;
        if x > 0 && y > 0 && x < 1281 && y < 1281
            X = [X [x;y]];
            time = [time data(i,1)/1000];
        end
    end
    
    dist = [];
    key = [];
    figure('units','normalized','outerposition',[0 0 1 1]);
    hold on;
    n = size(means,2);
    for k = 1:size(means,2)
        for i = 1:size(X,2)
            pos = [X(1,i) means(1,k); X(2,i) means(2,k)];
            dist(i) = pdist(pos, 'euclidean');
        end
        %uncomment vel or both to generate graphs for velocity or
        %acceleration,
        %vel = [0 transpose(diff(dist(:))./diff(time(:)))];
        %acc = [0 transpose(diff(vel(:))./diff(time(:)))]
        subplot(ceil(sqrt(n)),ceil(sqrt(n)),k);
        plot(time(1:end), dist(1:end));
        title(strcat('Cluster ', int2str(k)));
        xlabel('Time (s)');
        ylabel('Distance');
    end
    
    saveas(gcf, strcat('Expert', int2str(expertno), 'Clip', int2str(clipno),'Distance','.jpg'));
    saveas(gcf, strcat('Expert', int2str(expertno), 'Clip', int2str(clipno),'Distance','.fig'));
    close(gcf);
end