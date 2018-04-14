function [] = featureHeatMap(clipno)
% This function takes all the features compiled, and classifies on all
% possible pairs of them. It then plots a heatmap of the top 10 in terms of
% accuracy.
    exp = [];
    lay = [];
%   load in various sets of features for experts and lays
    working = '/Users/liam/Projects/Final-Year-Project/Working Directory/';
    %The following can be used for all clips
    load(strcat(working,'Temporal/SaccadeCount/ExpertClip',int2str(clipno),'SaccadeCount.mat'));
    exp = [exp zscore(sacc_cnt(:,:))];
    load(strcat(working,'Temporal/SaccadeCount/LayClip',int2str(clipno),'SaccadeCount.mat'));
    lay = [lay zscore(sacc_cnt(:,:))];
    load(strcat(working,'Temporal/SaccadeDuration/ExpertClip',int2str(clipno),'SaccadeDuration.mat'));
    exp = [exp zscore(sacc_dur_per_cluster(:,:))];
    load(strcat(working,'Temporal/SaccadeDuration/LayClip',int2str(clipno),'SaccadeDuration.mat'));
    lay = [lay zscore(sacc_dur_per_cluster(:,:))];
    load(strcat(working,'/Spatial/DistanceTravelled/ExpertClip',int2str(clipno),'DistanceTravelled.mat'));
    exp = [exp zscore(total_dist(:,:))];
    load(strcat(working,'/Spatial/DistanceTravelled/LayClip',int2str(clipno),'DistanceTravelled.mat'));
    lay = [lay zscore(total_dist(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/ExpertClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    exp = [exp zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/LayClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    lay = [lay zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/ExpertClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    exp = [exp zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/LayClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    lay = [lay zscore(total_time(:,:))];
    
    load(strcat(working,'Temporal/SaccadesPerCluster/ExpertClip',int2str(clipno),'SaccadesPerCluster.mat'));
    exp = zscore(sacc_per_cluster(:,:));
    load(strcat(working,'Temporal/SaccadesPerCluster/LayClip',int2str(clipno),'SaccadesPerCluster.mat'));
    lay = zscore(sacc_per_cluster(:,:));
    load(strcat(working,'Spatial/Variance/ExpertClip',int2str(clipno),'Variance.mat'));
    exp = [exp zscore(fixVar(:,:,1)') zscore(fixVar(:,:,2)')];
    load(strcat(working,'Spatial/Variance/LayClip',int2str(clipno),'Variance.mat'));
    lay = [lay zscore(fixVar(:,:,1)') zscore(fixVar(:,:,2)')];
    load(strcat(working,'/Spatial/numTransitions/ExpertClip',int2str(clipno),'numTransitions.mat'));
    exp = [exp zscore(numTrans(:,:))];
    load(strcat(working,'/Spatial/numTransitions/LayClip',int2str(clipno),'numTransitions.mat'));
    lay = [lay zscore(numTrans(:,:))];
    
%    Specify training and testing data using best partition
    X = [exp; lay];
    y = [ones(8,1); zeros(7,1) - 1];
    XT = [X(2:5,:); X(9:12,:)];
    yT = [y(2:5); y(9:12)];
    Xt = [X(1,:); X(6:8,:); X(13:end,:)];
    yt = [y(1); y(6:8); y(13:end)];
%    classify experts vs lays using feature i and feature j
    acc = zeros(105,105);
    for i = 1:105
        for j = 1:105
%          Define accuracy as the percentage of test observations
%          misclassified
           acc(i,j) = (sum(yt~=(predict(fitcsvm([XT(:,i) XT(:,j)],yT),...
               [Xt(:,i) Xt(:,j)]))))/size(yt,1);
        end
    end
%   display the heatmap of the classification results
    h = heatmap(acc);   
    saveas(gcf, strcat('pairwiseClassificationClip',int2str(clipno),'.png'));
    close(gcf);
    
end