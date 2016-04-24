% sigmoid_curve_fitting
% This is a script for plotting sigmoidal curves of best fit.
%
% Original script "sigmoid_curve_fitting"
% by Peter Ghazal and Steven Watterson (17.7.2012)
% Available on: https://figshare.com/articles/Matlab_Script_for_fitting_sigmoidal_curves_to_infection_inhibition_data./97311
% used under CC-BY (http://creativecommons.org/licenses/by/4.0/)
%
% Modified by Sven T. Bitters (21.3.2016) - sven.bitters@gmail.com
% - Refactored code and improved usability for working with data not 
%   related to infection inhibition
% - Revised IC50 determination method
% - Added subplot functionality
% - Introduced dynamic determination of various aspects concerning plotting
%   (e.g. ticks, axes lengths)
% - Included my default data
%
%
% Works with MATLAB R2015b and Curve Fitting Toolbox 3.5.2
%
%
% Requires a minimum of 5 data points per data set.


function [x_sig, y_sig, working_c, working_data, working_error_data, Xlinlog_orig, Ylinlog_orig] = CurveFitting_sigmoid(x_axis_data, y_axis_data, error_data, x_axis_unit)

%====================== Input your data here! =============================

% Set all data < 0 to 0 --> plausibility
y_axis_data(y_axis_data<0) = 0;

% Determine the size of the y_axis_data matrix
data_size = size(y_axis_data);

% Form of the data points (marker and colour)
data_points = cellstr('ok');
data_points_size = 30;

% Form of the curve of best fit (continuous, dashed etc, plus colour)
curve_form = cellstr('-r');

% IC50s:
% Instead of determining the IC50 at y-axis value 50% while
% disregarding the actual value where saturation occurs, the y-axis
% position of the IC50 value will be determined according to
% ic50_pos = (100+min(working_data))/2;
% Your first data set will be used to determine ic50_pos and the same
% ic50_pos will be used for all following data sets
% (IC50_opts = 'relative_first').
% If you want to set IC50 always at y = 50%, set IC50_opts = '50'.
% If you want to determine a relative IC50 position for each individual 
% data set, set IC50_opts = 'relative'.

IC50_opts = '50';

quest_50 = questdlg('Select IC50 determination method:',...
                    'Curve Fitting - Sigmoid', 'Relative to data',...
                    'At 50%', 'At 50%');
waitfor(quest_50);

switch quest_50
    case 'Relative to data'
        IC50_opts = 'relative';
    case 'At 50%'
        IC50_opts = '50';
end


%==========================================================================


% Initialize some variables
ic50_x = zeros(data_size(1),1);
ic50_y = zeros(data_size(1),1);

for ii = 1:data_size(1)
    % Make percent
    working_data = (y_axis_data(ii,:) / y_axis_data(ii,1)) * 100;
    if ~isempty(error_data)
        working_error_data = (error_data(ii,:) / y_axis_data(ii,1)) * 100;
    end
        
    % Logarithmize x-axis values
    working_c_log = log10(x_axis_data);

    % Set up the sigmoidal model
    curve = @(a, b, c, d, e, x) a./(b+exp(-c*(x-d)))+e;
    
    lower_bound = [-Inf -Inf -Inf min(working_c_log), -max(working_data)];
    upper_bound = [Inf Inf Inf max(working_c_log), max(working_data)];
    starting_param = [max(working_data) 1 1 working_c_log(round(length(working_c_log)/2)), min(working_data)];
    [fit_op, gof, output] = fit(working_c_log', working_data', curve, 'StartPoint', starting_param, 'Lower', lower_bound, 'Upper', upper_bound, 'MaxFunEvals', 10000, 'MaxIter', 2000);
    
    coeffs = coeffvalues(fit_op);
    
    % Extract points from the fitting model for plotting
    x_sig = min(working_c_log):((max(working_c_log)-min(working_c_log))/1000):max(working_c_log);
    y_sig = curve(coeffs(1), coeffs(2), coeffs(3), coeffs(4), coeffs(5), x_sig);
        
    % Reverse logarithmization
    working_c = 10.^working_c_log;
    x_sig = 10.^x_sig;

    % Determine the IC50 position
    switch IC50_opts
        case 'relative_first'
            if ii == 1
                ic50_pos = (100+min(working_data))/2;
            end
        case 'relative'
            ic50_pos = (100+min(working_data))/2;
        case '50'
            ic50_pos = 50;
    end
    
    % Find IC50 by shifting the fitting function down by ic50_pos and then
    % looking for the x value at the zero point.
    objective = @(value)fit_op(value)-ic50_pos;
    ic50_log = fzero(objective, 1);
    
    ic50 = 10.^ic50_log;
    ic50_rnd = round(ic50);
    ic50_str = strcat(num2str(ic50_rnd), {' '}, x_axis_unit);
    
    % Plot lines indicating the IC50 value
    x_line_x = [min(x_axis_data)/1000000, ic50_rnd];
    y_line_x = [ic50_pos, ic50_pos];
    x_line_y = [ic50_rnd, ic50_rnd];
    y_line_y = [ic50_pos, 0];
    
    plot(x_line_x', y_line_x', 'Color', [.5 .5 .5], 'Linewidth', 1)
    plot(x_line_y', y_line_y', 'Color', [.5 .5 .5], 'Linewidth', 1)
    
    % Plot errorbars and data points
%     if ~isempty(error_data)
%         errorbar(working_c, working_data, working_error_data, char(data_points), 'MarkerSize', round(sqrt(data_points_size)));
%     else
%         scatter(working_c, working_data, char(data_points));
%     end
        
    % Range of the y-axis
    if isempty(error_data)
        error_data = zeros(data_size(1), data_size(2));
    end
    
    y_h = ceil(max(max(working_data+working_error_data))/10)*10;
    while mod(y_h, 20) ~= 0
        y_h = y_h + 10;
    end
    y_top = y_h;
    y_bot = 0;
    
    % Range of the x-axis
    if max(x_axis_data) > 1
        x_max_numlength = strsplit(num2str(max(x_axis_data)),'.');
        x_top = 10^(length(x_max_numlength{1}));
    elseif max(x_axis_data) < 1
        x_max_numlength = log10(max(x_axis_data));
        x_top = 10^round(x_max_numlength);
    else
        x_top = max(x_axis_data)*10;
    end
    
    if min(x_axis_data) > 1
        x_min_numlength = strsplit(num2str(min(x_axis_data)),'.');
        x_bot = 10^(length(x_min_numlength{1})-1);
    elseif min(x_axis_data) == 1
        x_bot = min(x_axis_data)/10;
    elseif min(x_axis_data) == 0
        x_h = unique(x_axis_data);
        x_bot = x_h(2)/10;
    elseif min(x_axis_data) < 1
        x_min_numlength = floor(log10(min(x_axis_data)));
        x_bot = 10^x_min_numlength;
    end
    
    % Determine x-axis ticks
    x_ticks(1) = x_bot;
    count = 2;
    while x_ticks < x_top
        x_ticks(count) = x_ticks(count-1)*10;
        count = count + 1;
    end
    
    % Create axes
    axis(gca, [x_bot/2 x_top y_bot y_top])
    set(gca, 'xscale', 'log');
    Xlinlog_orig = 'log';
    Ylinlog_orig = 'lin';
    
    % Write IC50 values
    str1 = ['IC_{50} = ~ ' char(ic50_str)];
    ic50_x(ii) = x_bot*0.65;
    ic50_y(ii) = (ic50_pos-10)*0.9;
    text(ic50_x(ii),ic50_y(ii), str1, 'FontName', 'Arial', 'fontsize', 14, 'FontWeight', 'Demi')
    
    % Write RSQ values
    rsquare_str = ['R^2 = ' num2str(sprintf('%.3f',round(gof.rsquare, 3)))];
    text( x_ticks(ceil(length(x_ticks)/2))*10, y_top-10, rsquare_str, 'FontName', 'Arial', 'fontsize', 11)
    
    % Set ticks
    set(gca, 'YTick', 0:20:y_top)
    set(gca, 'XTick', x_ticks)
    
end