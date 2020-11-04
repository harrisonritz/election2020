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


%% prepare models
popWt = readmatrix('./models/pop_weights.csv');

d_538   = log(tbl538.Variables) - log(1-tbl538.Variables);
d_Econ  = log(tblEcon.Variables) - log(1-tblEcon.Variables);


b_538 = min(std(d_538), iqr(d_538)/1.34).*(4/(52*nsims)).^(1/54);
b_Econ = min(std(d_Econ), iqr(d_Econ)/1.34).*(4/(52*nsims)).^(1/54);



%% compare models

% load results
r = readmatrix('./data/live_results.csv', 'Range', 'B1:ZZ52');

clear curTime
for cc = 1:size(r,2)
    curTime(cc) = datetime([2020 11 3 r(1,cc) r(2,cc) 00]);
end

r = r(3:52,:);

% univariate model
clear lik_538 lik_Econ
for ss = 1:length(stateNames)
    lik_538(ss,:) = ksdensity(d_538(:,ss), r(ss,:), 'bandwidth', b_538(ss), 'Kernel', 'epanechnikov');
    lik_Econ(ss,:) = ksdensity(d_Econ(:,ss), r(ss,:), 'bandwidth', b_Econ(ss), 'Kernel', 'epanechnikov');
end

repPopWt = repmat(popWt, [1, size(r,2)]);

tot_lik_538 = sum(log(eps + lik_538) .* isfinite(r))./sum(isfinite(r));
tot_wt_lik_538 = sum(log(eps + lik_538) .* isfinite(r) .* repPopWt./sum(repPopWt .* isfinite(r)));

tot_lik_Econ = sum(log(eps + lik_Econ) .* isfinite(r))./sum(isfinite(r));
tot_wt_lik_Econ = sum(log(eps + lik_Econ) .* isfinite(r) .* repPopWt./sum(repPopWt .* isfinite(r)));



% plot
f_ModelCompare = figure('Renderer', 'painters', 'Position', [0 0 700 500]); 
tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');


nexttile;hold on;

plot(curTime, tot_lik_538 - tot_lik_Econ, '-ok', 'LineWidth', 1, 'MarkerFaceColor', 'k', 'MarkerSize', 8);
yline(0, '--k', 'LineWidth', 2);

text(datetime([2020 11 3 19 05 00]), 5, '538 better', 'FontSize', 12)
text(datetime([2020 11 3 19 05 00]), -5, 'Economist better', 'FontSize', 12)
ylim([min(-25, f_ModelCompare.Children.Children.YLim(1)), max(25, f_ModelCompare.Children.Children.YLim(2))]);
xlim([datetime([2020 11 3 19 00 00]), max(datetime([2020 11 4 00 00 00]), max(curTime))])

% legend({'', 'population-weighted'}, 'Location', 'northeast','FontSize', 10)

title('un-weighted model comparison', 'FontSize', 15)
xlabel('Time', 'FontSize', 12)
ylabel('log-likelihood difference', 'FontSize', 12)
set(gca, 'TickDir', 'out', 'LineWidth', 1)




nexttile;hold on;

plot(curTime, tot_wt_lik_538 - tot_wt_lik_Econ, '-ob', 'LineWidth', 1, 'MarkerFaceColor', 'b', 'MarkerSize', 8);
yline(0, '--k', 'LineWidth', 2);


text(datetime([2020 11 3 19 05 00]), 5, '538 better', 'FontSize', 12)
text(datetime([2020 11 3 19 05 00]), -5, 'Economist better', 'FontSize', 12)
ylim([min(-25, f_ModelCompare.Children.Children(1).YLim(1)), max(25, f_ModelCompare.Children.Children(1).YLim(2))]);
xlim([datetime([2020 11 3 19 00 00]), max(datetime([2020 11 4 00 00 00]), max(curTime))])

% legend({'', 'population-weighted'}, 'Location', 'northeast','FontSize', 10)

title('population-weighted model comparison', 'FontSize', 15)
xlabel('Time', 'FontSize', 12)
ylabel('log-likelihood difference', 'FontSize', 12)
set(gca, 'TickDir', 'out', 'LineWidth', 1)




saveas(f_ModelCompare, './figures/modelComparison_1.png') 


