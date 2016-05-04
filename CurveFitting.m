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

% Last Modified by GUIDE v2.5 29-Apr-2016 02:50:18

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
guidata(hObject, handles)

% Default axis state
box off
set(gca, 'LineWidth', 1)
set(gca, 'TickLength', [0.02 0.02])
set(gca, 'TickDir','out');

% Default UI state
handlesArray = [handles.pushbutton_FitCurve, handles.popupmenu_TabForm, handles.popupmenu_FitType, handles.popupmenu_Marker, handles.pushbutton_save];
set(handlesArray, 'Enable', 'off');

% UIWAIT makes CurveFitting wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% CHECK FOR UPDATES
% This program version
ThisVersion = '1.0';

% Get the latest version
[NewVersion,status] = urlread('https://raw.githubusercontent.com/Amarator/CurveFitting/master/CurrentVersion');

% Check if latest version is newer than this version
if status ~=0 && str2double(ThisVersion)<str2double(NewVersion)
    msg_h = msgbox('A newer version of CurveFitting is available.', 'Update Notice');
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

[DataSourceName, DataSourcePath] = uigetfile({'*.xls'; '*.xlsx'}, 'Select File');
handles.mydata = importdata([DataSourcePath DataSourceName]);
guidata(hObject, handles)

set(handles.popupmenu_TabForm, 'Enable', 'on');


% --- Executes on button press in pushbutton_FitCurve.
function pushbutton_FitCurve_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla reset

global x_axis_data
global y_axis_data
global error_data
global my_xlabels
global my_ylabels
global x_axis_unit
global my_ids

fitOptions = handles.fitOptions;
hold on

data_size = size(x_axis_data);
sample_no = data_size(1);

param_count = 1;
for ii = 1:data_size(1)
    switch char(fitOptions)
        case 'Biphasic (experimental)'
            
        case 'Michaelis-Menten'
            [x_fit, y_fit, x_data, y_data, EB_data, Xlinlog_orig, Ylinlog_orig, fit_parameters] = CurveFitting_MichaelisMenten(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), x_axis_unit, sample_no);
        case 'Sigmoidal - IC50'
            [x_fit, y_fit, x_data, y_data, EB_data, Xlinlog_orig, Ylinlog_orig, fit_parameters] = CurveFitting_sigmoid(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), x_axis_unit, sample_no);
    end
    
    curve_plot(ii) = plot(x_fit, y_fit, '-', 'Linewidth', 1.5);
    
    if sum(error_data) == 0
        scatter(x_data, y_data, marker)
    else
        errorbar(x_data, y_data, EB_data, handles.my_marker, 'MarkerSize', sqrt(35))
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

box off
set(gca, 'Color', 'white')
set(gca, 'FontName', 'Arial');
set(gca, 'fontsize', 12);
set(gca, 'LineWidth', 1)
set(gca, 'TickLength', [0.02 0.002])
set(gca, 'TickDir','out');
xlabel(my_xlabels, 'FontSize', 14)
ylabel(my_ylabels, 'FontSize', 14)

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

mydata = handles.mydata;

val = get(hObject, 'Value');
str = get(hObject, 'String');
TabForm = str(val);

data_size = size(mydata.data);
text_size = size(mydata.textdata);

hold on
switch char(TabForm)
    case 'Rows'
        for ii = 1:(data_size(1)/3)
            x_axis_data(ii, :) = mydata.data(ii+((ii-1)*2), :);
            y_axis_data(ii, :) = mydata.data((ii+1)+((ii-1)*2), :);
            error_data(ii, :) = mydata.data((ii+2)+((ii-1)*2), :);
            errorbar(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), '--o')
        end
    case 'Columns'
        for ii = 1:(data_size(2)/3)
            x_axis_data(ii, :) = mydata.data(:, ii+((ii-1)*2))';
            y_axis_data(ii, :) = mydata.data(:, (ii+1)+((ii-1)*2))';
            error_data(ii, :) = mydata.data(:, (ii+2)+((ii-1)*2))';
            errorbar(x_axis_data(ii,:), y_axis_data(ii,:), error_data(ii,:), '--o')
        end
end

my_title = mydata.textdata{2, 2};
my_xlabels = mydata.textdata{2, 3};
my_ylabels = mydata.textdata{2, 4};
x_axis_unit = mydata.textdata{2, 5};

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
        my_ids(ii, :) = mydata.textdata{ii+1, 1};
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
    save_dir = uigetdir('Desktop', 'Curve Fitting - Select Save Location');
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

% Create new (invisible) figure and copy axes' content into the new figure
GUI_fig_children = get(gcf, 'children');
Fig_Axes = findobj(GUI_fig_children, 'type', 'Axes');
fig = figure('Visible', 'off');
ax = axes;
clf;
new_handle = copyobj(Fig_Axes, fig);
set(gca, 'ActivePositionProperty', 'outerposition')
set(gca, 'Units', 'normalized')
set(gca, 'OuterPosition', [0 0 1 1])
set(gca, 'position', [0.1300 0.1100 0.7750 0.8150])
curve_plot = handles.curve_plot;
title(my_title)

char(my_ids)

if ~isempty(char(my_ids))
    legend(gca, char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')

%     legend(ax, char(my_ids), 'Location', 'northoutside', 'Orientation', 'horizontal')
end

my_parameters = handles.data_sum;

% Save figure as epsc, png, and fig at chosen location
whereToStore_vec = fullfile(save_dir,[['Curve_Fitting_VectorGraphic_' char(my_title)] '.epsc']);
print(fig, whereToStore_vec, '-depsc', '-painters')

whereToStore_png = fullfile(save_dir, [['Curve_Fitting_PNG_' char(my_title)], '.png']);
print(fig, whereToStore_png, '-dpng', '-r300')

whereToStore_txt = fullfile(save_dir, [['Curve_Fitting_Parameters_' char(my_title)], '.txt']);
loc_txt = fopen(whereToStore_txt, 'w');
if isempty(char(my_ids))
    fprintf(loc_txt, 'Parameter, Value\r\n');

else
    fprintf(loc_txt, 'Sample ID, Parameter, Value\r\n');
end
for ii = 1:length(my_parameters)
        data_mkchar = [char(my_parameters(ii, 1)) ', ' char(my_parameters(ii, 2))];
        data_export = strrep(data_mkchar, ' -', ', ');
        fprintf(loc_txt, '%s\r\n', data_export);
end
fclose(loc_txt);


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
web('https://github.com/Amarator/CurveFitting', '-browser')


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



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
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


