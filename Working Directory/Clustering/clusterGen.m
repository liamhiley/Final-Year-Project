function [] = clusterGen
    for i = 1:8
        for j = 1:14
            if j > 6
                gazeMapOverlay(i, j, true);
            else
                gazeMapOverlay(i, j, false);                
            end
        end
    end
end