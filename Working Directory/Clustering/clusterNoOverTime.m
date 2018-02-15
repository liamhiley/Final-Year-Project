function [] = clusterNoOverTime(clipno)
    load expert6.net mix -mat;
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    sbplot = 1;
    for expert = 1:8
        filename = strcat('AnaesExpert', int2str(expert), 'VideoGZD.txt');
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
            X = [X;[x y]];
            time = [time ((data(i,1)/1000)-(data(1,1)/1000))];
            
        end
        
        hold on;
        n = size(X,1);
        clusters = [];
        k = 1;
        for i = 1:n
            point = X(i,:);
            x = point(1);
            y = point(2);
            if x < 0 || x > 1280 || y < 0 || x > 1280
                clusters = [clusters mix.ncentres + 1];
            else
                post = gmmpost(mix, point);


                [val ind] = min(post);

                clusters = [clusters ind];
            end
            
        end
        
        
        
        seg = size(X,1)/(mix.ncentres + 1);
        
        for i = 1:seg:size(X,1)
            legend(round(i):round(seg)+round(i-1)) = (seg + i - 1) / seg;
        end
        
        subplot(5,2,sbplot);
        if sbplot == 1
            leg_plot = surface(time, legend, 'linew', 20, 'edgecolor', 'interp');
            title('Legend');
            hold on;
            sbplot = sbplot + 2;
            subplot(5,2,sbplot);
        end 
        surf_plot = surface(time, clusters, 'linew', 20, 'edgecolor', 'interp');
        ylim([0 3]);
        xlabel('Time');
        ylabel('Cluster Number');
        title(strcat('Expert ', int2str(expert)));
        hold off;
        sbplot = sbplot + 1;
    end

    saveas(gcf, strcat('ExpertClip', int2str(clipno),'ClusterNoOverTime','.jpg'));
    saveas(gcf, strcat('ExpertClip', int2str(clipno),'ClusterNoOverTime','.fig'));
    close(gcf);
end