%   Sort features based on their individual classification accuracy
    y = [ones(8,1);zeros(7,1)-1];
    fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT),Xt))));
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
