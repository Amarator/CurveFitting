clc
close all
clear

% Measured data (y-axis values). Form: my_data = [1 2 3 4 5 ...]
%my_data = [0.008 0.018 0.024 0.044 0.135 0.471 1.248 2.306 5.572 13.203];
my_data = [0.005 0.014 0.065 0.137 0.349 1.484 3.150 9.726 24.759 21.426];
% my_data = [3.0 3.2 4.0 4.5 6.0 11.0 14.0 16.0 21.7 22.3 24.0 23.0 23.5 25.3 25.8 27.9 32.2 33.7 36.4 38.9 50.7 61.5 64.7 69.5 77.5 86.5 91 102 102];
%my_data = [0.01 0.02 0.02 0.04 0.14 0.47 1.25 2.31 5.57];
%my_data = [0.01 0.02 0.02 0.04 0.14 0.47 1.25 2.31];

% (Substrate) Concentration (x-axis values). Form: c_vals = [1 2 3 4 5 ...]
%c_vals = [0.05 0.1 0.15 0.45 1.485 4.9005 16.17165 53.366445 176.1092685 581.1605861];
c_vals = [0.05 0.15 0.45 1.35 4.05 12.15 36.45 109.35 328.05 984.15];
% c_vals = [1e-8 2.5e-8 5e-8 7.5e-8 1e-7 2.5e-7 5e-7 7.5e-7 1e-6 2e-6 3e-6 5e-6 7.5e-6 1e-5 2e-5 3e-5 5e-5 6e-5 7.5e-4 1e-4 2e-4 3e-4 4e-4 5e-4 6e-4 7.5e-4 1.5e-3 2e-3 3e-3];
%c_vals = [0.05 0.1 0.15 0.45 1.49 4.90 16.17 53.37];
%c_vals = [0.05 0.1 0.15 0.45 1.49 4.90 16.17 53.37 176.11];
%c_vals = [0.1 0.2 0.3 0.45 1.485 4.90 16.17 53.37 176.11];

% Error bars data. Form: EB_data = [1 2 3 4 5 ...]
EB_data = [0.002 0.001 0.017 0.013 0.027 0.156 0.268 2.071 0.398 0.584];
%EB_data = [0.001 0.001 0.004 0.006 0.004 0.017 0.145 0.670 0.336 9.647];

num_fits = 15;

ft = fittype('((V1 * x^n1)/(K1 + x^n1)) + ((V2 * x^n2)/(K2 + x^n2))', 'Independent', {'x'}, 'Coefficients', {'V1', 'n1', 'K1', 'V2', 'n2', 'K2'});


param_ID = num2hex(prod([prod(sum(num2hex(c_vals))) prod(sum(num2hex(my_data))) prod(sum(num2hex(EB_data))) prod(sum(num2hex(num_fits)))]));
save_location = param_ID;

found_data = false;
if exist(save_location, 'file') == 2
    fileID_save = fopen(save_location, 'r');
    
    ii = 1;
    tline = fgets(fileID_save);
    
    while ischar(tline)
        save_entry(ii) = cellstr(tline);
        
        ii = ii+1;
        tline = fgetl(fileID_save);
    end
    
    V1s = str2num(char(save_entry(1)));
    n1s = str2num(char(save_entry(2)));
    K1s = str2num(char(save_entry(3)));
    V2s = str2num(char(save_entry(4)));
    n2s = str2num(char(save_entry(5)));
    K2s = str2num(char(save_entry(6)));
    found_data = true;
end

[xDat_curve, yDat_curve] = prepareCurveData(c_vals, my_data);

if found_data == true
    foptions = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', [0 0 0 0 0 0], 'StartPoint', [V1s n1s K1s V2s n2s K2s], 'MaxFunEvals', 10000, 'MaxIter', 2000);
    [fit_result, gof] = fit(xDat_curve, yDat_curve, ft, foptions);
else
    foptions = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', [0 0 0 0 0 0], 'MaxFunEvals', 10000, 'MaxIter', 2000);
    
    warning('off', 'curvefit:fit:noStartPoint')
    
    fprintf('This may take several minutes. \n\n')
    fprintf('Curve fit in progress')
    
    gof_limit = 1;
    n = 1;
    counter_fit_results = 1;
    counter_gof = 1;
    tic
    while counter_fit_results ~= num_fits
        
        try
            [fit_result, gof] = fit(xDat_curve, yDat_curve, ft, foptions);
            
        catch
            continue
        end
        
        if (fit_result.V1 < fit_result.V2) && gof.rsquare > gof_limit ...
                && fit_result.V1 ~= 0 && fit_result.n1 ~= 0 && fit_result.K1 ~= 0 && fit_result.V2 ~= 0 && fit_result.n2 ~= 0 && fit_result.K2 ~= 0
            V1(counter_fit_results) = fit_result.V1;
            n1(counter_fit_results) = fit_result.n1;
            K1(counter_fit_results) = fit_result.K1;
            V2(counter_fit_results) = fit_result.V2;
            n2(counter_fit_results) = fit_result.n2;
            K2(counter_fit_results) = fit_result.K2;
            counter_fit_results = counter_fit_results + 1;            
            fprintf(',')
            
            counter_gof = 1;
        else
            fprintf('.')
        end
        
        counter_gof = counter_gof + 1;
        
        if counter_gof == 10
            gof_limit = gof_limit - 0.01;
            counter_gof = 1;
            fprintf(':')
        end
        
    end
    
    V1 = mean(V1(V1 < min(V1)*1.025));
    n1 = mean(n1(n1 < min(n1)*1.025));
    K1 = mean(K1(K1 < min(K1)*1.025));
    V2 = mean(V2(V2 < min(V2)*1.025));
    n2 = mean(n2(n2 < min(n2)*1.025));
    K2 = mean(K2(K2 < min(K2)*1.025));

    
    foptions = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', [0 0 0 0 0 0], 'StartPoint', [V1 n1 K1 V2 n2 K2], 'MaxFunEvals', 10000, 'MaxIter', 2000);
    [fit_result, gof] = fit(xDat_curve, yDat_curve, ft, foptions);
    
    fprintf('\n\n')
    fprintf(['Process completed in ' num2str(round(toc,2)) ' seconds.\n'])
    
    my_fileID = fopen(save_location, 'w');
    fprintf(my_fileID, '%f', V1);
    fprintf(my_fileID, '\n');
    fprintf(my_fileID, '%f', n1);
    fprintf(my_fileID, '\n');
    fprintf(my_fileID, '%f', K1);
    fprintf(my_fileID, '\n');
    fprintf(my_fileID, '%f', V2);
    fprintf(my_fileID, '\n');
    fprintf(my_fileID, '%f', n2);
    fprintf(my_fileID, '\n');
    fprintf(my_fileID, '%f', K2);
    fclose(my_fileID);
    
end


saturation = fit_result.V2 + fit_result.V1;
objective = @(value)fit_result(value) - saturation;
warning('off', 'all')

% for zerofinder = 0:(min(c_vals)/max(c_vals)):(100*max(c_vals))
%     saturation_pos = fzero(objective, zerofinder);
%     
%     if saturation_pos < 0
%         break
%     end
% 
% end

x_fit = linspace(min(c_vals)/100, 1, 1000000);

% Extract y-data from the fitting model for plotting
y_fit = ((fit_result.V1 * x_fit.^fit_result.n1)./(fit_result.K1 + x_fit.^fit_result.n1)) + ((fit_result.V2 * x_fit.^fit_result.n2)./(fit_result.K2 + x_fit.^fit_result.n2));
y_part1 = ((fit_result.V1 * x_fit.^fit_result.n1)./(fit_result.K1 + x_fit.^fit_result.n1));
y_part2 = ((fit_result.V2 * x_fit.^fit_result.n2)./(fit_result.K2 + x_fit.^fit_result.n2))+fit_result.V1;

hold on

% Plot both, the curve and the original data points
plot(x_fit, y_part1, '--b', 'Linewidth', 1)
plot(x_fit, y_part2, '--b', 'Linewidth', 1)
plot(x_fit, y_fit, '-r', 'Linewidth', 1)
% errorbar(c_vals, my_data, EB_data, '.k', 'MarkerSize', 20);
plot(c_vals, my_data, '.k', 'MarkerSize', 20);

% Write Rsq in the plot window
rsquared_str = ['R^2 =  ',  num2str(sprintf('%.3f',round(gof.rsquare,3)))];
text(0.015, 16, rsquared_str, 'FontName', 'Arial', 'fontsize', 12)

%============= Configuring the presentation of the figure =================
set(gca, 'FontName', 'Arial');
set(gca, 'fontsize', 12);

% Axes labels
xlabel('InsP_{6} [nM]', 'FontSize', 14)
ylabel('InsP_{6} per COI1 [pmol/µg]', 'FontSize', 14)

set(gca, 'LineWidth', 1.2)
set(gca, 'TickDir','out');
set(gca, 'TickLength', [0.015 0.0015])

% Create axes
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')
axis([0.00001 1 0 180])
set(gca,'xscale','log');

set(gca, 'YTick', 0:17)
set(gca, 'XMinorTick', 'on')
set(gca, 'YMinorTick', 'on')

set(gcf,'units','centimeters','position',[10,1.5,25,15])
warning('on', 'curvefit:fit:noStartPoint')