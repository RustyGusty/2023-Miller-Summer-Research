function varargout = imageanalysis(varargin)
% IMAGEANALYSIS M-file for imageanalysis.fig
%      IMAGEANALYSIS, by itself, creates a new IMAGEANALYSIS or raises the existing
%      singleton*.
%
%      H = IMAGEANALYSIS returns the handle to a new IMAGEANALYSIS or the
%      handle to
%      the existing singleton*.
%
%      IMAGEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEANALYSIS.M with the given input arguments.
%
%      IMAGEANALYSIS('Property','Value',...) creates a new IMAGEANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageanalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageanalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageanalysis

% Last Modified by GUIDE v2.5 10-May-2024 18:42:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageanalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @imageanalysis_OutputFcn, ...
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


% --- Executes just before imageanalysis is made visible.
function imageanalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command graph arguments to imageanalysis (see VARARGIN)

set(handles.contmin,'Enable','off');
set(handles.contmax,'Enable','off');
set(handles.contmax,'Max',uint16(65535));
set(handles.contmin,'Max',uint16(65535));
handles.contminimum = uint16(0);
handles.contmaximum = uint16(65535);
set(handles.axes1,'XTickLabel',[]);
set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTickLabel',[]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'Box','on');
set(handles.lineprofile,'Enable','off');
set(handles.radialaverage,'Enable','off');
set(handles.statistic,'Enable','off');
set(handles.yscale,'Enable','off');
handles.a = [];
handles.b = [];
set(handles.yscale,'String',[{'linear'} {'log'}]);
handles.path = ['c:\data\' datestr(date,10) '\' datestr(date,5) '\' datestr(date,5) datestr(date,7) datestr(date,11) '\'];

% Choose default command graph output for imageanalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageanalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command graph.
function varargout = imageanalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command graph output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.tif','Open file name',handles.path);
filename = [path file];
handles.path = path;

if isequal(file,0) || isequal(path,0)
    
else
    
    handles.image = imread(filename);
    precision = class(handles.image);

    switch precision
        case 'uint8'
            set(handles.contmax,'Max',uint16(255))
            set(handles.contmin,'Max',uint16(255))
            handles.contmaximum = uint16(255);
        otherwise
            set(handles.contmax,'Max',uint16(65535))
            set(handles.contmin,'Max',uint16(65535))
    end

    set(handles.axes1,'UserData',1)

    if get(handles.autoscale,'Value') == 1
        handles.contminimum = uint16(min(handles.image(:)));
        handles.contmaximum = uint16(max(handles.image(:)));
    else
        handles.contminimum = uint16(handles.contminimum);
        handles.contmaximum = uint16(handles.contmaximum);
    end

    set(handles.contmin,'Enable','on');
    set(handles.contmax,'Enable','on');
    set(handles.lineprofile,'Enable','on');
    set(handles.radialaverage,'Enable','on');
    set(handles.statistic,'Enable','on');

    set(handles.contmax,'Value',handles.contmaximum)
    set(handles.contmin,'Value',handles.contminimum)
    set(handles.maxnumstr,'String',num2str(handles.contmaximum,'%d'))
    set(handles.minnumstr,'String',num2str(handles.contminimum,'%d'))

    plotdiffraction(handles);
    set(handles.filenamelabel,'String',file);

    imsize = size(handles.image);
    if ~isempty(get(handles.lineprofile,'UserData'))
        mousecoord = get(handles.lineprofile,'UserData'); % Read mouse coordinate from UserData lineprofile
        if mousecoord(1) > imsize(2) || mousecoord(2) > imsize(2) || mousecoord(3) > imsize(1) || mousecoord(4) > imsize(1)
            smallimage = 'true';
        else
            smallimage = 'false';
        end
        if strcmp(smallimage,'true') == 1
            set(handles.lineprofile,'State','off');
            lineprofile_OffCallback(hObject,eventdata,guidata(hObject))
        else
            plotline(handles);
        end
    end

    if ~isempty(get(handles.radialaverage,'UserData'))
        if imsize == get(handles.autoplot,'UserData')
            plotradial(handles);
        else
            set(handles.radialaverage,'State','off')
            radialaverage_OffCallback(hObject,eventdata,guidata(hObject))
        end
    end

    if ~isempty(get(handles.statistic,'UserData'))
        mousecoord = get(handles.statistic,'UserData'); % Read mouse coordinate from UserData lineprofile
        if mousecoord(1) > imsize(2) || mousecoord(2) > imsize(2) || mousecoord(3) > imsize(1) || mousecoord(4) > imsize(1)
            smallimage = 'true';
        else
            smallimage = 'false';
        end
        if strcmp(smallimage,'true') == 1
            set(handles.statistic,'State','off');
            statistic_OffCallback(hObject,eventdata,guidata(hObject))
        else
            plotrectangle(handles);
        end
    end
    set(handles.autoplot,'UserData',imsize);
end

% set(handles.autoplot,'UserData',imsize);

guidata(hObject, handles);

% --------------------------------------------------------------------
function lineprofile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to lineprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function lineprofile_OnCallback(hObject, eventdata, handles)
% hObject    handle to lineprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.a handles.b handles.button] = ginputc(2,'LineWidth',1,'Color',[1 0 0],'ShowPoints',true,'ConnectPoints',true);

% if isfield(handles,'image') == 0
%     handles.image = get(handles.filenamelabel,'UserData');
%     child = get(get(handles.axes1,'Children'));
%     handles.image = child.CData;
% end

child = get(get(handles.axes1,'Children'));
handles.image = child.CData;

% plotdiffraction(handles);

handles = plotline(handles);

set(handles.yscale,'Enable','on');

guidata(hObject, handles);

% --------------------------------------------------------------------
function lineprofile_OffCallback(hObject, eventdata, handles)
% hObject    handle to lineprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.lineprofile,'UserData',[]);

hchildren = get(handles.axes1,'Children');

for i = 1:length(hchildren)
    if strcmp(get(hchildren(i),'Type'),'image') ~= 1
        delete(hchildren(i))
    end
end

set(handles.minplot,'String','');
set(handles.maxplot,'String','');

hplot = get(handles.axes2,'Children');
delete(hplot);

% --------------------------------------------------------------------
function radialaverage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to radialaverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function radialaverage_OnCallback(hObject, eventdata, handles)
% hObject    handle to radialaverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.a handles.b handles.button] = ginputc(3,'LineWidth',1,'Color',[1 0 0],'ShowPoints',true,'ConnectPoints',true);

plotdiffraction(handles);

handles = plotradial(handles);

if get(handles.autoplot,'Value')
    ymin = str2double(get(handles.minplot,'String'));
    ymax = str2double(get(handles.maxplot,'String'));
    set(handles.axes2,'Ylim',[ymin ymax])
end

set(handles.yscale,'Enable','on');

guidata(hObject, handles);


% --------------------------------------------------------------------
function radialaverage_OffCallback(hObject, eventdata, handles)
% hObject    handle to radialaverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.radialaverage,'UserData',[]);

hchildren = get(handles.axes1,'Children');

for i = 1:length(hchildren)
    if strcmp(get(hchildren(i),'Type'),'image') ~= 1
        delete(hchildren(i))
    end
end

set(handles.minplot,'String','');
set(handles.maxplot,'String','');

hplot = get(handles.axes2,'Children');
delete(hplot);

% --------------------------------------------------------------------
function statistic_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to statistic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function statistic_OnCallback(hObject, eventdata, handles)
% hObject    handle to statistic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.a handles.b handles.button] = ginputc(2,'LineWidth',1,'Color',[1 0 0],'ShowPoints',true,'ConnectPoints',true);

% if isfield(handles,'image') == 0
%     handles.image = get(handles.filenamelabel,'UserData');
% end

child = get(get(handles.axes1,'Children'));
handles.image = child.CData;

plotdiffraction(handles);

handles = plotrectangle(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function statistic_OffCallback(hObject, eventdata, handles)
% hObject    handle to statistic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.statistic,'UserData',[]);

hchildren = get(handles.axes1,'Children');

for i = 1:length(hchildren)
    if strcmp(get(hchildren(i),'Type'),'image') ~= 1
        delete(hchildren(i))
    end
end

set(handles.smin,'String','');
set(handles.smax,'String','');
set(handles.smean,'String','');
set(handles.sstd,'String','');

% --- Executes during object creation, after setting all properties.
function smin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function smax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function smean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sstd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sstd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function contmin_Callback(hObject, eventdata, handles)
% hObject    handle to contmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contmin as text
%        str2double(get(hObject,'String')) returns contents of contmin as a double

set(handles.autoscale,'Value',0)
handles.contmaximum = get(handles.contmax,'Value');
handles.contminimum = get(handles.contmin,'Value');

if handles.contminimum == 65535
    set(handles.contmin,'Value',uint16(65534));
end

if handles.contmaximum <= handles.contminimum
    set(handles.contmin,'Value',uint16(handles.contmaximum-1));
end

set(handles.minnumstr,'String',num2str(round(get(handles.contmin,'Value')),'%d'));

if isfield(handles,'image') == 0
    handles.image = get(handles.filenamelabel,'UserData');
end

plotdiffraction(handles);

if ~isempty(get(handles.lineprofile,'UserData'))
    plotline(handles);
end

if ~isempty(get(handles.radialaverage,'UserData'))
    plotradial(handles);
end

if ~isempty(get(handles.statistic,'UserData'))
    plotrectangle(handles);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function contmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function contmax_Callback(hObject, eventdata, handles)
% hObject    handle to contmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contmax as text
%        str2double(get(hObject,'String')) returns contents of contmax as a double

set(handles.autoscale,'Value',0)
handles.contmaximum = get(handles.contmax,'Value');
handles.contminimum = get(handles.contmin,'Value');

if handles.contmaximum == 0
    set(handles.contmax,'Value',uint16(1));
end

if handles.contminimum >= handles.contmaximum
    set(handles.contmax,'Value',uint16(handles.contminimum+1));
end

set(handles.maxnumstr,'String',num2str(round(get(handles.contmax,'Value')),'%d'));

if isfield(handles,'image') == 0
    handles.image = get(handles.filenamelabel,'UserData');
end

plotdiffraction(handles);

if ~isempty(get(handles.lineprofile,'UserData'))
    plotline(handles);
end

if ~isempty(get(handles.radialaverage,'UserData'))
    plotradial(handles);
end

if ~isempty(get(handles.statistic,'UserData'))
    plotrectangle(handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function contmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minnumstr_Callback(hObject, eventdata, handles)
% hObject    handle to minnumstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minnumstr as text
%        str2double(get(hObject,'String')) returns contents of minnumstr as a double

set(handles.autoscale,'Value',0)
minnum = str2double(get(handles.minnumstr,'String')) ;
maxnum = str2double(get(handles.maxnumstr,'String')) ;

if minnum < 0
    set(handles.minnumstr,'String','0')
elseif minnum > maxnum
    set(handles.minnumstr,'String',num2str(maxnum-1))
elseif minnum > 65534
    set(handles.minnumstr,'String','65534')
elseif isnan(minnum)
    set(handles.minnumstr,'String','0')
end

set(handles.contmin,'Value',str2double(get(handles.minnumstr,'String')));

if isfield(handles,'image') == 0
    handles.image = get(handles.filenamelabel,'UserData');
end

plotdiffraction(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minnumstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minnumstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxnumstr_Callback(hObject, eventdata, handles)
% hObject    handle to maxnumstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxnumstr as text
%        str2double(get(hObject,'String')) returns contents of maxnumstr as a double

set(handles.autoscale,'Value',0)
minnum = str2double(get(handles.minnumstr,'String')) ;
maxnum = str2double(get(handles.maxnumstr,'String')) ;

if maxnum > 65535
    set(handles.maxnumstr,'String','65535')
elseif maxnum < minnum
    set(handles.maxnumstr,'String',num2str(minnum+1))
elseif maxnum < 0
    set(handles.minnumstr,'String','1')
elseif isnan(maxnum)
    set(handles.maxnumstr,'String','65535')
end

set(handles.contmax,'Value',str2double(get(handles.maxnumstr,'String')));

if isfield(handles,'image') == 0
    handles.image = get(handles.filenamelabel,'UserData');
end

plotdiffraction(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxnumstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxnumstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in yscale.
function yscale_Callback(hObject, eventdata, handles)
% hObject    handle to yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns yscale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yscale

if get(handles.yscale,'Value') == 1
    set(handles.axes2,'YScale','linear') ;
elseif get(handles.yscale,'Value') == 2
    set(handles.axes2,'YScale','log') ;
end

guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function yscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoscale.
function autoscale_Callback(hObject, eventdata, handles)
% hObject    handle to autoscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoscale

if isfield(handles,'image') == 0
    handles.image = get(handles.filenamelabel,'UserData');
end

if get(handles.autoscale,'Value')
    handles.contminimum = uint16(min(handles.image(:)));
    handles.contmaximum = uint16(max(handles.image(:)));
else
    prelim = get(handles.autoscale,'UserData');
    handles.contminimum = prelim(1);
    handles.contmaximum = prelim(2);
end

set(handles.autoscale,'UserData',[handles.contminimum, handles.contmaximum]);

set(handles.contmax,'Value',round(handles.contmaximum));
set(handles.contmin,'Value',round(handles.contminimum));
set(handles.maxnumstr,'String',num2str(round(get(handles.contmax,'Value')),'%d'));
set(handles.minnumstr,'String',num2str(round(get(handles.contmin,'Value')),'%d'));

plotdiffraction(handles);
    
if ~isempty(get(handles.lineprofile,'UserData'))
    plotline(handles);
end
    
if ~isempty(get(handles.radialaverage,'UserData'))
    plotradial(handles);
end

if ~isempty(get(handles.statistic,'UserData'))
    plotrectangle(handles);
end


% --- Executes on button press in autoplot.
function autoplot_Callback(hObject, eventdata, handles)
% hObject    handle to autoplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoplot
if get(handles.autoplot,'Value')
    limmax = round(max(get(get(handles.axes2,'Children'),'YData')));
    limmin = round(min(get(get(handles.axes2,'Children'),'YData')));
    if limmin == limmax
        limmin = int16(linmin) - 1;
        limmax = int16(linmin) + 1;
    end
    set(handles.minplot,'String',num2str(limmin));
    set(handles.maxplot,'String',num2str(limmax));
    set(handles.axes2,'YLim',[limmin limmax]);
end

function maxplot_Callback(hObject, eventdata, handles)
% hObject    handle to maxplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxplot as text
%        str2double(get(hObject,'String')) returns contents of maxplot as a double

set(handles.autoplot,'Value',0);
ylim = round(get(handles.axes2,'YLim'));
set(handles.axes2,'YLim',[ylim(1) round(str2double(get(handles.maxplot,'String')))]);

% --- Executes during object creation, after setting all properties.
function maxplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minplot_Callback(hObject, eventdata, handles)
% hObject    handle to minplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minplot as text
%        str2double(get(hObject,'String')) returns contents of minplot as a double

set(handles.autoplot,'Value',0);
ylim = round(get(handles.axes2,'YLim'));
set(handles.axes2,'YLim',[round(str2double(get(handles.minplot,'String'))) ylim(2)]);


% --- Executes during object creation, after setting all properties.
function minplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on autoscale and none of its controls.
function autoscale_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to autoscale (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in grayscale.
function grayscale_Callback(hObject, eventdata, handles)
% hObject    handle to grayscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grayscale
if(get(hObject, 'Value'))
    colormap(gray);
else
    colormap(jet);
end

% --- Executes on key press with focus on grayscale and none of its controls.
function grayscale_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to grayscale (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in bgsubtract.
function bgsubtract_Callback(hObject, eventdata, handles)
% hObject    handle to bgsubtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bgsubtract