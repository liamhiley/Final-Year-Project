function [acc] = pca_classification(clip,n)
%This function loads in a the scores of Principal Component Analysis and
%uses 15-fold leave-n-out cross-validation with SVM classification to
%assess the scores as a method of classification between Experts and Lays

%clip - the clip number that the user wants to evaluate
%n - what partition to use in leave-n-out cross validation

    load(strcat('ComponentDataClip',int2str(clip),'.mat'));
    if exist('full_score')
        lbls = [ones(8,1);ones(7,1)*-1];
        part = nchoosek([1:15],15-n);
        acc = zeros(size(part,1),1);
        i = 1;
        for T = part'
    %       using a 70:30 ratio for validation
            t = setdiff([1:15]',T);
            XT = score(T,:);
            yT = lbls(T);
            Xt = score(t,:);
            yt = lbls(t);
            acc(i) = sum(yt==svmclassify(svmtrain(XT,yT),Xt))/15;
            i = i + 1;
        end
    else
        lbls_1 = zeros(size(sc1,1),1);
        for i = lbls_1
            i
        end
        lbls_2 = zeros(size(sc2,1),1);
    end
    acc = mean(acc);
end

