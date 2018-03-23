function [] = NewExpert(clipno)
%   Uses a pre-trained GMM for Experts to generate exp to simulate an
%   Expert watching the video specified by clipno. This randomly samples
%   from each of the components of the model to create a convincing
%   sequence.
%   This should not be used on Video Clips as it does not account for the
%   common behaviour of following dynamic objects that is characteristic of
%   a human
    
%   define path to project folder
    homepath = '/Users/liam/Projects/Final-Year-Project';
%   Load in GMM
    load(strcat('Expert Networks/expert',int2str(clipno),'.net'),'mix','-mat');
%   Each video is approx. 15 seconds long at framerate of 50.2281fps
    numFrames = ceil(50.2281*15);
%   Generate around 15 Saccades for the video at lengths varying from
%   100 to 900 milliseconds = 5 to 45 frames
    numSacc = randi([13 17]);
    exp = zeros(numFrames,2);
    step = floor(numFrames/numSacc);
    for frame = 1:step:numFrames
        c = randi(mix.ncentres);
        comp = [mix.centres(c,:); mix.covars(c,:)];
        len = randi([100 900]);
        for saccFrame = frame:frame+step-1
%           Sample random point in the ellipse
            theta = 0:0.02:2*pi;
            X= sqrt(comp(2,1))*cos(theta) + comp(1,1);
            Y = sqrt(comp(2,2))*sin(theta) + comp(1,2);
            h = range(Y); w = range(X);
            x = sqrt(rand)*cos(rand*2*pi);
            y = sqrt(rand)*sin(rand*2*pi);
            x = x * w + comp(1,1);
            y = y * h + comp(1,2);
            exp(saccFrame,:) = [x y];
        end
    end
    save('NewExpert.mat','exp');
end