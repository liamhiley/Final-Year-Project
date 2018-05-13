%.    this function calculates the total misclassified observations from the test data by a model trained on the training data
        fn = @(XT, yT, Xt, yt)(sum(yt~=(predict(fitcsvm(XT, yT),Xt))));

%     Perform sequential forward selection on data
        c = cvpartition(y,'HoldOut',5);
        maxdev = chi2inv(.95,1);
        opt = statset('display','iter',...
                'TolFun',maxdev,...
                'TolTypeFun','abs');
        inmodel = sequentialfs(fn,cX,y,'options',opt,'cv',c);
