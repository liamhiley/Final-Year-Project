function [] = featureHeatMap(clipno)
% This function takes all the features compiled, and classifies on all
% possible pairs of them. It then plots a heatmap of the top 10 in terms of
% accuracy.
    exp = [];
    lay = [];
%   load in various sets of features for experts and lays
    working = '/Users/liam/Projects/Final-Year-Project/Working Directory/';
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
    

%    Specify training and testing data using best partition
    X = [exp; lay];
    y = [ones(8,1); zeros(7,1) - 1];
    XT = [X(2:5,:); X(9:12,:)];
    yT = [y(2:5); y(9:12)];
    Xt = [X(1,:); X(6:8,:); X(13:end,:)];
    yt = [y(1); y(6:8); y(13:end)];
%   classify experts vs lays using feature i and feature j
    if clipno < 7
        n_ft = 8*15 + 1;
    else
        n_ft = 4*15 + 1;
    end
    acc = zeros(n_ft,n_ft);
    for i = 1:n_ft
        for j = 1:n_ft
%          Define accuracy as the percentage of test observations
%          misclassified
           mdl = fitcsvm([X(:,i) X(:,j)],y,'KernelFunction','polynomial', 'KernelScale', 'auto','BoxConstraint',0.01);
           cvmdl = crossval(mdl,'holdout',0.3);
           acc(i,j) = 1 - kfoldLoss(cvmdl);
        end
    end
%   display the heatmap of the classification results
    h = heatmap(acc);   
    saveas(gcf, strcat('pairwiseClassificationClip',int2str(clipno),'.png'));
    close(gcf);
    
end