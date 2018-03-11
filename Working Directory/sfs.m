function [inmodel] = sfs(X,Y)
%     This function takes a n-by-p data matrix, X, and n length label column
%     vector Y and performs exhaustive k-fold cross validation.
%     Inmodel is a binary row vector of length p, with value of
%     one in column i corresponding to variable i being selected, and 0
%     otherwise
%     X - n-by-p matrix, i.e. n observations, and p variables.
%     Y - vector of length n, of values 1 or -1 classifying the
%     corresponding row in X as one of two classes

%     Loop through sequential feature selection, starting with n features,
%     removing each, to find the best 
      for l_o = 1:size(X,2)-1
        for l_o_ftr = 1:l_o:size(X,2)
            for 
        end
      end
end
