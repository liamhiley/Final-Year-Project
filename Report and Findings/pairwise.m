  for i = 1:n_ft
        for j = 1:n_ft
%          Define accuracy as the percentage of test observations misclassified
           mdl = fitcsvm([X(:,i) X(:,j)],y,'KernelFunction','polynomial', 'KernelScale', 'auto','BoxConstraint',0.01);
           cvmdl = crossval(mdl,'holdout',0.3);
           acc(i,j) = 1 - kfoldLoss(cvmdl);
        end
    end
