ncentres = 2;
%create mixture model, covariance set to full
mix = gmm(2,ncentres, 'diag');

%estimate the covariance of the gmm
%guess at  mix parameters (these are gathered from previous k means clustering) 
%mix.centres = [480 400; 480 100; 530 220];

%set options struct to use for displaying error at each cycle later
options = foptions; 
options(14) = 1; % A single iteration
options(1) = -1; % Switch off all messages, including warning

mix = gmminit(mix,X,options);
for i = 1:6
    switch clipno
        case 1
            mix.ncentres = 7;
        case 2
            mix.ncentres = 9;
        case 3
            mix.ncentres = 8;
        case 4
            mix.ncentres = 7;
        case 5
            mix.ncentres = 8;
        case 6
            mix.ncentres = 4;
    end
    GazeGMM(mix, i);
    if i == 1
        k = input('Press y to keep model, n to renew\n');
        pause;
    end
    if k == 'n'
        i = 1;
    end    
end