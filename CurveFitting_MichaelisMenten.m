% MichaelisMenten_Kd
% This is a script for determining Kd and Bmax values from kinetic measurements.
%
% Created by Sven T. Bitters (3/2016) - sven.bitters@gmail.com
% License: CC-BY (http://creativecommons.org/licenses/by/4.0/)


function [x_fit, y_fit, Xlinlog_orig, Ylinlog_orig] = CurveFitting_MichaelisMenten(x_axis_data, y_axis_data, error_data, x_axis_unit)

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
ft = fittype('(Bmax * x) / (Kd + x)', 'Independent', {'x'}, 'Coefficients', {'Kd', 'Bmax'});
foptions = fitoptions('Method', 'NonlinearLeastSquares', 'Lower',[0 0], 'StartPoint', [0 0], 'MaxFunEvals', 10000, 'MaxIter', 2000);

[xDat_curve, yDat_curve] = prepareCurveData(x_axis_data, y_axis_data);
[fit_result, gof] = fit(xDat_curve, yDat_curve, ft, foptions);

% Extract points from the fitting model for plotting
x_fit = linspace(-10, x_axis_data(end)*200, x_axis_data(end)*20000);
y_fit = (fit_result.Bmax*x_fit)./(fit_result.Kd + x_fit);

% Draw indicator line for Bmax
line_color = [0.4 0.4 0.4];
plot(x_fit, ones(size(x_fit))*fit_result.Bmax, '--', 'Color', line_color)

% Draw indicator lines for Kd
x_line_x = [0, fit_result.Kd];
y_line_x = [(fit_result.Bmax*fit_result.Kd)/(fit_result.Kd + fit_result.Kd), (fit_result.Bmax*fit_result.Kd)/(fit_result.Kd + fit_result.Kd)];
x_line_y = [fit_result.Kd, fit_result.Kd];
y_line_y = [(fit_result.Bmax*fit_result.Kd)/(fit_result.Kd + fit_result.Kd), 0];

plot(x_line_x', y_line_x', 'Color', line_color, 'Linewidth', 1)
plot(x_line_y', y_line_y', 'Color', line_color, 'Linewidth', 1)

% Plot the original data points
hold on
errorbar(x_axis_data, y_axis_data, error_data, '.k', 'MarkerSize', 15);

% Write Bmax and Kd in the plot window
Xmax_str = [char(Xmax), ' = ~ ', num2str(sprintf('%.1f',round(fit_result.Bmax, 1))), ' ', char(unit_Xmax)];
text(fit_result.Kd*0.025, fit_result.Bmax*0.925, Xmax_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')

K_str = [K, ' = ~ ', num2str(sprintf('%.1f',round(fit_result.Kd, 1))), ' ', char(x_axis_unit)];
text(fit_result.Kd*1.025, fit_result.Bmax*0.05, K_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')

% Write Rsq in the plot window
rsquared_str = ['R^2 =  ',  num2str(sprintf('%.3f',round(gof.rsquare,3)))];
text(max(x_axis_data)*1.15, fit_result.Bmax*1.1, rsquared_str, 'FontName', 'Arial', 'fontsize', 12)

%============= Configuring the presentation of the figure =================

% Create axes
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')
Xlinlog_orig = 'lin';
Ylinlog_orig = 'lin';

if max(y_axis_data + error_data) > fit_result.Bmax
    y_axis_lim = max(y_axis_data + error_data) * 1.15;
else
    y_axis_lim = fit_result.Bmax * 1.15;
end
axis([0 max(x_axis_data)*1.5 0 y_axis_lim])

set(gca, 'XMinorTick', 'on')
set(gca, 'YMinorTick', 'on')