        while(true)
            prinMix = gmm(num_dim,2,'diag');
            options = foptions;
            prinMix = gmminit(prinMix, full_score, options);
            prinMix = gmmem(prinMix, full_score,options);
            post = gmmpost(prinMix,full_score);
            [val, ind] = max(post');
%           keep record of what subjects are in either Gaussian
            subjects_in_1 = []; subjects_in_2 = [];
            sc1 = []; sc2 = [];
            for j = 1:15
                if ind(j) == 1
                    sc1 = [sc1;full_score(j,:)];
                    subjects_in_1 = [subjects_in_1; j];
                else
                    sc2 = [sc2; full_score(j,:)];
                    subjects_in_2 = [subjects_in_2; j];
                end
            end
            if min(size(sc1,1),size(sc2,1)) >= 5
                break;
            end
        end
%       Find the explained variability of the principal components in each
%       Gaussian
        cov1 = cov(sc1); cov2 = cov(sc2);
        eig1 = sort(eig(cov1),'descend'); eig2 = sort(eig(cov2),'descend');
        [sc1, energ1] = filter_components(sc1,eig1,60);
        [sc2, energ2] = filter_components(sc2,eig2,60);
