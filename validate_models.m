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


f_meanfield = figure('Renderer', 'painters', 'Position', [0 0 480, 960]);
tiledlayout(10,5,'TileSpacing', 'compact', 'Padding', 'compact');

for ss = 1:length(stateNames)
    
    nexttile; hold on;
    xline(.5, '--k', 'LineWidth', 1);
      
    % plot 538
    [f,x]=ksdensity(tbl538.(stateNames{ss}), 'Kernel', 'epanechnikov');
    plot(x,f, '-k', 'LineWidth', 2);
    
    % plot economist
    [f,x]=ksdensity(tblEcon.(stateNames{ss}), 'Kernel', 'epanechnikov');
    plot(x,f, '-r', 'LineWidth', 2);
    
    title(stateNames{ss});
    ylim([0, 20]);
    yticks([]);
    set(gca, 'TickDir', 'out', 'LineWidth', 1);
    
end


saveas(f_meanfield, './figures/meanfield.png') 



%% plot correlation matrix

f_corr = figure('Renderer', 'painters', 'Position', [0 0 500 400])
colormap(batlow);

tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
c538 = corr(tbl538.Variables);
imagesc(c538, [-1 1]); colorbar('Ticks', [-1,0,1]);
title('538 state correlation')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])


nexttile;
cEcon = corr(tblEcon.Variables);
imagesc(cEcon, [-1 1]);
title('Economist state correlation')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])



% nexttile([2, 2]); hold on;
% 
% t538 = c538(logical(tril(ones(50),-1)));
% tEcon = cEcon(logical(tril(ones(50),-1)));
% 
% histogram(t538, 30, 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineWidth', 2)
% histogram(tEcon, 30, 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 2)
% yticks([])
% xlim([-1 1])
% xlabel('between-state correlation')
% title('Comparing state correlation')
% set(gca, 'TickDir', 'out', 'LineWidth', 1)




nexttile; hold on;

t538 = c538(logical(tril(ones(50),-1)));
tEcon = cEcon(logical(tril(ones(50),-1)));

histogram(t538, 30, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineWidth', 2)
histogram(tEcon, 30,'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 2)
yticks([])
xlim([-1 1])
xlabel('between-state correlation')
title('state correlation distribution')
set(gca, 'TickDir', 'out', 'LineWidth', 1)


nexttile; hold on;

t538 = c538(logical(tril(ones(50),-1)));
tEcon = cEcon(logical(tril(ones(50),-1)));

plot(t538, tEcon, '.b', 'LineWidth', 1)
plot([-.5 1], [-.5 1], '-b', 'LineWidth', 1)
xlabel('538')
ylabel('Economist')

title('state correlation contrast')
set(gca, 'TickDir', 'out', 'LineWidth', 1)








saveas(f_corr, './figures/corrplots.png') 



%% plot multivariate


compareStates = {'CT', 'ME', 'MA', 'NH', 'RI', 'VT'};
nComp = length(compareStates);

f_538 = figure('Renderer', 'painters', 'Position', [0 0 350 350]);

[S_538,AX_538,BigAx_538,H_538,HAx_538] = plotmatrix(tbl538{datasample(1:nsims, 1e4),compareStates}, '.k');
for ii = 1:nComp; H_538(ii).DisplayStyle = 'stairs';end
for ii = 1:nComp; H_538(ii).EdgeColor = 'k';end
for ii = 1:nComp; H_538(ii).LineWidth = 1;end
for ii = 1:nComp; set(get(AX_538(1,ii),'Title'),'String',compareStates{ii});end
for ii = 1:(nComp^2); AX_538(ii).XTickLabel = [];end
for ii = 1:(nComp^2); AX_538(ii).YTickLabel = [];end

f_Econ = figure('Renderer', 'painters', 'Position', [0 0 350 350]);

[S_Econ,AX_Econ,BigAx_Econ,H_Econ,HAx_Econ] = plotmatrix(tblEcon{datasample(1:nsims, 1e4),compareStates}, '.r');
for ii = 1:nComp; H_Econ(ii).DisplayStyle = 'stairs';end
for ii = 1:nComp; H_Econ(ii).EdgeColor = 'r';end
for ii = 1:nComp; H_Econ(ii).LineWidth = 1;end
for ii = 1:nComp; set(get(AX_Econ(1,ii),'Title'),'String',compareStates{ii});end
for ii = 1:nComp; HAx_Econ(ii).XLim = HAx_538(ii).XLim;end
for ii = 1:nComp; HAx_Econ(ii).YLim = HAx_538(ii).YLim;end
for ii = 1:(nComp^2); AX_Econ(ii).XLim = AX_538(ii).XLim;end
for ii = 1:(nComp^2); AX_Econ(ii).YLim = AX_538(ii).YLim;end
for ii = 1:(nComp^2); AX_Econ(ii).XTickLabel = [];end
for ii = 1:(nComp^2); AX_Econ(ii).YTickLabel = [];end


saveas(f_538, './figures/compareMulti_538.png') 
saveas(f_Econ, './figures/compareMulti_Econ.png') 



%% compare model likelihoods


b_538 = min(std(tbl538{1:39000,:}), iqr(tbl538{1:39000,:})/1.34).*(4/(52*nsims)).^(1/54);
b_Econ = min(std(tblEcon{1:39000,:}), iqr(tblEcon{1:39000,:})/1.34).*(4/(52*nsims)).^(1/54);

lik_538_538     = mvksdensity(tbl538{1:39000,:}, tbl538{39001:end,:}, 'bandwidth', b_538, 'Kernel', 'epanechnikov');
lik_538_Econ    = mvksdensity(tbl538{1:39000,:}, tblEcon{39001:end,:}, 'bandwidth', b_538, 'Kernel', 'epanechnikov');
lik_Econ_Econ   = mvksdensity(tblEcon{1:39000,:}, tblEcon{39001:end,:}, 'bandwidth', b_Econ, 'Kernel', 'epanechnikov');
lik_Econ_538    = mvksdensity(tblEcon{1:39000,:}, tbl538{39001:end,:}, 'bandwidth', b_Econ, 'Kernel', 'epanechnikov');



f_modelRec = figure('Renderer', 'painters', 'Position', [0 0 400 500]); hold on;
tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');



nexttile; hold on;
histogram(log(1+lik_538_538), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 2)
histogram(log(1+lik_538_Econ), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '--', 'LineWidth', 2)
histogram(log(1+lik_Econ_Econ), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 2)
histogram(log(1+lik_Econ_538), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 2)

legend({'P(538 | 538)', 'P(538 | Economist)', 'P(Economist | Economist)', 'P(Economist | 538)'}, 'Location', 'northwest')
xticks([])
yticks([])
title('model recovery')
xlabel('model loglik')
ylabel('density')
set(gca, 'TickDir', 'out', 'LineWidth', 1)



nexttile; hold on;

clear simDiff_538 simDiff_Econ 
for ii = 1:1000
    simDiff_538(ii) = nanmean(datasample(log(1+lik_538_538), 1000) - datasample(log(1+lik_Econ_538), 1000));
    simDiff_Econ(ii) = nanmean(datasample(log(1+lik_Econ_Econ), 1000) - datasample(log(1+lik_538_Econ), 1000));
end

histogram(simDiff_538, 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 2)
histogram(simDiff_Econ, 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 2)

xline(0, '--k')
legend({'(correct | 538)', '(correct | Economist)'}, 'Location', 'northeast')
yticks([])
ylabel('density')
title('model selection')
xlabel('loglik difference')
set(gca, 'TickDir', 'out', 'LineWidth', 1)


saveas(f_modelRec, './figures/modelRecovery.png') 




