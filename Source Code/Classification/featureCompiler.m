function [sfs_acc] = featureCompiler(clipno)
%   Loads in multiple features taken by measuring at small timesteps
%   through a video, each measure then becoming a feature. A
%   Gaussian mixture model is used to separate features into Gaussian
%   components. PCA is performed on each component, then the principal
%   components are compiled and ran through sequential feature selection to
%   devise the best subset of components for classification.

    rng(73);
    
    exp = [];
    lay = [];
%   load in various sets of features for experts and lays
    working = '/Users/liam/Projects/Final-Year-Project/Source Code/';
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
    
    
%   Combine expert and lay data
    X = [exp; lay];
    
%     figure;
    [coeff, score, latent] = pca(X);
    [full_score,norm_eig] = filter_components(score,latent,80);
    
    title('PCA on complete data');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    hold on;
    plot(1:size(norm_eig,1),norm_eig,'kx');
    plot(1:size(norm_eig,1),norm_eig);
%     saveas(gcf,strcat('Clip',int2str(clipno),'FullPCA','.png'));
%     close(gcf);    
    
%   If the number of principal components after filtering is large, split 
%   components into  gaussian
    num_dim = size(full_score,2);
    if num_dim > 3
        while(true)
            prinMix = gmm(num_dim,2,'diag');
            options = foptions;
            prinMix = gmminit(prinMix, full_score, options);
            prinMix = gmmem(prinMix, full_score,options);
            post = gmmpost(prinMix,full_score);
            [val, ind] = max(post');
%           keep record of what subjects are in either gaussian
            subjects_in_1 = []; subjects_in_2 = [];
            sc1 = []; sc2 = [];
            for j = 1:15
                if ind(j) == 1
                    sc1 = [sc1;full_score(j,:)];
                    subjects_in_1 = [subjects_in_1; j];
                else
                    sc2 = [sc2; full_score(j,:)];
                    subjects_in_2 = [subjects_in_2; j];
                end
            end
            if min(size(sc1,1),size(sc2,1)) >= 5
                break;
            end
        end
%       Find the explained variability of the principal components in each
%       Gaussian
        cov1 = cov(sc1); cov2 = cov(sc2);
        eig1 = sort(eig(cov1),'descend'); eig2 = sort(eig(cov2),'descend');
        [sc1, energ1] = filter_components(sc1,eig1,60); 
        [sc2, energ2] = filter_components(sc2,eig2,60);

        figure;
        plot(1:num_dim,energ1,'rx',1:num_dim,energ2,'bx');
        hold on;
        plot(1:num_dim,energ1,'r-',1:num_dim,energ2,'b-');
        title('Percentage Eigen energy of PCs in two Gaussians')
        legend('G1','G2')
        xlabel('PC');
        ylabel('Eigen energy (%)');
%         saveas(gcf,strcat('Clip',int2str(clipno),'GaussianPCA.png'));
%         close(gcf);
%         save(strcat('ComponentDataClip',int2str(clipno),'.mat'),'sc1','sc2','subjects_in_1','subjects_in_2');
    else
%       Plot data transformed onto PCA space
        title('Scores of first two components');
        plot(full_score(1:8,1),full_score(1:8,2),'rx')
        hold on;
        plot(full_score(9:end,1),full_score(9:end,2),'bx');
        xlabel('PC1');
        ylabel('PC2');
%         saveas(gcf,strcat('Clip',int2str(clipno),'Transformed','.png'));
%         close(gcf);
%         save(strcat('ComponentDataClip',int2str(clipno),'.mat'),'full_score');
    end   

    
%   Sort features based on their individual classification accuracy
    y = [ones(8,1);zeros(7,1)-1];
    fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT,'KernelFunction','polynomial','BoxConstraint',0.01),Xt))));
    acc = zeros(1,size(X,2));
    
    for i = 1:size(X,2)
        ft = X(:,i);
%       Iterate through the partition objects test data and evaluate the
%       feature based on mean classification loss
        ftmdl = fitcsvm(ft,y,'KernelFunction','polynomial', 'KernelScale', 'auto','BoxConstraint',0.01);
        cvmdl = crossval(ftmdl, 'holdout', 0.3);
        acc(i) = 1 - kfoldLoss(cvmdl);
    end
    [val ind] = max(acc)
    cX = [acc;X];
    cX = sort(cX,2,'descend');
    cX = cX(2:end,:);
    
%   Perform sequential feature selection on data
    c = cvpartition(y,'HoldOut',5);
    maxdev = chi2inv(.95,1);     
    opt = statset('display','iter',...
                'TolFun',maxdev,...
                'TolTypeFun','abs');
    inmodel = sequentialfs(fn,X,y,'options',opt,'cv',c, 'direction', 'backward');
    
    sfsmdl = fitcsvm(X(:,inmodel),y,'KernelFunction','polynomial','BoxConstraint',0.01);
    cvsfsmdl = crossval(sfsmdl,'holdout', 0.3);
    sfs_acc = 1 - kfoldLoss(cvsfsmdl);
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
%     
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
%     saveas(gcf,strcat('Clip',int2str(clipno),'t-SNE.fig'));
%     close(gcf);
end