function [] = featureCompiler(clipno)
%   Loads in multiple features taken by measuring at small timesteps
%   through a video, each measure then becoming a feature. A
%   Gaussian mixture model is used to separate features into Gaussian
%   components. PCA is performed on each component, then the principal
%   components are compiled and ran through sequential feature selection to
%   devise the best subset of components for classification.

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
    load(strcat(working,'Temporal/TimeBetweenSaccades/ExpertClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    exp = [exp zscore(total_time(:,:))];
    load(strcat(working,'Temporal/TimeBetweenSaccades/LayClip',int2str(clipno),'TimeBetweenSaccades.mat'));
    lay = [lay zscore(total_time(:,:))];
    
%   the following can only be used with the static images
    if clipno < 7
        load(strcat(working,'Temporal/SaccadesPerCluster/ExpertClip',int2str(clipno),'SaccadesPerCluster.mat'));
        exp = zscore(sacc_per_cluster(:,:));
        load(strcat(working,'Temporal/SaccadesPerCluster/LayClip',int2str(clipno),'SaccadesPerCluster.mat'));
        lay = zscore(sacc_per_cluster(:,:));
        load(strcat(working,'Spatial/Variance/ExpertClip',int2str(clipno),'Variance.mat'));
        exp = [exp zscore(fix_var(:,:,1)') zscore(fixVar(:,:,2)')];
        load(strcat(working,'Spatial/Variance/LayClip',int2str(clipno),'Variance.mat'));
        lay = [lay zscore(fix_var(:,:,1)') zscore(fixVar(:,:,2)')];
        load(strcat(working,'/Spatial/numTransitions/ExpertClip',int2str(clipno),'numTransitions.mat'));
        exp = [exp zscore(num_trans(:,:))];
        load(strcat(working,'/Spatial/numTransitions/LayClip',int2str(clipno),'numTransitions.mat'));
        lay = [lay zscore(num_trans(:,:))];
    end
    
    
%   Combine expert and lay data
    X = [exp; lay];
    
    figure;
    [coeff, score, latent] = pca(X);
    norm_eig = 100*latent / sum(latent);
    
    title('PCA on complete data');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    hold on;
    plot(1:size(norm_eig,1),norm_eig,'kx');
    plot(1:size(norm_eig,1),norm_eig);
    saveas(gcf,strcat('Clip',int2str(clipno),'FullPCA','.jpg'));
    close(gcf);
%   Split components into  gaussian
%   Count number of components that produce 60% of the eigen energy
    i = 1;
    energy = 0;  
    while energy < 60
        energy = energy + norm_eig(i);
        i = i + 1;
    end
%   This will be the dimensionality of the mixture
    prinMix = gmm(i,2,'diag');
    options = foptions;
    prinMix = gmminit(prinMix, score(:,1:i), options);
    prinMix = gmmem(prinMix, score(:,1:i),options);
    post = gmmpost(prinMix,score(:,1:i));
    [val ind] = max(post');
    sc1 = []; sc2 = [];
    for j = 1:15
        if ind(j) == 1
            sc1 = [sc1;score(j,1:i)];
        else
            sc2 = [sc2; score(j,1:i)];
        end
    end
%   Find the explained variability of the principal components in each
%   Gaussian
    cov1 = cov(sc1); cov2 = cov(sc2);
    eig1 = eig(cov1); eig2 = eig(cov2);
    energ1 = sort(eig1*100/sum(eig1),'descend'); energ2 = sort(eig2*100/sum(eig2),'descend');
    
    figure;
    plot(1:i,energ1,'rx',1:i,energ2,'bx');
    hold on;
    plot(1:i,energ1,'r-',1:i,energ2,'b-');
    title('Percentage Eigen energy of PCs in two Gaussians')
    legend('G1','G2')
    xlabel('PC');
    ylabel('Eigen energy (%)');
    saveas(gcf,strcat('Clip',int2str(clipno),'GaussianPCA.jpg'));
    close(gcf);
    
%   Sort features based on their individual classification accuracy
    y = [ones(8,1);zeros(7,1)-1];
    fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT),Xt))));
    acc = zeros(1,size(X,2));
    c = cvpartition(y,'HoldOut',5);
    for i = 1:size(X,2)
        ft = X(:,i);
%       Iterate through the partition objects test data and evaluate the
%       feature based on mean classification loss
        err = zeros(c.NumTestSets,1);
        for test = 1:c.NumTestSets
            trIdx = c.training(test);
            tesIdx = c.test(test);
            XT = ft(trIdx);
            Xt = ft(tesIdx);
            yT = y(trIdx);
            yt = y(tesIdx);
            err(test) = fn(XT,yT,Xt,yt)/sum(tesIdx);
        end
        mnErr = sum(err)/size(err,1);
        acc(i) = 1 - mnErr;
    end
    [val ind] = max(acc)
    cX = [acc;X];
    cX = sort(cX,2,'descend');
    cX = cX(2:end,:);
    
%   Perform sequential feature selection on components        
    
    maxdev = chi2inv(.95,1);     
    opt = statset('display','iter',...
                'TolFun',maxdev,...
                'TolTypeFun','abs');
%   On original data
    inmodel = sequentialfs(fn,cX,y,'options',opt);
    
%   Use tsne for visualisation of data in two-dimensional
    group = {'expert';'expert';'expert';'expert';'expert';...
        'expert';'expert';'expert';'lay';'lay';'lay';'lay';...
        'lay';'lay';'lay',};
%   compare all distance measures
    cosX = tsne(X,'Distance','cosine','NumDimensions',3);
    eucX = tsne(X,'Distance','euclidean','NumDimensions',3);
    chebX = tsne(X,'Distance','chebychev','NumDimensions',3);
    
    v = double(categorical(group));
    c = full(sparse(1:numel(v),v,ones(size(v)),numel(v),3));
    
    figure;
    subplot(2,2,2);
    scatter3(cosX(:,1),cosX(:,2),cosX(:,3),15,c);
    title('Cosine');
    subplot(2,2,3);
    scatter3(eucX(:,1),eucX(:,2),eucX(:,3),15,c);
    title('Euclidean');
    subplot(2,2,4);
    scatter3(chebX(:,1),chebX(:,2),chebX(:,3),15,c);
    title('Chebychev');
    saveas(gcf,strcat('Clip',int2str(clipno),'t-SNE.fig'));
    close(gcf);


end