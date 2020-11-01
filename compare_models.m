%% compare models

addpath(genpath(pwd))
batlow = load('batlow.txt');

%% load data


% == load 538
raw = fread(fopen('./models/origSims_538.json'));
str = char(raw');
val = jsondecode(str);
pred = 1-(1+val.maps(:,4:end)/100)/2;

tbl538 = array2table(pred, 'VariableNames', val.states);


% == load economist
tblEcon = readtable('./models/origSim_econ.csv');


% == select data from both
stateNames = setxor(intersect(tblEcon.Properties.VariableNames, tbl538.Properties.VariableNames), 'DC');
nsims = size(tbl538,1);

tbl538  = tbl538(:, stateNames);
tblEcon = tblEcon(:, stateNames);



%% plot mean field


f_meanfield = figure('Renderer', 'painters', 'Position', [0 0 1024 512]);
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
    yticks([]);
    set(gca, 'TickDir', 'out', 'LineWidth', 1);
    
end


saveas(f_meanfield, './figures/meanfield.png') 



%% plot correlation matrix

f_corr = figure('Renderer', 'painters', 'Position', [0 0 400 200])
colormap(batlow);

tiledlayout(1,2,'TileSpacing', 'compact', 'Padding', 'compact');

nexttile(1);
imagesc(corr(tbl538.Variables), [-1 1]);
title('538 state correlation')
yticks([])
xticks([])



nexttile(2);
imagesc(corr(tblEcon.Variables), [-1 1])
title('Econ state correlation')
yticks([])
xticks([])







saveas(f_corr, './figures/corrplots.png') 



%% plot multivariate


triState = {'NY', 'NJ', 'CT', 'PA'};

f_538 = figure('Renderer', 'painters', 'Position', [0 0 600 600]);

[S_538,AX_538,BigAx_538,H_538,HAx_538] = plotmatrix(tbl538{datasample(1:nsims, 1e4),triState}, '.k');
for ii = 1:4; H_538(ii).DisplayStyle = 'stairs';end
for ii = 1:4; H_538(ii).EdgeColor = 'k';end
for ii = 1:4; H_538(ii).LineWidth = 1;end
for ii = 1:4; set(get(AX_538(1,ii),'Title'),'String',triState{ii});end


f_Econ = figure('Renderer', 'painters', 'Position', [0 0 600 600]);

[S_Econ,AX_Econ,BigAx_Econ,H_Econ,HAx_Econ] = plotmatrix(tblEcon{datasample(1:nsims, 1e4),triState}, '.r');
for ii = 1:4; H_Econ(ii).DisplayStyle = 'stairs';end
for ii = 1:4; H_Econ(ii).EdgeColor = 'r';end
for ii = 1:4; H_Econ(ii).LineWidth = 1;end
for ii = 1:4; set(get(AX_Econ(1,ii),'Title'),'String',triState{ii});end
for ii = 1:4; HAx_Econ(ii).XLim = HAx_538(ii).XLim;end
for ii = 1:16; AX_Econ(ii).XLim = AX_538(ii).XLim;end
for ii = 1:16; AX_Econ(ii).YLim = AX_538(ii).YLim;end


saveas(f_538, './figures/tristate_538.png') 
saveas(f_Econ, './figures/tristate_Econ.png') 



