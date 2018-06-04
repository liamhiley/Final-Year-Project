function [score,perc_var] = filter_components(score, latent, cutoff)
%This function takes the scores and variances from a principal component
%analysis and filters out the top n principal components, such that these n
%components account for more than cutoff percent of the variance in the
%model
%score - the scores of a pca
%latent - the variances of each principal component from pca
%cutoff - the percentage variance after which all principal components are
%discarded

    perc_var = 100 * latent / sum(latent);
    energ = 0;
    num_c = 1;
    while energ < cutoff
        energ = energ + perc_var(num_c);
        num_c = num_c + 1;
    end
    score = score(:,1:num_c);
end

