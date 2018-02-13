O = 3; %3 possible observations
Q = 2; %2 possible states

%true parameters
prior0 = normalise(rand(Q,1)); %?
transmat0 = mk_stochastic(rand(Q,Q)); %transition matrix A
obsmat0 = mk_stochastic(rand(Q,O)); %observation matrix
%define 20 sequences of length 10
nex = 20;
T = 10;
data = dhmm_sample(prior0,transmat0, obsmat0, nex, T)

%data is 20x10
%guess at true parameters
prior1 = normalise(rand(Q,1));
transmat1 = mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));

%improve guess using 5 iterations of EM
[LL,prior2,transmat2,obsmat2,] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', 5);


%given test data, compute loglikelihood of trained model producing said
%data (i.e. higher numbers (closer to 0) mean the estimated HMM is closer
%to the original, since estimated HMM is more likely to produce the
%observation sequence we know has come from the original model)
loglik = dhmm_logprob(data,prior2,transmat2,obsmat2)



