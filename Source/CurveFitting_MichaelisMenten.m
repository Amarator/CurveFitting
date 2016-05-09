% MichaelisMenten_Kx
% This is a script for determining Kx and Xmax values from kinetic measurements.
%
% Created by Sven T. Bitters (3/2016) - sven.bitters@gmail.com
% License: CC-BY (http://creativecommons.org/licenses/by/4.0/)


function [x_fit, y_fit, x_axis_data, y_axis_data, error_data, Xlinlog_orig, Ylinlog_orig, parameters] = CurveFitting_MichaelisMenten(x_axis_data, y_axis_data, error_data, x_axis_unit, sample_no)

K = 'K_{m}';
Xmax = 'V_{max}';

quest_MM = questdlg('Which constants do you want to calculate?',...
    'Curve Fitting - Michaelis-Menten', 'Km and Vmax',...
    'Kd and Bmax', 'Km and Vmax');
waitfor(quest_MM);

switch quest_MM
    case 'Km and Vmax'
        K = 'K_{m}';
        Xmax = 'V_{max}';
    case 'Kd and Bmax'
        K = 'K_{d}';
        Xmax = 'B_{max}';
end

unit_Xmax = 'N/A';
unit_Xmax = inputdlg(['Input unit for ', Xmax], 'Curve Fitting - Michaelis-Menten', 1, {'pmol/µg'});
waitfor(unit_Xmax);

% Create a fitting model and fit data
ft = fittype('(Xmax * x) / (Kx + x)', 'Independent', {'x'}, 'Coefficients', {'Kx', 'Xmax'});
foptions = fitoptions('Method', 'NonlinearLeastSquares', 'Lower',[0 0], 'StartPoint', [0 0], 'MaxFunEvals', 10000, 'MaxIter', 2000);

[xDat_curve, yDat_curve] = prepareCurveData(x_axis_data, y_axis_data);
[fit_result, gof] = fit(xDat_curve, yDat_curve, ft, foptions);

% Extract points from the fitting model for plotting
x_fit = linspace(-10, x_axis_data(end)*200, x_axis_data(end)*20000);
y_fit = (fit_result.Xmax*x_fit)./(fit_result.Kx + x_fit);

% Draw indicator line for Xmax
line_color = [0.4 0.4 0.4];
plot(x_fit, ones(size(x_fit))*fit_result.Xmax, '--', 'Color', line_color)

% Draw indicator lines for Kx
x_line_x = [0, fit_result.Kx];
y_line_x = [(fit_result.Xmax*fit_result.Kx)/(fit_result.Kx + fit_result.Kx), (fit_result.Xmax*fit_result.Kx)/(fit_result.Kx + fit_result.Kx)];
x_line_y = [fit_result.Kx, fit_result.Kx];
y_line_y = [(fit_result.Xmax*fit_result.Kx)/(fit_result.Kx + fit_result.Kx), 0];

plot(x_line_x', y_line_x', 'Color', line_color, 'Linewidth', 1)
plot(x_line_y', y_line_y', 'Color', line_color, 'Linewidth', 1)

% Plot the original data points
% hold on
% errorbar(x_axis_data, y_axis_data, error_data, '.k', 'MarkerSize', 15);

if sample_no == 1
    % Write Xmax and Kx in the plot window
    Xmax_str = [char(Xmax), ' = ~ ', num2str(sprintf('%.1f',round(fit_result.Xmax, 1))), ' ', char(unit_Xmax)];
    text(fit_result.Kx*0.025, fit_result.Xmax*0.925, Xmax_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')
    
    K_str = [K, ' = ~ ', num2str(sprintf('%.1f',round(fit_result.Kx, 1))), ' ', char(x_axis_unit)];
    text(fit_result.Kx*1.025, fit_result.Xmax*0.05, K_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')
    
    % Write Rsq in the plot window
    rsquared_str = ['R^2 =  ',  num2str(sprintf('%.3f',round(gof.rsquare,3)))];
    text(max(x_axis_data)*1.15, fit_result.Xmax*1.1, rsquared_str, 'FontName', 'Arial', 'fontsize', 12)
end

% Return Xmax, Kx, and Rsq
parameters = {char(Xmax) num2str(fit_result.Xmax) char(K) num2str(fit_result.Kx) 'RSQ' num2str(gof.rsquare)};
%============= Configuring the presentation of the figure =================

% Create axes
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')
Xlinlog_orig = 'lin';
Ylinlog_orig = 'lin';

if max(y_axis_data + error_data) > fit_result.Xmax
    y_axis_lim = max(y_axis_data + error_data) * 1.15;
else
    y_axis_lim = fit_result.Xmax * 1.15;
end
axis([0 max(x_axis_data)*1.5 0 y_axis_lim])

set(gca, 'XMinorTick', 'on')
set(gca, 'YMinorTick', 'on')