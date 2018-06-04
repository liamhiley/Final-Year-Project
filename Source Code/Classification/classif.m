function [res] = classif(clipno)
    clipno
    exp = [];
    lay = [];
%   load in various sets of features for experts and lays
    working = '/Users/liam/Projects/Final-Year-Project/Working Directory/';
%   The following can be used for all clips
    %   The following can be used for all clips
    load(strcat(working,'Temporal/SaccadeCount/ExpertClip',int2str(clipno),'SaccadeCount.mat'));
    exp = [exp zscore(sacc_cnt(:,:))];
    load(strcat(working,'Temporal/SaccadeCount/LayClip',int2str(clipno),'SaccadeCount.mat'));
    lay = [lay zscore(sacc_cnt(:,:))];
    load(strcat(working,'Temporal/SaccadeDuration/ExpertClip',int2str(clipno),'SaccadeDuration.mat'));
    exp = [exp zscore(sacc_dur_per_step(:,:))];
    load(strcat(working,'Temporal/SaccadeDuration/LayClip',int2str(clipno),'SaccadeDuration.mat'));
    lay = [lay zscore(sacc_dur_per_step(:,:))];
    load(strcat(working,'/Spatial/DistanceTravelled/ExpertClip',int2str(clipno),'DistanceTravelled.mat'));
    exp = [exp zscore(total_dist(:,:))];
    load(strcat(working,'/Spatial/DistanceTravelled/LayClip',int2str(clipno),'DistanceTravelled.mat'));
    lay = [lay zscore(total_dist(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/ExpertClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    exp = [exp zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/LayClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    lay = [lay zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeToInitialSaccade/ExpertClip',int2str(clipno),'InitSaccade.mat'));
    exp = [exp zscore(init_saccs')];
    load(strcat(working,'Temporal/TimeToInitialSaccade/LayClip',int2str(clipno),'InitSaccade.mat'));
    lay = [lay zscore(init_saccs')];
%   the following can only be used with the static images
    if clipno < 7
        load(strcat(working,'Temporal/SaccadesPerCluster/ExpertClip',int2str(clipno),'SaccadesPerCluster.mat'));
        exp = [exp zscore(sacc_per_cluster(:,:))];
        load(strcat(working,'Temporal/SaccadesPerCluster/LayClip',int2str(clipno),'SaccadesPerCluster.mat'));
        lay = [lay zscore(sacc_per_cluster(:,:))];
        load(strcat(working,'Spatial/Variance/ExpertClip',int2str(clipno),'Variance.mat'));
        exp = [exp zscore(fix_var(:,:,1)') zscore(fix_var(:,:,2)')];
        load(strcat(working,'Spatial/Variance/LayClip',int2str(clipno),'Variance.mat'));
        lay = [lay zscore(fix_var(:,:,1)') zscore(fix_var(:,:,2)')];
        load(strcat(working,'/Spatial/numTransitions/ExpertClip',int2str(clipno),'numTransitions.mat'));
        exp = [exp zscore(num_trans(:,:))];
        load(strcat(working,'/Spatial/numTransitions/LayClip',int2str(clipno),'numTransitions.mat'));
        lay = [lay zscore(num_trans(:,:))];
    end
    
    X = [exp; lay];
    y = [ones(8,1);zeros(7,1)-1];
    mn_acc = zeros(50,1);
    meh_ft = zeros(50,1);
    good_ft = zeros(50,1);
    vgd_ft = zeros(50,1);
    for r = 1:20
        acc = zeros(1,size(X,2));

        for i = 1:size(X,2)
            ft = X(:,i);
    %       Iterate through the partition objects test data and evaluate the
    %       feature based on mean classification loss
            ftmdl = fitcsvm(ft,y,'KernelFunction','polynomial', 'KernelScale', 'auto','BoxConstraint',0.01);
            cvmdl = crossval(ftmdl, 'holdout', 0.3);
            acc(i) = 1 - kfoldLoss(cvmdl);
        end
        [val ind] = max(acc);
        cX = [acc;X];
        cX = sort(cX,2,'descend');
        cX = cX(2:end,:);
        
        acc = acc(~isnan(acc));
        mn_acc(r) = mean(acc);
        meh_ft(r) = sum(acc>0.5);
        good_ft(r) = sum(acc>0.7);
        vgd_ft(r) = sum(acc == 1);
    end
    res = [mean(mn_acc) mean(meh_ft) mean(good_ft) mean(vgd_ft)];
    
end