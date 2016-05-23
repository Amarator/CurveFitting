% CurveFitting
% Easy to use tool for non-linear regression analyses and plotting.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%      
% This file is part of CurveFitting.
% 
% CurveFitting is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% CurveFitting is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CurveFitting. If not, see http://www.gnu.org/licenses/.


function varargout = CurveFitting(varargin)
% CurveFitting MATLAB code for CurveFitting.fig
%      CurveFitting, by itself, creates a new CurveFitting or raises the existing
%      singleton*.
%
%      H = CurveFitting returns the handle to a new CurveFitting or the handle to
%      the existing singleton*.
%
%      CurveFitting('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CurveFitting.M with the given input arguments.
%
%      CurveFitting('Property','Value',...) creates a new CurveFitting or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CurveFitting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CurveFitting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CurveFitting

% Last Modified by GUIDE v2.5 21-May-2016 06:31:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CurveFitting_OpeningFcn, ...
    'gui_OutputFcn',  @CurveFitting_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CurveFitting is made visible.
function CurveFitting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CurveFitting (see VARARGIN)

clc
clearvars -global

% Choose default command line output for CurveFitting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Default values
handles.mod_x = 0;
handles.mod_y = 0;

handles.my_marker = 'o';

handles.user_saved = true;

handles.advOptsFlag = 0;
handles.minRegressionX = [];
handles.maxRegressionX = [];
handles.pointsRegressionX = [];

guidata(hObject, handles)

% Default axis state
box off
set(gca, 'LineWidth', 1)
set(gca, 'TickLength', [0.02 0.02])
set(gca, 'TickDir','out');

% Default UI state
handlesArray = [handles.pushbutton_FitCurve, handles.popupmenu_TabForm, handles.popupmenu_FitType, handles.popupmenu_Marker, handles.pushbutton_save, handles.edit_minRegX, handles.edit_maxRegX, handles.edit_pointsReg];
set(handlesArray, 'Enable', 'off');

% UIWAIT makes CurveFitting wait for user response (see UIRESUME)
% uiwait(handles.figure2602);

% CHECK FOR UPDATES
% This program version
ThisVersion = '1.0';

% Get the latest version
[NewVersion,status] = urlread('https://raw.githubusercontent.com/s-bit/CurveFitting/master/CurrentVersion');

% Check if latest version is newer than this version
if status ~=0 && str2double(ThisVersion)<str2double(NewVersion)
    msg_h = msgbox('A newer version of CurveFitting is available! How to download:      "About" > "Download Update"', 'Update Notice');
    waitfor(msg_h)
end


% --- Outputs from this function are returned to the command line.
function varargout = CurveFitting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_LoadData.
function pushbutton_LoadData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[DataSourceName, DataSourcePath] = uigetfile({'*.xlsx'; '*.xls'}, 'Select File');

[status,sheets] = xlsfinfo([DataSourcePath DataSourceName]);
numOfSheets = numel(sheets);

% Check whether imported Excel file holds more than one Sheet - if yes, use
% first Sheet
if numOfSheets > 1
    handles.mySheet = char(sheets(1));
else
    handles.mySheet = 0;
end

myImportDoc = importdata([DataSourcePath DataSourceName]);
handles.myImportDoc = myImportDoc;

guidata(hObject, handles)

set(handles.popupmenu_TabForm, 'Enable', 'on');


% --- Executes on button press in pushbutton_FitCurve.
function pushbutton_FitCurve_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_OutputFig);

% Reset axis
cla reset

global x_axis_data
global y_axis_data
global error_data
global my_xlabels
global my_ylabels
global x_axis_unit
global my_ids

% Parameters for regression plot
if handles.advOptsFlag == 1
    minRegX = handles.minRegressionX;
    maxRegX = handles.maxRegressionX;
    pointsRegX = handles.pointsRegressionX;
else
    minRegX = [];
    maxRegX = [];
    pointsRegX = [];
end

fitOptions = handles.fitOptions;
hold on

data_size = size(x_axis_data);
sample_no = data_size(1);

param_count = 1;
for ii = 1:data_size(1)
    switch char(fitOptions)
        case 'Biphasic (experimental)'
            
        case 'Michaelis-Menten'
            [x_fit, y_fit, x_data, y_data, EB_data, Xlinlog_orig, Ylinlog_orig, fit_parameters] = CurveFitting_MichaelisMenten(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), x_axis_unit, sample_no, minRegX, maxRegX, pointsRegX);
        case 'Sigmoidal - IC50'
            [x_fit, y_fit, x_data, y_data, EB_data, Xlinlog_orig, Ylinlog_orig, fit_parameters] = CurveFitting_sigmoid(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), x_axis_unit, sample_no, minRegX, maxRegX, pointsRegX);
    end
    
    curve_plot(ii) = plot(x_fit, y_fit, 'Color', handles.my_LineColor(ii, :), 'Linewidth', 1.5, 'LineStyle', '-');
    
    if sum(error_data) == 0
        scatter(x_data, y_data, handles.my_marker, 'MarkerEdgeColor', handles.my_MarkerColor(ii, :))
    else
        errorbar(x_data, y_data, EB_data, handles.my_marker, 'MarkerSize', sqrt(35), 'MarkerEdgeColor', handles.my_MarkerColor(ii, :))
    end
    
    for jj = 1:(length(fit_parameters)/2)
        
        if sample_no > 1
            data_name = [char(my_ids(ii,:)), ' - ', char(fit_parameters(jj+jj-1))];
        else
            data_name = char(fit_parameters(jj+jj-1));
            
        end
        
        data_value = char(fit_parameters(jj*2));
        data_sum(param_count, :) = {data_name data_value};
        
        param_count = param_count + 1;
    end
    
    set(handles.uitable_Parameters, 'Data', data_sum)
    
end

% Format axis
box off
set(gca, 'Color', 'white')
set(gca, 'FontName', 'Arial');
set(gca, 'fontsize', 12);
set(gca, 'LineWidth', 1)
set(gca, 'TickLength', [0.02 0.002])
set(gca, 'TickDir','out');
xlabel(my_xlabels, 'FontSize', 14)
ylabel(my_ylabels, 'FontSize', 14)

% If more than one data set is plotted, insert legend in axis
if ~isempty(char(my_ids))
    legend(curve_plot, char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
end

handles.curve_plot = curve_plot;
handles.data_sum = data_sum;

% Get some info about axes properties
handles.Xlinlog_orig = Xlinlog_orig;

handles.Ylinlog_orig = Ylinlog_orig;

XTick_orig = get(gca, 'XTick');
handles.XTick_orig = XTick_orig;
handles.XTick_curr = XTick_orig;

YTick_orig = get(gca, 'YTick');
handles.YTick_orig = YTick_orig;
handles.YTick_curr = YTick_orig;

XLim_orig = get(gca, 'XLim');
handles.XLim_orig = XLim_orig;
handles.XLim_curr = XLim_orig;

YLim_orig = get(gca, 'YLim');
handles.YLim_orig = YLim_orig;
handles.YLim_curr = YLim_orig;
guidata(hObject, handles)


% --- Executes on selection change in popupmenu_TabForm.
function popupmenu_TabForm_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_TabForm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_TabForm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_TabForm
cla reset
clearvars -global

global x_axis_data
global y_axis_data
global error_data
global my_title
global my_xlabels
global my_ylabels
global x_axis_unit
global my_ids

sheet = handles.mySheet;

if sheet == 0
    myData = handles.myImportDoc.data;
    myTextData = handles.myImportDoc.textdata;
else
    myData = handles.myImportDoc.data.(sheet);
    myTextData = handles.myImportDoc.textdata.(sheet);
end

val = get(hObject, 'Value');
str = get(hObject, 'String');
TabForm = str(val);

data_size = size(myData);
text_size = size(myTextData);

warning('off','MATLAB:legend:PlotEmpty')
if text_size(1) > 2
    for ii = 1:(text_size(1)-1)
        my_ids(ii, :) = myTextData{ii+1, 1};
        legend(char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
        my_LineColor(ii,:) = uisetcolor([0 0 0], ['Line Color - ', my_ids(ii,:)]);
        my_MarkerColor(ii,:) = uisetcolor([1 0 0], ['Marker Color - ', my_ids(ii,:)]);
    end
else
    my_LineColor = uisetcolor([0 0 0], 'Choose Line Color');
    my_MarkerColor = uisetcolor([1 0 0], 'Choose Marker Color');   
end
warning('on','MATLAB:legend:PlotEmpty')

handles.my_LineColor = my_LineColor;
handles.my_MarkerColor = my_MarkerColor;

hold on
switch char(TabForm)
    case 'Rows'
        for ii = 1:(data_size(1)/3)
            x_axis_data(ii, :) = myData(ii+((ii-1)*2), :);
            y_axis_data(ii, :) = myData((ii+1)+((ii-1)*2), :);
            error_data(ii, :) = myData((ii+2)+((ii-1)*2), :);
            errorbar(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), 'LineStyle', '--', 'Color', handles.my_LineColor(ii, :), 'Marker', handles.my_marker, 'MarkerSize', sqrt(35), 'MarkerEdgeColor', handles.my_MarkerColor(ii, :))
        end
    case 'Columns'
        for ii = 1:(data_size(2)/3)
            x_axis_data(ii, :) = myData(:, ii+((ii-1)*2))';
            y_axis_data(ii, :) = myData(:, (ii+1)+((ii-1)*2))';
            error_data(ii, :) = myData(:, (ii+2)+((ii-1)*2))';
            errorbar(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), 'LineStyle', '--', 'Color', handles.my_LineColor(ii, :), 'Marker', handles.my_marker, 'MarkerSize', sqrt(35), 'MarkerEdgeColor', handles.my_MarkerColor(ii, :))
        end
end

my_title = myTextData{2, 2};
my_xlabels = myTextData{2, 3};
my_ylabels = myTextData{2, 4};
x_axis_unit = myTextData{2, 5};

box off
set(gca, 'Color', 'white')
set(gca, 'FontName', 'Arial');
set(gca, 'fontsize', 12);
set(gca, 'LineWidth', 1)
set(gca, 'TickLength', [0.02 0.02])
set(gca, 'TickDir','out');
xlabel(char(my_xlabels), 'FontSize', 14)
ylabel(char(my_ylabels), 'FontSize', 14)

if text_size(1) > 2
    for ii = 1:(text_size(1)-1)
        my_ids(ii, :) = myTextData{ii+1, 1};
        legend(char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
    end
end

% Get some info about axes properties
handles.Xlinlog_orig = 'lin';
handles.Ylinlog_orig = 'lin';

XTick_orig = get(gca, 'XTick');
handles.XTick_orig = XTick_orig;
handles.XTick_curr = XTick_orig;

YTick_orig = get(gca, 'YTick');
handles.YTick_orig = YTick_orig;
handles.YTick_curr = YTick_orig;

XLim_orig = get(gca, 'XLim');
handles.XLim_orig = XLim_orig;
handles.XLim_curr = XLim_orig;

YLim_orig = get(gca, 'YLim');
handles.YLim_orig = YLim_orig;
handles.YLim_curr = YLim_orig;

handles.user_saved = false;
guidata(hObject, handles)

handlesArray = [handles.popupmenu_FitType, handles.pushbutton_save];
set(handlesArray, 'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function popupmenu_TabForm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_TabForm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global my_title
global my_ids

% Choose save location
user_saved = false;
while user_saved == false
    save_dir = uigetdir('Curve Fitting - Select Save Location');
    if save_dir == 0
        quest_h = questdlg('Data has not been saved, yet! Really cancel?', 'Cancel? - Curve Fitting', 'No', 'Yes', 'No');
        waitfor(quest_h)
        if strcmp(quest_h, 'Yes') == 1
            return
        end
    else
        user_saved = true;
        handles.user_saved = user_saved;
        guidata(hObject, handles)
    end
end

waitbar_handle = waitbar(0, 'Saving Data...');

% Create new (invisible) figure and copy axes' content into the new figure
fig = figure('Visible', 'off');
ax = axes;
clf;
new_handle = copyobj(handles.axes_OutputFig, fig);
set(gca, 'ActivePositionProperty', 'outerposition')
set(gca, 'Units', 'normalized')
set(gca, 'OuterPosition', [0 0 1 1])
set(gca, 'position', [0.1300 0.1100 0.7750 0.8150])
curve_plot = handles.curve_plot;
title(my_title)
waitbar(1/5)

if ~isempty(char(my_ids))
%     legend(gca, char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
    
    %     legend(ax, char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
end

% Save figure as epsc, png, and fig at chosen location
whereToStore_vec = fullfile(save_dir,[['CurveFitting_' char(my_title) '_VectorGraphic'] '.epsc']);
print(fig, whereToStore_vec, '-depsc', '-painters')
waitbar(2/5)

whereToStore_png = fullfile(save_dir, [['CurveFitting_' char(my_title) '_PNG'], '.png']);
print(fig, whereToStore_png, '-dpng', '-r300')
waitbar(3/5)

whereToStore_txt = fullfile(save_dir, [['CurveFitting_' char(my_title) '_Parameters'], '.txt']);
loc_txt = fopen(whereToStore_txt, 'w');
if isempty(char(my_ids))
    fprintf(loc_txt, 'Parameter; Value\r\n');
else
    fprintf(loc_txt, 'Sample ID; Parameter; Value\r\n');
end
waitbar(4/5)

my_parameters = handles.data_sum;
for ii = 1:length(my_parameters)
    data_mkchar = [char(my_parameters(ii, 1)) '; ' char(my_parameters(ii, 2))];
    data_export_point = strrep(data_mkchar, ' -', '; ');
    data_export = strrep(data_export_point, '.', ',');
    fprintf(loc_txt, '%s\r\n', data_export);
end
fclose(loc_txt);
waitbar(5/5)
close(waitbar_handle)


function edit_yMax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yMax as text
%        str2double(get(hObject,'String')) returns contents of edit_yMax as a double

set_new_yMax = str2double(get(hObject,'String'));
X_lim = handles.XLim_curr;
Y_lim = handles.YLim_curr;

axis(gca, [X_lim(1) X_lim(2) Y_lim(1) set_new_yMax])
set(gca, 'YTickMode', 'auto');

handles.YTick_curr = get(gca, 'YTick');
handles.YLim_curr = get(gca, 'YLim');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit_yMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yMin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yMin as text
%        str2double(get(hObject,'String')) returns contents of edit_yMin as a double

set_new_yMin = str2double(get(hObject,'String'));
X_lim = handles.XLim_curr;
Y_lim = handles.YLim_curr;

axis(gca, [X_lim(1) X_lim(2) set_new_yMin Y_lim(2)])
set(gca, 'YTickMode', 'auto');

handles.YTick_curr = get(gca, 'YTick');
handles.YLim_curr = get(gca, 'YLim');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit_yMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xMax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xMax as text
%        str2double(get(hObject,'String')) returns contents of edit_xMax as a double

set_new_xMax = str2double(get(hObject,'String'));
X_lim = handles.XLim_curr;
Y_lim = handles.YLim_curr;

axis(gca, [X_lim(1) set_new_xMax Y_lim(1) Y_lim(2)])
set(gca, 'XTickMode', 'auto');

handles.XTick_curr = get(gca, 'XTick');
handles.XLim_curr = get(gca, 'XLim');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit_xMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_xMin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xMin as text
%        str2double(get(hObject,'String')) returns contents of edit_xMin as a double

set_new_xMin = str2double(get(hObject,'String'));
X_lim = handles.XLim_curr;
Y_lim = handles.YLim_curr;

axis(gca, [set_new_xMin X_lim(2) Y_lim(1) Y_lim(2)])
set(gca, 'XTickMode', 'auto');

handles.XTick_curr = get(gca, 'XTick');
handles.XLim_curr = get(gca, 'XLim');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit_xMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_linLogX.
function radiobutton_linLogX_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_linLogX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_linLogX

Xlinlog_state = get(hObject, 'Value');
Xlinlog_orig = handles.Xlinlog_orig;
XTick_curr = handles.XTick_curr;

if Xlinlog_state == 1
    switch char(Xlinlog_orig)
        case 'lin'
            set(gca, 'xscale', 'log');
            set(gca, 'XTickMode', 'auto');
        case 'log'
            set(gca, 'xscale', 'linear');
            set(gca, 'XTickMode', 'auto');
    end
    handles.mod_x = 1;
end

if Xlinlog_state == 0
    if handles.mod_x == 0
        switch char(Xlinlog_orig)
            case 'lin'
                set(gca, 'xscale', 'linear');
                set(gca, 'XTick', XTick_curr)
            case 'log'
                set(gca, 'xscale', 'log');
                set(gca, 'XTick', XTick_curr)
        end
    end
    if handles.mod_x == 1
        switch char(Xlinlog_orig)
            case 'lin'
                set(gca, 'xscale', 'linear');
                set(gca, 'XTickMode', 'auto');
            case 'log'
                set(gca, 'xscale', 'log');
                set(gca, 'XTickMode', 'auto');
        end
    end
end

handles.XTick_curr = get(gca, 'XTick');
handles.XLim_curr = get(gca, 'XLim');
guidata(hObject, handles)


% --- Executes on button press in radiobutton_linLogY.
function radiobutton_linLogY_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_linLogY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_linLogY

Ylinlog_state = get(hObject, 'Value');
Ylinlog_orig = handles.Ylinlog_orig;
YTick_curr = handles.YTick_curr;

if Ylinlog_state == 1
    switch char(Ylinlog_orig)
        case 'lin'
            set(gca, 'yscale', 'log');
            set(gca, 'YTickMode', 'auto');
        case 'log'
            set(gca, 'yscale', 'linear');
            set(gca, 'YTickMode', 'auto');
    end
    handles.mod_y = 1;
end

if Ylinlog_state == 0
    if handles.mod_y == 0
        switch char(Ylinlog_orig)
            case 'lin'
                set(gca, 'yscale', 'linear');
                set(gca, 'YTick', YTick_curr)
            case 'log'
                set(gca, 'yscale', 'log');
                set(gca, 'YTick', YTick_curr)
        end
    end
    if handles.mod_y == 1
        switch char(Ylinlog_orig)
            case 'lin'
                set(gca, 'yscale', 'linear');
                set(gca, 'YTickMode', 'auto');
            case 'log'
                set(gca, 'yscale', 'log');
                set(gca, 'YTickMode', 'auto');
        end
    end
end

handles.YTick_curr = get(gca, 'YTick');
handles.YLim_curr = get(gca, 'YLim');
guidata(hObject, handles)

% --- Executes on selection change in popupmenu_FitType.
function popupmenu_FitType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_FitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_FitType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_FitType

val = get(hObject, 'Value');
str = get(hObject, 'String');

handles.fitOptions = str(val);
guidata(hObject, handles)

handlesArray = [handles.popupmenu_Marker, handles.pushbutton_FitCurve];
set(handlesArray, 'Enable', 'on')


% --- Executes during object creation, after setting all properties.
function popupmenu_FitType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_FitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Menu_QM_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_QM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_QM_Info_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_QM_Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('ReadMe.txt')

% --------------------------------------------------------------------
function Menu_QM_Update_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_QM_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/s-bit/CurveFitting', '-browser')


% --- Executes on button press in pushbutton_revOriginal.
function pushbutton_revOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_revOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

X_lim = handles.XLim_orig;
Y_lim = handles.YLim_orig;
axis(gca, [X_lim(1) X_lim(2) Y_lim(1) Y_lim(2)])

Xlinlog_orig = handles.Xlinlog_orig;
Ylinlog_orig = handles.Ylinlog_orig;
switch char(Xlinlog_orig)
    case 'lin'
        set(gca, 'xscale', 'linear');
    case 'log'
        set(gca, 'xscale', 'log');
end

switch char(Ylinlog_orig)
    case 'lin'
        set(gca, 'yscale', 'linear');
    case 'log'
        set(gca, 'yscale', 'log');
end

XTick_orig = handles.XTick_orig;
YTick_orig = handles.YTick_orig;
set(gca, 'XTick', XTick_orig)
set(gca, 'YTick', YTick_orig)


% --- Executes on selection change in popupmenu_Marker.
function popupmenu_Marker_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_Marker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_Marker contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_Marker

val = get(hObject, 'Value');
str = get(hObject, 'String');
marker_input = str(val);

switch char(marker_input)
    case 'Asterisk'
        handles.my_marker = '*';
    case 'Circle'
        handles.my_marker = 'o';
    case 'Cross'
        handles.my_marker = 'x';
    case 'Diamond'
        handles.my_marker = 'd';
    case 'Plus sign'
        handles.my_marker = '+';
    case 'Point'
        handles.my_marker = '.';
    case 'Square'
        handles.my_marker = 's';
    case 'Star (5-pointed)'
        handles.my_marker = 'p';
    case 'Star (6-pointed)'
        handles.my_marker = 'h';
end

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_Marker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_Marker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton_grid.
function togglebutton_grid_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_grid
toggle_grid = get(hObject,'Value');
if toggle_grid == 1
    grid on
else
    grid off
end



% --- Executes when user attempts to close figure2602.
function figure2602_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure2602 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
user_saved = handles.user_saved;
if user_saved == false
    quest_h = questdlg('Data has not been saved, yet! Really quit?', 'Quit? - Curve Fitting', 'No', 'Yes', 'No');
    waitfor(quest_h)
    if strcmp(quest_h, 'Yes') == 1
        delete(hObject);
    end
else
    delete(hObject);
end




% --- Executes on button press in checkbox_advancedOpts.
function checkbox_advancedOpts_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_advancedOpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_advancedOpts

handlesArray = [handles.edit_minRegX, handles.edit_maxRegX, handles.edit_pointsReg];
if get(hObject, 'Value') == 1
   set(handlesArray, 'Enable', 'on')
   handles.advOptsFlag = 1;
else
    set(handlesArray, 'Enable', 'off')
    handles.advOptsFlag = 0;
end
guidata(hObject, handles)


function edit_minRegX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minRegX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minRegX as text
%        str2double(get(hObject,'String')) returns contents of edit_minRegX as a double

input_val = get(hObject, 'String');

if isempty(input_val)
    handles.minRegressionX = [];
    set(hObject,'String','Edit...')
else
    handles.minRegressionX = str2double(input_val);
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit_minRegX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minRegX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_maxRegX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxRegX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maxRegX as text
%        str2double(get(hObject,'String')) returns contents of edit_maxRegX as a double

input_val = get(hObject, 'String');

if isempty(input_val)
    handles.maxRegressionX = [];
    set(hObject,'String','Edit...')
else
    handles.maxRegressionX = str2double(input_val);
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit_maxRegX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxRegX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pointsReg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pointsReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pointsReg as text
%        str2double(get(hObject,'String')) returns contents of edit_pointsReg as a double
input_val = get(hObject, 'String');

if isempty(input_val)
    handles.pointsRegressionX = [];
    set(hObject,'String','Edit...')
else
    handles.pointsRegressionX = str2double(input_val);
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit_pointsReg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pointsReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Menu_QM_License_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_QM_License (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gpl_license_p1 = ...
    {'CurveFitting' ...
    'Toolbox for the non-linear regression analysis of experimental data.' ...
    '' ...
    'Copyright (C) 2016, Sven T. Bitters' ...
    'Contact: sven.bitters@gmail.com' ...
    ''};

gpl_license_p3 = ...
    {'-------------------------------------------------------------------' ...   
    '' ...
    'CurveFitting_sigmoid' ...
    'This is a script for plotting sigmoidal curves of best fit.' ...
    '' ...
    'Original script "sigmoid_curve_fitting.m" available at https://figshare.com/articles/Matlab_Script_for_fitting_sigmoidal_curves_to_infection_inhibition_data./97311' ...
    '' ...
    'Modified by Sven T. Bitters (21.3.2016)' ...
    '- Refactored code and improved usability for working with data' ...
    '  not related to infection inhibition' ...
    '- Revised IC50 determination method' ...
    '- Introduced dynamic determination of various aspects concerning' ... 
    '  plotting (e.g. ticks, axes lengths)' ...
    '' ...
    'Copyright (C) 2012, Peter Ghazal and Steven Watterson' ...
    'Released under CC-BY.' ...
    '' ...
    'The terms of the Creative Commons Attribution 4.0 International Public License can be found under http://creativecommons.org/licenses/by/4.0/.' ...
    };

GNU_GPL_License(gpl_license_p1, gpl_license_p3)
