function [acc] = pca_classification(clip,n)
%This function loads in a the scores of Principal Component Analysis and
%uses 15-fold leave-n-out cross-validation with SVM classification to
%assess the scores as a method of classification between Experts and Lays

%clip - the clip number that the user wants to evaluate
%n - what partition to use in leave-n-out cross validation

    load(strcat('ComponentDataClip',int2str(clip),'.mat'));
%   if the principal components were biased enough for the first 3 to
%   account for enough of the variance, then there is only one set of
%   scores to classify
    if exist('full_score','var')
%       in this case the order of subjects would be preserved
        lbls = [ones(8,1);ones(7,1)*-1];
%       get all possible combinations for training data that include two
%       separate groups
        part = nchoosek(1:15,15-n);
        bad_pt = zeros(size(part,1),1);
        for i = 1:size(part,1)
            if sum(lbls(part(i,:)') == 1) == 0 || sum(lbls(part(i,:)') == -1) == 0
                bad_pt(i) = 1;
            end
        end
        part(bad_pt==1,:) = [];
        acc = zeros(size(part,1),1);
        i = 1;
        for T = part'
%           get the complimenting test data
            t = setdiff([1:15]',T);
            XT = full_score(T,:);
            yT = lbls(T);
            Xt = full_score(t,:);
            yt = lbls(t);
            acc(i) = sum(yt==svmclassify(svmtrain(XT,yT),Xt))/size(yt,1);
            i = i + 1;
        end
        acc = mean(acc);
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
%       we do not want a training partition of less than 0
        if n >= sz1
            m = max(sz1 - 1,0);
        else
            m = n;
        end
        part = nchoosek(1:sz1,sz1-m);
        bad_pt = zeros(size(part,1),1);
        for i = 1:size(part,1)
            if sum(lbls1(part(i,:)') == 1) == 0 || sum(lbls1(part(i,:)') == -1) == 0
                bad_pt(i) = 1;
            end
        end
        part(bad_pt==1,:) = [];
%       calculate the accuracies separately
        acc1 = zeros(size(part,1),1);
        i = 1;
        for T = part'
            t = setdiff(1:sz1,T);
            XT = sc1(T,:);
            yT = lbls1(T);
            Xt = sc1(t,:);
            yt = lbls1(t);
            acc1(i) = sum(yt==svmclassify(svmtrain(XT,yT),Xt))/size(yt,1);
            i = i + 1;
        end
        
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
        if n >= sz2
            m = max(sz2 - 1,0);
        else
            m = n;
        end
        part = nchoosek(1:sz2,sz2-m);
        bad_pt = zeros(size(part,1),1);
        for i = 1:size(part,1)
            if sum(lbls2(part(i,:)') == 1) == 0 || sum(lbls2(part(i,:)') == -1) == 0
                bad_pt(i) = 1;
            end
        end
        part(bad_pt==1,:) = [];
%       calculate the accuracies separately
        acc2 = zeros(size(part,1),1);
        i = 1;
        for T = part'
            t = setdiff(1:sz2,T);
            XT = sc2(T,:);
            yT = lbls2(T);
            Xt = sc2(t,:);
            yt = lbls2(t);
            acc2(i) = sum(yt==svmclassify(svmtrain(XT,yT),Xt))/size(yt,1);
            i = i + 1;
        end
        acc = mean([mean(acc1),mean(acc2)]);
    end
end

