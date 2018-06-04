function [acc,orig_acc] = pca_classification(clip,kf,bc,po)
%This function loads in  the scores of Principal Component Analysis,fits
%an SVM model to data, and returns it's estimated accuracy for two class
%classification

%clip - the clip number that the user wants to evaluate
    
%   specify rng for reproducibility
    rng default;

    load(strcat('ComponentDataClip',int2str(clip),'.mat'));
    
    if ~exist('po','var')
        po = 3;
    end
%   if the principal components were biased enough for the first 3 to
%   account for enough of the variance, then there is only one set of
%   scores to classify
    if exist('full_score','var')
        
%       in this case the order of subjects would be preserved
        lbls = [ones(8,1);ones(7,1)*-1];
        
%       pad out the data with 92 more "new" observations each
        exp = full_score(1:8,:); lay = full_score(9:end,:);
        new_exp = zeros(92,size(full_score,2));
        new_lay = zeros(92,size(full_score,2));
        
        for i = 1:92
%           choose a random expert and lay observation and generate a point
%           near to them
            new_exp(i,:) = mvnrnd(exp(randi(8),:),eye(size(full_score,2)));
            new_lay(i,:) = mvnrnd(lay(randi(7),:),eye(size(full_score,2)));
        end
        
%       train the svm model
        svmmdl = fitcsvm(full_score, lbls,'KernelFunction','polynomial', 'KernelScale', 'auto','BoxConstraint',0.01);
%       cross-validate the model
        cvmdl = crossval(svmmdl);
%       obtain the estimated accuracy
        acc = 1 -  kfoldLoss(cvmdl);
%   otherwise the score data is fitted into two gaussians to be classified
%   separately
    else
        sz1 = size(sc1,1); sz2 = size(sc2,1);
%       if the data is split between two gaussians, the labels must be
%       calculated
        lbls1 = zeros(sz1,1);
        for i = 1:size(lbls1,1)
            if subjects_in_1(i) < 9
                lbls1(i) = 1;
            else
                lbls1(i) = -1;
            end
        end
        
%       pad out the data to 100 observations by interpolating
        new_sc1 = zeros(100-sz1,size(sc1,2));
        new_lbls1 = zeros(100-sz1,1);
        for i = 1:100-sz1
%           choose a random expert and lay observation and generate a point
%           near to them
            subject = randi(sz1);
            new_lbls1(i) = lbls1(subject);
            new_sc1(i,:) = mvnrnd(sc1(subject,:),eye(size(sc1,2)));
        end
        
        orig_sc1 = sc1;
        orig_lbls1 = lbls1;
        
        sc1 = [sc1;new_sc1];
        lbls1 = [lbls1; new_lbls1];
%       train the svm model
        if strcmp(kf,'polynomial')
            svmmdl1 = fitcsvm(sc1, lbls1,'KernelFunction',kf,'BoxConstraint',bc,'PolynomialOrder',po);
        else
            svmmdl1 = fitcsvm(sc1, lbls1,'KernelFunction',kf,'BoxConstraint',bc);
        end
%       cross-validate the model
        cvmdl1 = crossval(svmmdl1,'KFold',sz1-1);
%       obtain the estimated accuracy
        acc1 = 1 -  kfoldLoss(cvmdl1);
        orig_acc1 = sum(orig_lbls1==predict(svmmdl1,orig_sc1))/sz1;
        
%       for the second gaussian
        sz2 = size(sc2,1);
        lbls2 = zeros(sz2,1);
        for i = 1:sz2
            if subjects_in_2(i) < 9
                lbls2(i) = 1;
            else
                lbls2(i) = -1;
            end
        end
        
        %       pad out the data to 100 observations by interpolating
        new_sc2 = zeros(100-sz2,size(sc2,2));
        new_lbls2 = zeros(100-sz2,1);
        for i = 1:100-sz2
%           choose a random expert and lay observation and generate a point
%           near to them
            subject = randi(sz2);
            new_lbls2(i) = lbls2(subject);
            new_sc2(i,:) = mvnrnd(sc2(subject,:),eye(size(sc2,2)));
        end
        
        orig_sc2 = sc2;
        orig_lbls2 = lbls2;
        
        sc2 = [sc2;new_sc2];
        lbls2 = [lbls2; new_lbls2];
        
%       train the svm model
        if strcmp(kf,'polynomial')
            svmmdl2 = fitcsvm(sc2, lbls2,'KernelFunction',kf,'BoxConstraint',bc,'PolynomialOrder',po);
        else
            svmmdl2 = fitcsvm(sc2, lbls2,'KernelFunction',kf,'BoxConstraint',bc);
        end
%       cross-validate the model
        cvmdl2 = crossval(svmmdl2,'KFold',sz2-1);
%       obtain the estimated accuracy
        acc2 = 1 -  kfoldLoss(cvmdl2);
        orig_acc2 = sum(orig_lbls2==predict(svmmdl2,orig_sc2))/sz2;
        
        acc = mean([mean(acc1),mean(acc2)]);
        orig_acc = mean([orig_acc1, orig_acc2]);
    end
end