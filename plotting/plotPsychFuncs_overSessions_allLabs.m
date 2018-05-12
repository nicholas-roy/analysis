%function data = plotPsychFuncs_overSessions_allLabs()
% make overview plots across labs
% uses the gramm toolbox: https://github.com/piermorel/gramm
% Anne Urai, 2018

% grab all the data that's on Drive
addpath('~/Desktop/code/npy-matlab//');
data = readAlf_allData();
addpath('~/Desktop/code/gramm/');

%% use gramm for easy dataviz
% bestAnimals = {'Kornberg', '4619', 'Mouse2'};
bestAnimals = unique(data.animal);
close all;
g = gramm('x', data.signedContrast, 'y', (data.response > 0), 'color', data.dayidx, ...
    'subset', ismember(data.animal, bestAnimals));
g.set_names('x', 'Signed contrast (%)', 'y', 'P(rightwards)', 'color', 'Days', 'Row', 'animal');
g.set_continuous_color('active', false);  
g.set_color_options('map', flipud(plasma(100)));
g.stat_summary('type', 'std', 'geom', 'line'); % no errorbars within a session
g.facet_wrap(data.name, 'ncols', 7);
g.set_text_options('facet_scaling', 1, 'title_scaling', 1, 'base_size', 9);
g.no_legend();
g.draw();

% overlay the summary psychometric in black for the later sessions
g.update('x', data.signedContrast, 'y', (data.response > 0), ...
   'color', ones(size(data.dayidx)), 'subset', (data.dayidx > 7 & ismember(data.animal, bestAnimals)));
g.stat_summary('type', 'bootci', 'geom', 'errorbar');
g.stat_summary('type', 'std', 'geom', 'line'); % hack to get a connected errorbar
g.set_color_options('map', zeros(max(data.dayidx), 3)); % black
g.draw();

% ADD A COLORBAR FOR SESSION NUMBER
colormap(flipud(plasma));
subplot(7,8,56);
c = colorbar;
c.Location = 'EastOutside';
axis off;
prettyColorbar('Sessions');
c.Ticks = [0 1];
c.TickLabels = {'early', 'late'};

print(gcf, '-dpdf', '/Users/anne/Google Drive/Rig building WG/Data/psychfuncs_alllabs.pdf');
print(gcf, '-dpng', '/Users/anne/Google Drive/Rig building WG/Data/psychfuncs_alllabs.png');

%% SAME FOR REACTION TIMES

% leave out 0% contrast
close all;
g = gramm('x', abs(data.signedContrast), 'y', data.rt, 'color', data.dayidx, 'subset', abs(data.signedContrast) > 0);
g.set_names('x', 'Contrast (%)', 'y', 'RT (ms)', 'color', 'Days', 'Column', 'animal');
g.set_continuous_color('active', false);  
g.set_color_options('map', flipud(plasma(100)));
g.stat_summary('type', 'quartile', 'geom', 'line', 'setylim', 1); % no errorbars within a session
g.facet_wrap(data.name, 'ncols', 7);
g.set_text_options('facet_scaling', 1, 'title_scaling', 1, 'base_size', 9);
g.no_legend();
g.axe_property('ylim', [0 2]);
g.draw();

% overlay the summary psychometric in black for the later sessions
g.update('x', abs(data.signedContrast), 'y', data.rt, ...
   'color', ones(size(data.dayidx)), 'subset', (data.dayidx > 7 & abs(data.signedContrast) > 0));
g.stat_summary('type', 'quartile', 'geom', 'line', 'setylim', 1); % hack to get a connected errorbar
% g.stat_summary('type', 'quartile', 'geom', 'errorbar', 'setylim', 1); % hack to get a connected errorbar
g.set_color_options('map', zeros(max(data.dayidx), 3)); % black
g.draw();

% ADD A COLORBAR FOR SESSION NUMBER
colormap(flipud(plasma));
subplot(7,8,56);
c = colorbar;
c.Location = 'EastOutside';
axis off;
prettyColorbar('Sessions');
c.Ticks = [0 1];
c.TickLabels = {'early', 'late'};

print(gcf, '-dpdf', '/Users/anne/Google Drive/Rig building WG/Data/rts_alllabs.pdf');
print(gcf, '-dpng', '/Users/anne/Google Drive/Rig building WG/Data/rts_alllabs.png');


%% LEARNING RATES ACROSS 
close all;
g = gramm('x', data.dayidx, 'y', data.correct, 'color', data.animal,...
    'subset', (abs(data.signedContrast) >= 80 & data.dayidx < 31));
g.set_names('x', 'Training day', 'y', 'Performance (%)', 'color', 'Animal', 'Row', 'Lab');
g.geom_hline('yintercept', 0.5);
g.set_color_options('map', repmat(linspecer(11, 'qualitative'), 3, 1));
g.stat_summary('type', 'sem', 'geom', 'line', 'setylim', 1); % no errorbars within a session
g.facet_grid(data.lab, []);
g.set_text_options('facet_scaling', 1, 'title_scaling', 1, 'base_size', 9);
g.set_title('Performance on > 80% contrast trials');
g.draw();

% overlay the summary psychometric in black for the later sessions
g.update('color', data.lab);
g.stat_summary('type', 'sem', 'geom', 'line', 'setylim', 1); % hack to get a connected errorbar
g.set_color_options('map', zeros(max(data.dayidx), 3)); % black
g.no_legend();
g.draw();

print(gcf, '-dpdf', '/Users/anne/Google Drive/Rig building WG/Data/learningrates_alllabs.pdf');
print(gcf, '-dpng', '/Users/anne/Google Drive/Rig building WG/Data/learningrates_alllabs.png');

%% PSYCHOMETRIC FUNCTION PER LAB
% ONLY USE MICE THAT ARE CONSIDERED TRAINED!
% correct = data.correct;
% correct(abs(data.signedContrast) < 80) = NaN;
% correct(data.dayidx < 11) = NaN;
% [gr, animalName] = findgroups(data.animal);
% correctPerMouse = splitapply(@nanmean, correct, gr);
% goodAnimals = animalName(correctPerMouse > 0.6);

goodAnimals = {'4581', 'M6', 'Medawar'}; close all;
g = gramm('x', data.signedContrast, 'y', double(data.response > 0), ...
    'subset', (data.dayidx > 0 & ismember(data.animal, goodAnimals)));
g.set_names('x', 'Signed contrast (%)', 'y', 'P(rightwards)');

% overlay logistic fit in black
g.stat_fit('fun', @(a,b,g,l,x) g+(1-g-l) * (1./(1+exp(- ( a + b.*x )))), ...
    'StartPoint', [0 0.1 0.1 0.1], 'geom', 'line', 'disp_fit', false, 'fullrange', false);
g.set_color_options('map', zeros(max(data.dayidx), 3)); % black
g.facet_wrap(data.lab, 'ncols', 4);
g.set_text_options('facet_scaling', 1, 'title_scaling', 1, 'base_size', 10);
g.no_legend();
g.axe_property('PlotBoxAspectRatio', [1 1 1]);
g.draw();

% summary stats
g.update();
g.stat_summary('type', 'bootci', 'geom', 'errorbar', 'setylim', 1);
g.stat_summary('type', 'bootci', 'geom', 'point', 'setylim', 1);
red = linspecer(2);
g.set_color_options('map', repmat(red(2, :), 3, 1)); % black
g.draw();

print(gcf, '-dpdf', '/Users/anne/Google Drive/Rig building WG/Data/psychfuncs_perlab.pdf');
print(gcf, '-dpng', '/Users/anne/Google Drive/Rig building WG/Data/psychfuncs_perlab.png');

% ends
