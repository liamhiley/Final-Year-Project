function [inmodel] = sfs(fn,X,y,ob_func)
%     This function takes a n-by-p data matrix, X, and n length label column
%     vector Y and performs exhaustive feature selection on all
%     combinations of columns p. Selecting features based on whether they
%     improve the classification of X to Y
%     Inmodel is a binary row vector of length p, with value of
%     one in column i corresponding to variable i being selected, and 0
%     otherwise

%     X - n-by-p matrix, i.e. n observations, and p variables.
%     Y - vector of length n, of values 1 or -1 classifying the
%     corresponding row in X as one of two classes

%   initialise inmodel
    inmodel = zeros(1,size(X,2));
    set = [];
    idx = 1;
    crit = 1;
    
    if ~exist('ob_func','var')
        ob_func = 'wrapper';
    end
    
%   The following executes if the user selected wrapper objective functions
    if strcmp(ob_func, 'wrapper')
%       Define cross validation object
        c = cvpartition(y,'HoldOut',5);
%       Iterate through the partition objects test data and evaluate the
%       feature based on it's contribution to the classification loss
        for i = 1:size(X,2)
            ft = X(:,i);
            set = [set ft];
            
            err = zeros(c.NumTestSets,1);
            for j = 1:c.NumTestSets
                trIdx = c.training(j);
                tesIdx = c.test(j);
                XT = set(trIdx);
                Xt = set(tesIdx);
                yT = y(trIdx);
                yt = y(tesIdx);
                err(j) = (fn(XT,yT,Xt,yt))/sum(tesIdx);
            end
            mnErr = sum(err)/size(err,1);
            if mnErr < crit
                s = ['Adding column ', int2str(i),'.'];
                disp(s);
                s = ['Mean classification error ', num2str(mnErr)];
                disp(s);
                inmodel(i) = 1;
                crit = mnErr;
            else
                set = set(:,1:end-1);
            end
        end
        features = 1:75;
        features = features(inmodel==1);
        disp('Final features selected: ');
        disp(features);
    elseif strcmp(ob_func,'filter')
        
    
    else
        disp('Please select either "wrapper" or "filter" as the objective function')
    end
end
