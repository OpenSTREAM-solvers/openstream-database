function plotResults(data, solver, range)
%PLOTRESULTS Plot predicted film thickness at the end of the simulation.
%   This implementation is specific to the Farrell2024 dataset and plots
%   the predicted end-of-simulation film thickness against the measured
%   film thickness from the dataset.
%   The optional range input selects a subset of the data.

arguments
    data
    solver
    range = []
end

if ~isempty(range)
    data = data(range);
end

measuredThickness = arrayfun(@(x) x.entryData.MeasuredFilmThickness, data);
predictedThickness = arrayfun(@(x) getPredictedFilmThickness(x), data);

valid = isfinite(measuredThickness) & isfinite(predictedThickness);
if ~any(valid)
    warning('No valid measured/predicted film thickness pairs found to plot.');
    return
end

measuredThickness = measuredThickness(valid) .* 1e6;
predictedThickness = predictedThickness(valid) .* 1e6;
plotData = find(valid);

figure('Name','Predicted vs Measured Film Thickness');
cla;
p = scatter(measuredThickness, predictedThickness, 50, 'filled', ...
    'MarkerFaceColor', [0 0.4470 0.7410]);
grid on;
axis equal;

xlabel('Measured film thickness [\mum]');
ylabel('Predicted film thickness [\mum]');

links = max([measuredThickness(:); predictedThickness(:)]);
xmax = max(links * 1.1, 1);
xlim([0 xmax]);
ylim([0 xmax]);
hold on;
plot([0 xmax], [0 xmax], 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
hold off;
set(gca, 'FontSize', 14);

nPoints = numel(measuredThickness);
title(sprintf(' Three Field Model Pre Obstruction Film Thickness (N=%d)', nPoints), 'FontSize', 16);

% Add datatips only for plotted entries
plottedData = data(plotData);
adddatatip(plottedData, p, 'Measured', 'Predicted');

end

function thickness = getPredictedFilmThickness(dataItem)
%GETPREDICTEDFILMTHICKNESS Extract end-of-simulation film thickness.
%   Only the three-field film thickness is used for this study.

thickness = NaN;
hasResults = (isobject(dataItem) && isprop(dataItem, 'results')) || (isstruct(dataItem) && isfield(dataItem, 'results'));
if ~hasResults
    return
end

resultsObj = dataItem.results;
hasFilm = (isobject(resultsObj) && isprop(resultsObj, 'film')) || (isstruct(resultsObj) && isfield(resultsObj, 'film'));
if ~hasFilm
    return
end

film = resultsObj.film;
if isempty(film)
    return
end

if ismethod(film, 'THICK')
    try
        thick = film(end).THICK();
    catch
        return
    end
elseif isfield(film, 'THICK')
    thick = film(end).THICK;
else
    return
end

thickness = extractEndThickness(thick, film);

end

function thickness = extractEndThickness(thick, film)
%EXTRACTENDTHICKNESS Convert thickness array to a scalar prediction.
%   Returns the outlet thickness from the first heated wall when multiple
%   walls are present.
thickness = NaN;
if isempty(thick)
    return
end

try
    endSlice = thick(end, :);
catch
    try
        endSlice = thick(end);
    catch
        return
    end
end

wallIdx = 1;

if isvector(endSlice)
    if wallIdx <= numel(endSlice)
        thickness = endSlice(wallIdx);
    else
        thickness = endSlice(1);
    end
else
    if wallIdx <= size(endSlice, 2)
        thickness = endSlice(1, wallIdx);
    else
        thickness = endSlice(1, 1);
    end
end

end

function adddatatip(data, p, xname, yname)

p.DataTipTemplate.DataTipRows(1).Label = xname;
p.DataTipTemplate.DataTipRows(2).Label = yname;
dtRows = [dataTipTextRow("Case", 1:length(data)), dataTipTextRow("Run", arrayfun(@(x) x.entryData.TestID, data))];
p.DataTipTemplate.DataTipRows(end+1:end+2) = dtRows;

end

