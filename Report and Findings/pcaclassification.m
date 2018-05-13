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
