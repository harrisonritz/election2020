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

tbl538  = tbl538(1:4e4, stateNames);
tblEcon = tblEcon(1:4e4, stateNames);


%% prepare models
popWt = readmatrix('./models/pop_weights.csv');

d_538   = log(tbl538.Variables) - log(1-tbl538.Variables);
d_Econ  = log(tblEcon.Variables) - log(1-tblEcon.Variables);


mb_538 = min(std(d_538), iqr(d_538)/1.34).*(4/(52*nsims)).^(1/54);
mb_Econ = min(std(d_Econ), iqr(d_Econ)/1.34).*(4/(52*nsims)).^(1/54);


%% compare models

% load results
r = readmatrix('./data/live_results.csv', 'Range', 'B1:ZZ54');

clear curTime
for cc = 1:sum(any(isfinite(r)))
    curTime(cc) = datetime([2020 r(1,cc) r(2,cc) r(3,cc) r(4,cc) 00]);
end

r = r(5:54,any(isfinite(r)));

d_r = real(log(r) - log(1-r));

% univariate model


clear lik_538 lik_Econ
for ss = 1:length(stateNames)
    lik_538(ss,:) = ksdensity(d_538(:,ss), d_r(ss,:), 'bandwidth', mean([mb_538(ss); mb_Econ(ss)],1), 'Kernel', 'epanechnikov');
    lik_Econ(ss,:) = ksdensity(d_Econ(:,ss), d_r(ss,:), 'bandwidth', mean([mb_538(ss); mb_Econ(ss)],1), 'Kernel', 'epanechnikov');
    
end


repPopWt = repmat(popWt, [1, size(r,2)]);

tot_lik_538 = sum(log(eps + lik_538) .* isfinite(r))./sum(isfinite(r));
tot_wt_lik_538 = sum(log(eps + lik_538) .* isfinite(r) .* repPopWt./sum(repPopWt .* isfinite(r)));

tot_lik_Econ = sum(log(eps + lik_Econ) .* isfinite(r))./sum(isfinite(r));
tot_wt_lik_Econ = sum(log(eps + lik_Econ) .* isfinite(r) .* repPopWt./sum(repPopWt .* isfinite(r)));


% multivariate model
mvlik_538 = mvksdensity(d_538, d_r', 'bandwidth', 2*mean([mb_538; mb_Econ],1), 'Kernel', 'epanechnikov');
mvlik_Econ = mvksdensity(d_Econ, d_r', 'bandwidth', 2*mean([mb_538; mb_Econ],1), 'Kernel', 'epanechnikov');

tot_mv_likDif = log(eps+mvlik_538) - log(eps+mvlik_Econ);
mv_sel = all(isfinite(r));


% plot
f_ModelCompare = figure('Renderer', 'painters', 'Position', [0 0 800 600]); 
tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');


nexttile;hold on;

p1=plot(curTime, tot_lik_538 - tot_lik_Econ, '-ok', 'LineWidth', 1, 'MarkerFaceColor', 'k', 'MarkerSize', 8);
p2=plot(curTime, tot_wt_lik_538 - tot_wt_lik_Econ, '-ob', 'LineWidth', 1, 'MarkerFaceColor', 'b', 'MarkerSize', 8);
p3=plot(curTime(mv_sel), tot_mv_likDif(mv_sel), '-or', 'LineWidth', 1, 'MarkerFaceColor', 'r', 'MarkerSize', 8);

yline(0, '--k', 'LineWidth', 2);

text(datetime([2020 11 3 19 05 00]), 17, '538 better', 'FontSize', 12)
text(datetime([2020 11 3 19 05 00]), -2, 'Economist better', 'FontSize', 12)
ylim([min(-5, f_ModelCompare.Children.Children.YLim(1)), max(20, f_ModelCompare.Children.Children.YLim(2))]);
xlim([datetime([2020 11 3 19 00 00]), max(datetime([2020 11 4 00 00 00]), max(curTime))])

% legend({'', 'population-weighted'}, 'Location', 'northeast','FontSize', 10)

title('model comparison', 'FontSize', 15)
xlabel('Time', 'FontSize', 12)
ylabel('log-likelihood difference', 'FontSize', 12)
set(gca, 'TickDir', 'out', 'LineWidth', 1)


legend([p1,p2,p3],{'un-weighted univariate', 'pop-weighted univariate', 'multivariate'}, 'Location', 'northeast', 'FontSize', 12)


% nexttile;hold on;

% yline(0, '--k', 'LineWidth', 2);

% 
% % text(datetime([2020 11 3 19 05 00]), 20, '538 better', 'FontSize', 12)
% % text(datetime([2020 11 3 19 05 00]), -20, 'Economist better', 'FontSize', 12)
% ylim([min(-25, f_ModelCompare.Children.Children(1).YLim(1)), max(25, f_ModelCompare.Children.Children(1).YLim(2))]);
% xlim([datetime([2020 11 3 19 00 00]), max(datetime([2020 11 4 00 00 00]), max(curTime))])
% 
% % legend({'', 'population-weighted'}, 'Location', 'northeast','FontSize', 10)
% 
% title('population-weighted model comparison', 'FontSize', 15)
% xlabel('Time', 'FontSize', 12)
% ylabel('log-likelihood difference', 'FontSize', 12)
% set(gca, 'TickDir', 'out', 'LineWidth', 1)
% 
% 
% 
% 
% % plot mv
% % nexttile;hold on;
% 
% % yline(0, '--k', 'LineWidth', 2);
% 
% 
% % text(datetime([2020 11 3 19 05 00]), 20, '538 better', 'FontSize', 12)
% % text(datetime([2020 11 3 19 05 00]), -20, 'Economist better', 'FontSize', 12)
% ylim([min(-25, f_ModelCompare.Children.Children(1).YLim(1)), max(25, f_ModelCompare.Children.Children(1).YLim(2))]);
% xlim([datetime([2020 11 3 19 00 00]), max(datetime([2020 11 4 00 00 00]), max(curTime))])
% 
% % legend({'', 'population-weighted'}, 'Location', 'northeast','FontSize', 10)
% 
% title('model comparison', 'FontSize', 15)
% xlabel('Time', 'FontSize', 12)
% ylabel('log-likelihood difference', 'FontSize', 12)
% set(gca, 'TickDir', 'out', 'LineWidth', 1)





saveas(f_ModelCompare, './figures/modelComparison_2.png') 




%% plot mean field


% load results
r = readmatrix('./data/live_results.csv', 'Range', 'B1:ZZ54');

clear curTime
for cc = 1:sum(any(isfinite(r)))
    curTime(cc) = datetime([2020 r(1,cc) r(2,cc) r(3,cc) r(4,cc) 00]);
end

r = r(5:54,any(isfinite(r)));


f_predMeanfield = figure('Renderer', 'painters', 'Position', [0 0 500, 1000]);
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
    
    % plot results
    if r(ss,end)>0
        xline(r(ss,end), '-b', 'LineWidth', 3);
    end
    
    title(stateNames{ss});
    
    if ss == 48
        xlabel(char(curTime(end)), 'FontSize', 12);        
    end
    
    ylim([0, 20]);
    yticks([]);
    set(gca, 'TickDir', 'out', 'LineWidth', 1);
    
    
    
end


saveas(f_predMeanfield, './figures/pred_meanfield.png') 





%% estimate bias


% load results
r = readmatrix('./data/live_results.csv', 'Range', 'B1:ZZ54');

clear curTime
for cc = 1:sum(any(isfinite(r)))
    curTime(cc) = datetime([2020 r(1,cc) r(2,cc) r(3,cc) r(4,cc) 00]);
end

r = r(5:54,any(isfinite(r)));



f_predError = figure('Renderer', 'painters', 'Position', [0 0 400, 300]);
tiledlayout('flow','TileSpacing', 'compact', 'Padding', 'compact');


nexttile; hold on;

histogram((r(:,end) - mean(tbl538.Variables)')*100,  -14:4,  'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineWidth', 2)
histogram((r(:,end) - mean(tblEcon.Variables)')*100, -14:4, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 2)
xline(0, '--k', 'LineWidth', 1);


text(-.5, .275, 'Trump', 'FontSize', 12, 'HorizontalAlignment', 'right')
text(.5, .275, 'Biden', 'FontSize', 12, 'HorizontalAlignment', 'left')



set(gca, 'TickDir', 'out', 'LineWidth', 1);
title('state prediction error', 'FontSize', 15)

xlabel(['prediction error (%)  ||  ' char(curTime(end))], 'FontSize', 12)
ylabel('density', 'FontSize', 12);
yticks([])

legend({'538', 'Economist'}, 'Location', 'northwest')


saveas(f_predError, './figures/predError.png') 

