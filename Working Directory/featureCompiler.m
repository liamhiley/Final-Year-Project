function [] = featureCompiler(clipno)
    exp = [];
    lay = [];
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
    load(strcat(working,'ExpertClip',int2str(clipno),'numTransitions.mat'));
    exp = [exp zscore(numTrans)];
    load(strcat(working,'LayClip',int2str(clipno),'numTransitions.mat'));
    lay = [lay zscore(numTrans)];
    
    c = cvpartition(15,'LeaveOut');
    fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT),Xt))));
    opts = statset('display','iter');
    inmdl = sequentialfs(fn, [exp; lay], [ones(8,1);zeros(7,1)-1],'cv',c, 'options', opts);
    coeff = pca([exp; lay])
end