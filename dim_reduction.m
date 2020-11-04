%% dim reduction

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



%% plot MDS


l538 = log(tbl538.Variables) - log(1-tbl538.Variables);
lEcon = log(tblEcon.Variables) - log(1-tblEcon.Variables);



f_embed = figure('Renderer', 'painters', 'Position', [0 0 400 200]);



% 538 embed
dist538 = squareform(pdist(zscore(l538)', 'euclidean'));
s538 = isomap(dist538, 3);
% s538 = cmdscale(dist538, 3);


% Econ embed
distEcon = squareform(pdist(zscore(lEcon)', 'euclidean'));
[~, sEcon] = procrustes(s538, isomap(distEcon, 3));
% [~, sEcon] = procrustes(s538, cmdscale(distEcon, 3));



nexttile; hold on; grid;

plot3(s538(dem,1), s538(dem,2), s538(dem,3), 'om', 'MarkerFaceColor', 'm')
plot3(s538(~dem,1), s538(~dem,2), s538(~dem,3), 'ob', 'MarkerFaceColor', 'b')



title('Partisanship (538)')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])
zticks([])





nexttile; hold on; grid;

dem = mean(tblEcon.Variables)>.5;

plot3(sEcon(dem,1), sEcon(dem,2), sEcon(dem,3), 'om', 'MarkerFaceColor', 'm')
plot3(sEcon(~dem,1), sEcon(~dem,2), sEcon(~dem,3), 'ob', 'MarkerFaceColor', 'b')


title('Partisanship (Economist)')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])
zticks([])





% 
% nexttile; hold on; grid;
% 
% dem = std((tblEcon.Variables))>median(std((tblEcon.Variables)));
% 
% plot3(sEcon(dem,1), sEcon(dem,2), sEcon(dem,3), 'om', 'MarkerFaceColor', 'm')
% plot3(sEcon(~dem,1), sEcon(~dem,2), sEcon(~dem,3), 'ob', 'MarkerFaceColor', 'b')
% 
% 
% title('Uncertainty')
% set(gca, 'LineWidth', 1)
% yticks([])
% xticks([])
% zticks([])


saveas(f_embed, './figures/embed.png') 




%% MDS movie





l538 = log(tbl538.Variables) - log(1-tbl538.Variables);
lEcon = log(tblEcon.Variables) - log(1-tblEcon.Variables);



f_embed = figure('Renderer', 'painters', 'Position', [0 0 500 500]);
nexttile([1,2]); hold on; grid;


% 538 embed
dist538 = squareform(pdist(zscore(l538)', 'cosine'));
s538 = isomap(dist538, 3);
% s538 = cmdscale(dist538, 3);


plot3(s538(:,1), s538(:,2), s538(:,3), 'ok', 'MarkerFaceColor', 'k')

text(s538(:,1), s538(:,2), s538(:,3), tbl538.Properties.VariableNames)



% Econ embed
distEcon = squareform(pdist(zscore(lEcon)', 'cosine'));
[~, sEcon] = procrustes(s538, isomap(distEcon, 3));
% [~, sEcon] = procrustes(s538, cmdscale(distEcon, 3));

plot3(sEcon(:,1), sEcon(:,2), sEcon(:,3), 'or', 'MarkerFaceColor', 'r')

text(sEcon(:,1), sEcon(:,2), sEcon(:,3), tblEcon.Properties.VariableNames)


% plot connections
for ii = 1:size(s538,1)
    plot3([s538(ii,1);sEcon(ii,1)], [s538(ii,2);sEcon(ii,2)], [s538(ii,3);sEcon(ii,3)], '--k');
end


title('Correlation embedding')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])
zticks([])


% make movie
OptionZ.FrameRate=15;OptionZ.Duration=8;OptionZ.Periodic=true;
CaptureFigVid([1:360; ones(1,360)*10]', './figures/embedVid',OptionZ)






%% partisan



l538 = log(tbl538.Variables) - log(1-tbl538.Variables);
lEcon = log(tblEcon.Variables) - log(1-tblEcon.Variables);



f_embed = figure('Renderer', 'painters', 'Position', [0 0 500 500]);
nexttile([1,2]); hold on; grid;


% 538 embed
dist538 = squareform(pdist(zscore(l538)', 'cosine'));
s538 = isomap(dist538, 3);
% s538 = cmdscale(dist538, 3);


% plot3(s538(:,1), s538(:,2), s538(:,3), 'ok', 'MarkerFaceColor', 'k')

text(s538(:,1), s538(:,2), s538(:,3), tbl538.Properties.VariableNames)



% Econ embed
distEcon = squareform(pdist(zscore(lEcon)', 'cosine'));
[~, sEcon] = procrustes(s538, isomap(distEcon, 3));
% [~, sEcon] = procrustes(s538, cmdscale(distEcon, 3));

% plot3(sEcon(:,1), sEcon(:,2), sEcon(:,3), 'or', 'MarkerFaceColor', 'r')



% plot connections
% for ii = 1:size(s538,1)
%     plot3([s538(ii,1);sEcon(ii,1)], [s538(ii,2);sEcon(ii,2)], [s538(ii,3);sEcon(ii,3)], '--k');
% end


title('Correlation embedding')
set(gca, 'LineWidth', 1)
yticks([])
xticks([])
zticks([])


dem = mean(tblEcon.Variables)>.5;

text(s538(:,1), s538(:,2), s538(:,3), tbl538.Properties.VariableNames)

plot3(s538(dem,1), s538(dem,2), s538(dem,3), 'om', 'LineWidth', 2)
plot3(s538(~dem,1), s538(~dem,2), s538(~dem,3), 'ob', 'LineWidth', 2)
% plot3(sEcon(dem,1), sEcon(dem,2), sEcon(dem,3), 'om', 'LineWidth', 2)
% plot3(sEcon(~dem,1), sEcon(~dem,2), sEcon(~dem,3), 'ob', 'LineWidth', 2)


% make movie
OptionZ.FrameRate=15;OptionZ.Duration=8;OptionZ.Periodic=true;
CaptureFigVid([1:360; ones(1,360)*10]', './figures/embedVid',OptionZ)
