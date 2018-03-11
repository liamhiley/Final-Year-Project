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
    
    
%   Combine expert and lay data
    X = [exp; lay];
%   Create mixture model for data, with 3 components, each of >0 length
    mixFail = true;
    while(mixFail)
        mixFail = false;
%       Create Gaussian Mixture Model
        ftMix = gmm(size(X,1),3,'diag');
%       Initialise model for feature data
        options = foptions;
        options(14) = 100;
        options(1) = -1;
        ftMix = gmminit(ftMix,X',options);
%       EM algorithm for 10 iterations to get best fit for data to components
        ftMix = gmmem(ftMix, X', options);
%       We now want to split the features into two groups based on which
%       component they belong to
%       Define vectors that store the index of each feature that belongs to
%       each component
        gauss1 = []; gauss2 = []; gauss3 = [];
        for sub = 1:size(X,2)
            post = gmmpost(ftMix, X(:,sub)');
            [val ind] = max(post');
            if ind == 1
                gauss1 = [gauss1 X(:,sub)];
            elseif ind == 2
                gauss2 = [gauss2 X(:,sub)];
            else
                gauss3 = [gauss3 X(:,sub)];
            end
        end
        if isempty(gauss1) || isempty(gauss2) || isempty(gauss3)
            mixFail = true;
        end
    end
    figure;
    [coeff, score, latent] = pca(X);
    norm_eig = 100*latent / sum(latent);
    
    title('PCA on complete data');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    hold on;
    plot(1:size(norm_eig,1),norm_eig,'kx');
    plot(1:size(norm_eig,1),norm_eig);
    
    figure;
    
    [coeff1, score1, latent,~,expl1] = pca(gauss1);
    norm_eig1 = expl1;
    [coeff2, score2, latent,~,expl2] = pca(gauss2);
    norm_eig2 = expl2;
    [coeff3, score3, latent,~,expl3] = pca(gauss3);
    norm_eig3 = expl3;
    
    subplot(3,1,1);
    hold on;
    title('Gaussian 1');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    plot(1:1:size(norm_eig1,1),norm_eig1,'rx');
    plot(1:size(norm_eig1,1),norm_eig1);
    subplot(3,1,2);
    hold on;
    title('Gaussian 2');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    plot(1:1:size(norm_eig2,1),norm_eig2,'bx');
    plot(1:size(norm_eig2,1),norm_eig2);
    subplot(3,1,3);
    hold on;
    title('Gaussian 3');
    xlabel('PC');
    ylabel('Percentage Eigenvalue');
    plot(1:1:size(norm_eig3,1),norm_eig3,'gx');
    plot(1:size(norm_eig3,1),norm_eig3);
    
    disp('PCA complete, Percentage eigenvalues for component 1 are:')
    norm_eig1'
    disp('for component 2:')
    norm_eig2'
    disp('for component 3:')
    norm_eig3'

%   Find the components from each Gaussian that cause the most (more than 75%) variability
    comp = 1;
    v = 75;
    while v > 0
        v = v - expl1(comp);
        comp = comp + 1;
    end
    score1 = score1(:,1:comp);
    
    comp = 1;
    v = 75;
    while v > 0
        v = v - expl2(comp);
        comp = comp + 1;
    end
    score2 = score2(:,1:comp);
    
    comp = 1;
    v = 75;
    while v > 0
        v = v - expl3(comp);
        comp = comp + 1;
    end
    score3 = score3(:,1:comp);
%   Combine components from each Gaussian
    compX = [score1 score2 score3];
    

%   Perform sequential feature selection on components
        
%     Y = [ones(8,1);zeros(7,1)-1];
%     fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT),Xt))));
%     maxdev = chi2inv(.95,1);     
%     opt = statset('display','iter',...
%                 'TolFun',maxdev,...
%                 'TolTypeFun','abs');
%     inmdl = sequentialfs(fn, X, Y,'cv',c, 'options', opt);

%   Use tsne for visualisation of data in two-dimensional
    group = {'expert';'expert';'expert';'expert';'expert';...
        'expert';'expert';'expert';'lay';'lay';'lay';'lay';...
        'lay';'lay';'lay',};
%   compare all distance measures
    cosX = tsne(X,'Distance','cosine','NumDimensions',3);
    eucX = tsne(X,'Distance','euclidean','NumDimensions',3);
    chebX = tsne(X,'Distance','chebychev','NumDimensions',3);
    
    v = double(categorical(group));
    c = full(sparse(1:numel(v),v,ones(size(v)),numel(v),3))
    
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
    
    
end