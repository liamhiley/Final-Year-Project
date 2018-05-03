        if ~exist('mix','var');
%         create mixture model, covariance set to full
            mix = gmm(2,num_centres, 'diag');

%         set options struct to use for dispExperting error at each cycle later
            mix = gmminit(mix,X,options);
        end

%     iterate through EM algorithm to improve fit to data points
        for i = 1:2000
            [mix, options] = gmmem(mix, X, options);
        end

        if num_centres ~= 1
            if options(8) - err > 1
                return;
            end
        end
