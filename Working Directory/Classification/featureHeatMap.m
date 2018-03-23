function [] = featureHeatMap(clipno)
% This function takes all the features compiled, and classifies on all
% possible pairs of them. It then plots a heatmap of the top 10 in terms of
% accuracy.
    exp = [];
    lay = [];
%   load in various sets of features for experts and lays
    working = '/Users/liam/Projects/Final-Year-Project/Working Directory/';
    load(strcat(working,'Temporal/ExpertClip',int2str(clipno),'Saccades.mat'));
    exp = zscore(saccPerCluster);
    load(strcat(working,'Temporal/LayClip',int2str(clipno),'Saccades.mat'));
    lay = zscore(saccPerCluster);
    load(strcat(working,'Temporal/ExpertClip',int2str(clipno),'SaccadeDuration.mat'));
    exp = [exp zscore(saccDurPerCluster)];
    load(strcat(working,'Temporal/LayClip',int2str(clipno),'SaccadeDuration.mat'));
    lay = [lay zscore(saccDurPerCluster)];
    load(strcat(working,'Spatial/ExpertClip',int2str(clipno),'Variance.mat'));
    exp = [exp zscore(fixVar(:,:,1)') zscore(fixVar(:,:,2)')];
    load(strcat(working,'Spatial/LayClip',int2str(clipno),'Variance.mat'));
    lay = [lay zscore(fixVar(:,:,1)') zscore(fixVar(:,:,2)')];
    load(strcat(working,'/Spatial/ExpertClip',int2str(clipno),'numTransitions.mat'));
    exp = [exp zscore(numTrans)];
    load(strcat(working,'/Spatial/LayClip',int2str(clipno),'numTransitions.mat'));
    lay = [lay zscore(numTrans)];
    
%    Specify training and testing data using best partition
    X = [exp; lay];
    y = [ones(8,1); zeros(7,1) - 1];
    XT = [X(2:5,:); X(9:12,:)];
    yT = [y(2:5); y(9:12)];
    Xt = [X(1,:); X(6:8,:); X(13:end,:)];
    yt = [y(1); y(6:8); y(13:end)];
%    classify experts vs lays using feature i and feature j
    acc = zeros(75,75);
    for i = 1:75
        for j = 1:75
%          Define accuracy as the percentage of test observations
%          misclassified
           acc(i,j) = (sum(yt~=(predict(fitcsvm([XT(:,i) XT(:,j)],yT),...
               [Xt(:,i) Xt(:,j)]))))/size(yt,1);
        end
    end
%   display the heatmap of the classification results
    h = heatmap(acc);   
    for j = 1:75
        sortx(h,int2str(j));
    end
    saveas(gcf, strcat('pairwiseClassificationClip',int2str(clipno),'.png'));
    close(gcf);
    
end