function varargout = picontrol(varargin)
% PICONTROL M-file for picontrol.fig
%      PICONTROL, by itself, creates a new PICONTROL or raises the existing
%      singleton*.
%
%      H = PICONTROL returns the handle to a new PICONTROL or the handle to
%      the existing singleton*.
%
%      PICONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PICONTROL.M with the given input arguments.
%
%      PICONTROL('Property','Value',...) creates a new PICONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before picontrol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to picontrol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help picontrol

% Last Modified by GUIDE v2.5 12-Jul-2011 15:44:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @picontrol_OpeningFcn, ...
                   'gui_OutputFcn',  @picontrol_OutputFcn, ...
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


% --- Executes just before picontrol is made visible.
function picontrol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to picontrol (see VARARGIN)

%createClassFromWsdl('http://server:8001/PIDelayStageWindowsService?wsdl') ;
handles.PIServer = PIDelayStageServiceProvider ;
GetStagePosition(handles.PIServer, 1) ;

%areAllStagesInitialized(handles.PIServer)
set(handles.directiond,'Enable','off') ;

posum = num2str(round(str2double(GetStagePosition(handles.PIServer,1))*1000)) ;
set(handles.positiond,'string',posum) ;

velums = num2str(round(str2double(GetStageVelocity(handles.PIServer,1))*1000)) ;
set(handles.velocd,'string',velums) ;

accelums2 = num2str(round(str2double(GetStageAcceleration(handles.PIServer,1))*1000)) ;
set(handles.acced,'string',accelums2) ;

% Choose default command line output for picontrol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes picontrol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = picontrol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function positiond_Callback(hObject, eventdata, handles)
% hObject    handle to positiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positiond as text
%        str2double(get(hObject,'String')) returns contents of positiond as a double


% --- Executes during object creation, after setting all properties.
function positiond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function targetd_Callback(hObject, eventdata, handles)
% hObject    handle to targetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetd as text
%        str2double(get(hObject,'String')) returns contents of targetd as a double


% --- Executes during object creation, after setting all properties.
function targetd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function velocd_Callback(hObject, eventdata, handles)
% hObject    handle to velocd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of velocd as text
%        str2double(get(hObject,'String')) returns contents of velocd as a double

velocity = str2double(get(handles.velocd,'String')) ;
minsetvel = 10 ;
maxsetvel = str2double(GetStageMaximumVelocity(handles.PIServer,1))*1000 ;
if velocity < minsetvel
    SetStageVelocity(handles.PIServer, 1, minsetvel/1000) ;
elseif velocity > maxsetvel
    SetStageVelocity(handles.PIServer, 1, maxsetvel/1000) ;
else
    SetStageVelocity(handles.PIServer, 1, num2str(velocity/1000)) ;
end

set(handles.velocd,'String',num2str(round(str2double(GetStageVelocity(handles.PIServer, 1))*1000))) ;

guidata(hObject,handles) ;

% --- Executes during object creation, after setting all properties.
function velocd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to velocd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function acced_Callback(hObject, eventdata, handles)
% hObject    handle to acced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acced as text
%        str2double(get(hObject,'String')) returns contents of acced as a double

acceleration = str2double(get(handles.acced,'String')) ;
minsetacce = 10 ;
maxsetacce = str2double(GetStageMaximumAcceleration(handles.PIServer,1))*1000 ;
if acceleration < minsetacce
    SetStageAcceleration(handles.PIServer, 1, minsetacce/1000) ;
elseif acceleration > maxsetacce
    SetStageAcceleration(handles.PIServer, 1, maxsetacce/1000) ;
else
    SetStageAcceleration(handles.PIServer, 1, num2str(acceleration/1000)) ;
end

set(handles.acced,'String',num2str(round(str2double(GetStageAcceleration(handles.PIServer, 1))*1000))) ;

guidata(hObject,handles) ;

% --- Executes during object creation, after setting all properties.
function acced_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function destinationd_Callback(hObject, eventdata, handles)
% hObject    handle to destinationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationd as text
%        str2double(get(hObject,'String')) returns contents of destinationd as a double


% --- Executes during object creation, after setting all properties.
function destinationd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in operationd.
function operationd_Callback(hObject, eventdata, handles)
% hObject    handle to operationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operationd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationd

if get(handles.operationd,'Value') == 1
    set(handles.directiond,'Enable','off') ;
else
    set(handles.directiond,'Enable','on') ;
end

guidata(hObject, handles) ;


% --- Executes during object creation, after setting all properties.
function operationd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in directiond.
function directiond_Callback(hObject, eventdata, handles)
% hObject    handle to directiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directiond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directiond


% --- Executes during object creation, after setting all properties.
function directiond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in god.
function god_Callback(hObject, eventdata, handles)
% hObject    handle to god (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.operationd,'Value') == 1
    set(handles.targetd,'String',get(handles.destinationd,'String')) ;
    target = str2double(get(handles.targetd,'String'))/1000 ;
    if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000
        errordlg('Target is beyond the limits', 'Error') ;
    else
    end
        MoveStageToAbsolutePosition(handles.PIServer,1,target) ;
        while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1
            pause(0.02) ;
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
        end
        set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
else
    if get(handles.directiond,'Value') == 1
        destination = str2double(GetStagePosition(handles.PIServer, 1))*1000 + str2double(get(handles.destinationd,'String')) ;
        set(handles.targetd,'String',num2str(round(destination))) ;
        target = str2double(get(handles.targetd,'String'))/1000 ;
        
        if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000
            errordlg('Target is beyond the limits', 'Error') ;
        else
        end
            relmov = str2double(get(handles.destinationd,'String'))/1000 ;
            MoveStageToRelativePosition(handles.PIServer, 1, relmov) ;
        
            while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1
                pause(0.02) ;
                set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
            end
        
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
    else
        destination = str2double(GetStagePosition(handles.PIServer, 1))*1000 - str2double(get(handles.destinationd,'String')) ;
        set(handles.targetd,'String',num2str(round(destination))) ;
        target = str2double(get(handles.targetd,'String'))/1000 ;
        
        if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000
            errordlg('Target is beyond the limits', 'Error') ;
        else
        end
            relmov = -1 * str2double(get(handles.destinationd,'String'))/1000 ;
            MoveStageToRelativePosition(handles.PIServer, 1, relmov) ;

            while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1
                pause(0.02) ;
                set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
            end
                    
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
    end
end

guidata(hObject, handles) ;

% --- Executes on button press in killd.
function killd_Callback(hObject, eventdata, handles)
% hObject    handle to killd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

StopStage(handles.PIServer, 1) ;

guidata(hObject, handles) ;

% --- Executes on button press in homed.
function homed_Callback(hObject, eventdata, handles)
% hObject    handle to homed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

homepos = (str2double(GetStageMaximumPosition(handles.PIServer, 1)) + str2double(GetStageMinimumPosition(handles.PIServer, 1)))/2 ;
set(handles.targetd,'String',num2str(round(homepos*1000))) ;
target = str2double(get(handles.targetd,'String'))/1000 ;
MoveStageToAbsolutePosition(handles.PIServer,1,target) ;
     while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1
         pause(0.02) ;
         set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;
     end
set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))) ;

guidata (hObject, handles) ;

% --- Executes on button press in resetd.
function resetd_Callback(hObject, eventdata, handles)
% hObject    handle to resetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InitializeAllStages(handles.PIServer) ;
pause(0.02)

posum = num2str(round(str2double(GetStagePosition(handles.PIServer,1))*1000)) ;
set(handles.positiond,'string',posum) ;

velums = num2str(round(str2double(GetStageVelocity(handles.PIServer,1))*1000)) ;
set(handles.velocd,'string',velums) ;

guidata(hObject, handles) ;
