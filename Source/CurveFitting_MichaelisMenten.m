% CurveFitting_MichaelisMenten
% This is a script for determining Kx and Xmax values from kinetic measurements.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%      
% This file is part of CurveFitting.
% 
% CurveFitting_MichaelisMenten is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% CurveFitting_MichaelisMenten is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CurveFitting_MichaelisMenten. If not, see http://www.gnu.org/licenses/.


function [x_fit, y_fit, x_axis_data, y_axis_data, error_data, Xlinlog_orig, Ylinlog_orig, parameters] = CurveFitting_MichaelisMenten(x_axis_data, y_axis_data, error_data, x_axis_unit, sample_no, minRegX, maxRegX, pointsRegX)

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
 
% Set up the range and the number of points
% used for plotting the regression curve
if isempty(minRegX)
    minRegX = -10;
end

if isempty(maxRegX)
    maxRegX = x_axis_data(end)*2
end

if isempty(pointsRegX)
    pointsRegX = (maxRegX - minRegX)*100
end

x_fit = linspace(minRegX, maxRegX, pointsRegX);
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
    Xmax_str = [char(Xmax), ' = ~ ', num2str(sprintf('%.3f',round(fit_result.Xmax, 3))), ' ', char(unit_Xmax)];
    text(fit_result.Kx*0.025, fit_result.Xmax*0.925, Xmax_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')
    
    K_str = [K, ' = ~ ', num2str(sprintf('%.3f',round(fit_result.Kx, 3))), ' ', char(x_axis_unit)];
    text(fit_result.Kx*1.025, fit_result.Xmax*0.05, K_str, 'FontName', 'Arial', 'fontsize', 12, 'FontWeight', 'Demi')
    
    % Write Rsq in the plot window
    rsquared_str = ['R^2 =  ',  num2str(sprintf('%.3f',round(gof.rsquare,3)))];
    text(max(x_axis_data)*1.15, fit_result.Xmax*1.1, rsquared_str, 'FontName', 'Arial', 'fontsize', 12)
end

switch quest_MM
    case 'Km and Vmax'
        K = 'Km';
        Xmax = 'Vmax';
    case 'Kd and Bmax'
        K = 'Kd';
        Xmax = 'Bmax';
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