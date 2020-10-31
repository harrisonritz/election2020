%% compare models


%% load data


% == load 538
raw = fread(fopen('./model-predictions/origSims_538.json'));
str = char(raw');
val = jsondecode(str);
pred = 1-(1+val.maps(:,4:end)/100)/2;

tbl538 = array2table(pred, 'VariableNames', val.states);


% == load economist
tblEcon = readtable('./model-predictions/origSim_econ.csv');


% == select data from both
stateNames = setxor(intersect(tblEcon.Properties.VariableNames, tbl538.Properties.VariableNames), 'DC');

tbl538  = tbl538(:, stateNames);
tblEcon = tblEcon(:, stateNames);


%% plot mean field


figure('Renderer', 'painters', 'Position', [0 0 1024 640])
tiledlayout(5,10,'TileSpacing', 'compact', 'Padding', 'compact');

for ss = 1:length(stateNames)
    
    nexttile; hold on;
    xline(.5, '--k', 'LineWidth', 1);
      
    % plot 538
    [f,x]=ksdensity(tbl538.(stateNames{ss}));
    plot(x,f, '-k', 'LineWidth', 2);
    
    % plot economist
    [f,x]=ksdensity(tblEcon.(stateNames{ss}));
    plot(x,f, '-r', 'LineWidth', 2);
    
    title(stateNames{ss});
    ylim([0, 20]);
    set(gca, 'TickDir', 'out', 'LineWidth', 1);
    
end




%% plot correlation matrix

figure('Renderer', 'painters', 'Position', [0 0 800 300])

nexttile;
imagesc(corr(tbl538.Variables), [-1 1]);
title('538 state corr')

nexttile;
imagesc(corr(tblEcon.Variables), [-1 1])
title('Econ state corr')



%% plot multivariate


triState = {'NY', 'NJ', 'CT', 'PA'};

figure('Renderer', 'painters', 'Position', [0 0 1024 640])
[S_538,AX_538,BigAx_538,H_538,HAx_538] = plotmatrix(tbl538{randsample(4e4, 1e3),triState}, '.k');
for ii = 1:4; H_538(ii).DisplayStyle = 'stairs';end
for ii = 1:4; H_538(ii).EdgeColor = 'k';end
for ii = 1:4; H_538(ii).LineWidth = 1;end
for ii = 1:4; set(get(AX_538(1,ii),'Title'),'String',triState{ii});end


figure('Renderer', 'painters', 'Position', [0 0 1024 640])
[S_Econ,AX_Econ,BigAx_Econ,H_Econ,HAx_Econ] = plotmatrix(tblEcon{randsample(4e4, 1e3),triState}, '.r');
for ii = 1:4; H_Econ(ii).DisplayStyle = 'stairs';end
for ii = 1:4; H_Econ(ii).EdgeColor = 'r';end
for ii = 1:4; H_Econ(ii).LineWidth = 1;end
for ii = 1:4; set(get(AX_Econ(1,ii),'Title'),'String',triState{ii});end
for ii = 1:4; HAx_Econ(ii).XLim = HAx_538(ii).XLim;end
for ii = 1:16; AX_Econ(ii).XLim = AX_538(ii).XLim;end
for ii = 1:16; AX_Econ(ii).YLim = AX_538(ii).YLim;end




