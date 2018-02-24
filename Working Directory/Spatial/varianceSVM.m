function varianceSVM(clipno)
    struc = load(strcat('ExpertClip',int2str(clipno),'Variance.mat'));
    expVar = struc.fixVar;
    struc = load(strcat('LayClip',int2str(clipno),'Variance.mat'));
    layVar = struc.fixVar;
    maxX = max([expVar(:,1);layVar(:,1)]);
    maxY = max([expVar(:,2);layVar(:,2)]);
    figure('units','normalized','outerposition',[0 0 maxX maxY]);
    scatter(expVar(:,1),expVar(:,2),'bx');
    hold on;
    scatter(layVar(:,1),layVar(:,2),'rx');
    X = [expVar(2:5,:);layVar(2:4,:)];
    Y = [1;1;1;1;-1;-1;-1];
    mdl = fitcsvm(X,Y);
    sv = mdl.SupportVectors;
    plot(sv(:,1),sv(:,2),'ko');
    legend('Expert','Lay','Support Vectors');
    saveas(gcf,strcat('VarianceSVM',int2str(clipno),'.jpg'));
    close(gcf);
    
    tX = [expVar(1,:);expVar(6:end,:);layVar(5:end,:)];
    tY = predict(mdl,tX);
    vY = [1;1;1;1;-1;-1;-1];
%   logically compare the labels assigned by the model with the correct
%   labels
    pT = tY == 1;
    pV = vY == 1;
    nT = tY == -1;
    nV = vY == -1;
    tp = sum(pT & pV);
    fp = sum(pT & ~pV);
    tn = sum(nT & nV);
    fn = sum(nT & ~nV);
    Positive = [tp; fp];
    Negative = [tn; fn];
    rn = {'True','False'};
    h = figure('units','normalized','outerposition',[0 0 1 1]);
    T = table(Positive, Negative, 'RowNames',rn);
    u = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    h.Units = 'pixels';
    h.Position = [0 1024 220 70]
    saveas(gcf,strcat('Clip', int2str(clipno), 'VarianceTest.jpg'));
    close(gcf);
    clear;
end