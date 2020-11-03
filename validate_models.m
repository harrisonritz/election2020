%% compare models

addpath(genpath(pwd))
batlow = load('batlow.txt');

%% load data


% == load 538
raw = fread(fopen('./models/sims_538.json'));
str = char(raw');
val = jsondecode(str);
pred = 1-(1+val.maps(:,4:end)/100)/2;

tbl538 = array2table(pred, 'VariableNames', val.states);
fprintf('\n538 loaded\n')


% == load economist
tblEcon = readtable('./models/sims_econ.csv');
fprintf('Econ loaded\n')

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

f_corr = figure('Renderer', 'painters', 'Position', [0 0 500 400]);
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

[S_538,AX_538,BigAx_538,H_538,HAx_538] = plotmatrix(tbl538{:,compareStates}, '.k');
for ii = 1:nComp; H_538(ii).DisplayStyle = 'stairs';end
for ii = 1:nComp; H_538(ii).EdgeColor = 'k';end
for ii = 1:nComp; H_538(ii).LineWidth = 1;end
for ii = 1:nComp; set(get(AX_538(1,ii),'Title'),'String',compareStates{ii});end
for ii = 1:(nComp^2); AX_538(ii).XTickLabel = [];end
for ii = 1:(nComp^2); AX_538(ii).YTickLabel = [];end

f_Econ = figure('Renderer', 'painters', 'Position', [0 0 350 350]);

[S_Econ,AX_Econ,BigAx_Econ,H_Econ,HAx_Econ] = plotmatrix(tblEcon{:,compareStates}, '.r');
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

% popWt = readmatrix('./models/pop_weights.csv');


d_538   = log(tbl538.Variables) - log(1-tbl538.Variables);
d_Econ  = log(tblEcon.Variables) - log(1-tblEcon.Variables);


b_538 = min(std(d_538(1:36000,:)), iqr(d_538(1:36000,:))/1.34).*(4/(52*nsims)).^(1/54);
b_Econ = min(std(d_Econ(1:36000,:)), iqr(d_Econ(1:36000,:))/1.34).*(4/(52*nsims)).^(1/54);

lik_538_538     = mvksdensity(d_538(1:36000,:), d_538(36001:end,:), 'bandwidth', b_538, 'Kernel', 'epanechnikov');
lik_538_Econ    = mvksdensity(d_538(1:36000,:), d_Econ(36001:end,:), 'bandwidth', b_538, 'Kernel', 'epanechnikov');
lik_Econ_Econ   = mvksdensity(d_Econ(1:36000,:), d_Econ(36001:end,:), 'bandwidth', b_Econ, 'Kernel', 'epanechnikov');
lik_Econ_538    = mvksdensity(d_Econ(1:36000,:), d_538(36001:end,:), 'bandwidth', b_Econ, 'Kernel', 'epanechnikov');

lik_538_538(lik_538_538<eps) = eps;
lik_538_Econ(lik_538_Econ<eps) = eps;
lik_Econ_Econ(lik_Econ_Econ<eps) = eps;
lik_Econ_538(lik_Econ_538<eps) = eps;


% Make figure
f_modelRec = figure('Renderer', 'painters', 'Position', [0 0 400 500]); hold on;
tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');


nexttile; hold on;
histogram(log(lik_538_538), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 2)
histogram(log(lik_538_Econ), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '--', 'LineWidth', 2)
histogram(log(lik_Econ_Econ), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 2)
histogram(log(lik_Econ_538), 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 2)

legend({'P(538 | 538)', 'P(538 | Economist)', 'P(Economist | Economist)', 'P(Economist | 538)'}, 'Location', 'northwest')
xticks([])
yticks([])
title('model recovery')
xlabel('model loglik')
ylabel('density')
set(gca, 'TickDir', 'out', 'LineWidth', 1)


% === compare fits
nexttile; hold on;
simDiff_538 = log(lik_538_538) - log(lik_Econ_538);
simDiff_Econ = log(lik_Econ_Econ) - log(lik_538_Econ);

prob_simDiff_538 = mean(simDiff_538 > 0)
simDiff_Econ = mean(simDiff_Econ > 0)


histogram(simDiff_538, 'Normalization', 'pdf',  'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 2)
histogram(simDiff_Econ, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 2)

xline(0, '--k')
legend({'(correct | 538)', '(correct | Economist)'}, 'Location', 'northwest')
yticks([])
ylabel('density')
title('model selection')
xlabel('loglik difference')
set(gca, 'TickDir', 'out', 'LineWidth', 1)


saveas(f_modelRec, './figures/modelRecovery.png') 



% when is it not discriminable
f_modelLikComp = figure('Renderer', 'painters', 'Position', [0 0 300 300]); hold on;

plot(log(lik_538_538) + log(lik_Econ_538), log(lik_538_538) - log(lik_Econ_538),  '.b'); lsline;
yline(0, '--k')
xticks([])
xlabel('liklihood sum')
ylabel('liklihood difference')
title('when are models distinguishable?')
set(gca, 'TickDir', 'out', 'LineWidth', 1)


saveas(f_modelLikComp, './figures/modelLikSum.png') 


