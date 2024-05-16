function varargout = motioncontrol_Daniel(varargin)
% MOTIONCONTROL M-file for motioncontrol.fig
%      MOTIONCONTROL, by itself, creates a new MOTIONCONTROL or raises the
%      existing
%      singleton*.
%
%      H = MOTIONCONTROL returns the handle to a new MOTIONCONTROL or the
%      handle to
%      the existing singleton*.
%
%      MOTIONCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTIONCONTROL.M with the given input arguments.
%
%      MOTIONCONTROL('Property','Value',...) creates a new MOTIONCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before motioncontrol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to motioncontrol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motioncontrol

% Last Modified by GUIDE v2.5 10-May-2024 17:04:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motioncontrol_OpeningFcn, ...
                   'gui_OutputFcn',  @motioncontrol_OutputFcn, ...
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


% --- Executes just before motioncontrol is made visible.
function motioncontrol_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to motioncontrol (see VARARGIN)

%%%% CCD camera Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.ccd = initccd(); % Run CCD camera init script

if (handles.ccd.IsConnected()) % Check if the connection was established
    set(handles.messages,'String','Connection to the server was successfully established!');
    [handles.cameraname,isOperationSuccessful, errorMessage] = handles.ccd.GetCameraName();
    if isempty(handles.cameraname)
        uiwait(warndlg('Camera is off','CCD Warning','modal'));
    else
        [isOperationSuccessful, errorMessage] = handles.ccd.SetExposureTime(1);  % Set the exposure time of the CCD
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end
        
        [exptime,isOperationSuccessful, errorMessage] = handles.ccd.GetExposureTime();  % Get the exposure time of the CCD (reconfirming the previous command worked O.K.
        if (~isOperationSuccessful)
        else
            set(handles.exposure,'String',num2str(exptime)); % Show exposure time value on screen
        end

        [isOperationSuccessful, errorMessage] = handles.ccd.SetExposureMode(1);
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        [logic,isOperationSuccessful, errorMessage] = handles.ccd.GetLogicOutput();
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        if logic ~= 1
            [isOperationSuccessful, errorMessage] = handles.ccd.SetLogicOutput(1);
            if (~isOperationSuccessful)
                set(handles.messages,'String',char(errorMessage));
            else
                [logic,isOperationSuccessful, errorMessage] = handles.ccd.GetLogicOutput();
                if (~isOperationSuccessful)
                    set(handles.messages,'String',char(errorMessage));
                else
                end
            end
        end

        [isOperationSuccessful, errorMessage] = handles.ccd.SetShutterMode(1); % Set shutter mode to open when triggered by the CCD SCAN output
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        [isOperationSuccessful, errorMessage] = handles.ccd.SetNumberOfStripesPerClean(1);
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        [currTempr,isOperationSuccessful, errorMessage] = handles.ccd.GetCurrentCCDTemperature(); % Get CCD temperature
        if (~isOperationSuccessful)
        else
            set(handles.actualtemp,'String',num2str(currTempr)); % Show temperature value on screen
        end

        [handles.fullwidth,handles.fullheight,isOperationSuccessful, errorMessage] = handles.ccd.GetCCDDimensions(); % Get the size of the CCD chip
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        else
            set(handles.messages,'String',['CCD dimensions: width = ' num2str(handles.fullwidth) ' x height = ' num2str(handles.fullheight)]);
        end

        [isOperationSuccessful, errorMessage] = handles.ccd.SetImageROI(handles.fullwidth,handles.fullheight,1); % Set the Image ROI to full chip
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        [width,height,binning,isOperationSuccessful, errorMessage] = handles.ccd.GetImageROI(); % Get the size of the ROI (reconfirming the previous command worked O.K.
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        else
            set(handles.width,'String',num2str(width)); % Show width value on screen
            set(handles.height,'String',num2str(height)); % Show height value on screen
            set(handles.binning,'String',num2str(binning)); % Show binning value on screen
        end

        [handles.maxtemp, isOperationSuccessful, errorMessage] = handles.ccd.GetMaximumCCDTargetTemperature; % Get the maximum temperature of the CCD
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end

        [handles.mintemp, isOperationSuccessful, errorMessage] = handles.ccd.GetMinimumCCDTargetTemperature; % Get the minimum temperature of the CCD
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end
    end
else
    set(handles.messages,'String','Failed to establish connection with the server!');
    uiwait(warndlg('Failed to establish connection with the server!','CCD Warning','modal'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Delay Stage Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.computeripdelaystage = '192.168.0.100'; % Set server computer IP or URL
createClassFromWsdl(['http://' handles.computeripdelaystage ':8001/PIDelayStageWindowsService?wsdl']);
handles.PIServer = PIDelayStageServiceProvider;

if str2double(NumberOfAttachedStages(handles.PIServer)) < 1
    uiwait(warndlg('No stages connected','Delay Stage Warning','modal'));
else
    GetStagePosition(handles.PIServer, 1);

    areAllStagesInitialized(handles.PIServer);
    set(handles.directiond,'Enable','off');

    posum = num2str(round(str2double(GetStagePosition(handles.PIServer,1))*1000));
    set(handles.positiond,'String',posum); % Show delay stage position on screen

    velums = num2str(round(str2double(GetStageVelocity(handles.PIServer,1))*1000));
    set(handles.velocd,'String',velums); % Show delay stage velocity on screen

    accelums2 = num2str(round(str2double(GetStageAcceleration(handles.PIServer,1))*1000));
    set(handles.acced,'String',accelums2); % Show delay stage acceleration on screen
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Shutters and NIDAQ Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.computeripshutter = '192.168.0.100'; % Set server computer IP or URL
createClassFromWsdl(['http://' handles.computeripshutter ':8003/VMMD3WindowsService?wsdl']);
handles.UniblitzServer = VMMD3ServiceProvider ;

% turning off manual control of shutter indicators, they will enable and
% disable automatically when they are toggled using the buttons in the
% toolbar
set(handles.shutterindic1, 'Enable', 'off');
set(handles.shutterindic2, 'Enable', 'off');

% NO LONGER USING DAQ
% handles.computeripNIDAQ = '192.168.0.100'; % Set server computer IP or URL
% handles.portni = 29000; % Set server port
% msg = {'GETVERSION'};

% [handles.answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg); % Send the commands
% answerinit = strrep(strrep(char(handles.answer),char(13),''),char(10),'');

% if strcmp(answerinit,'NIDAQ Server not running or network problem') == 1
%     uiwait(warndlg(answerinit,'NIDAQ Warning','modal'));
%     handles.NIDAQ = 0;
% else
%     msg = {'GETDEV'};
%     [handles.answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni);
%     handles.devname = strtok(char(handles.answer),[char(10) char(13)]);
%     
%     if ~isempty(handles.devname)
%         handles.NIDAQ = 1; 
%         msg = {['CHECKTR ' handles.devname(end)]};
%         [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
%         
%             if strcmp(strtok(char(handles.answer),[char(10) char(13)]),'NO_TRIGGER') == 1
%                 uiwait(warndlg('No Trigger for photodiodes','Trigger Warning','modal'));
%                 set(handles.trigger,'Enable','off');
%                 handles.triggeron = 0;
%             else
%                 set(handles.trigger,'Enable','on');
%                 handles.triggeron = 1;
%             end
%         
%     else
%         uiwait(errordlg('Device is no longer present in the system.','NIDAQ error','modal'));
%         set(handles.irvisuv,'value',1)
%         set(handles.irvisuv,'enable','off')
%         handles.NIDAQ = 0;
%     end
% 
% end


if strcmp('true',IsControllerAccessible(handles.UniblitzServer))
    [isOperationSuccessful,errorMessage] = CloseShutter(handles.UniblitzServer,1); %Close shutter 1
    % error dialog box if the shutter closing was unsuccessful
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 1 unable to close. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    end
    [isOperationSuccessful,errorMessage] = CloseShutter(handles.UniblitzServer,2); %Close shutter 2
    % error dialog box if the shutter closing was unsuccessful
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 2 unable to close. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    end
else
    uiwait(warndlg('Uniblitz controller inaccessible', 'Shutter Warning', 'modal'))
    set(handles.openshutter1,'Enable','off')
    set(handles.closeshutter1,'Enable','off')
    set(handles.openshutter2,'Enable','off')
    set(handles.closeshutter2,'Enable','off')    
end

% NO LONGER CHECKING THE STATUS OF SHUTTERS
% if ~isempty(answer)
%     checkstatus_Callback([], [], handles)% Check status of shutters
% end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%% PP-30 Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DISABLING VERTICAL SAMPLE CONTROL
set(handles.directionv,'Enable','off');  % Disable direction control
set(handles.directionh,'Enable','off');  % Disable direction control
handles.computerip30 = '192.168.0.100'; % Set server computer IP or URL
handles.port30 = 25000; % Set server port

set(handles.goh,'Enable','off');
set(handles.killh,'Enable','off');
set(handles.homeh,'Enable','off');
set(handles.reseth,'Enable','off');
set(handles.gov,'Enable','off');
set(handles.killv,'Enable','off');
set(handles.homev,'Enable','off');
set(handles.resetv,'Enable','off');

% msg = {'NUMBEROFDEVICES'}; % Creates a command to check number of plugged motors
% [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg); % Check number of plugged motors
% 
% if str2double(answer) == 0
%     handles.numberpp30 = str2double(char(answer));
%     uiwait(warndlg('No PP-30 connected','PP-30 Warning','modal'));
%     msg = {'QUIT'}; % Creates a command to quit the server communication
%     [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); %Quit the communication
% 
% elseif str2double(answer) <= 2 && str2double(answer) >= 1
%     handles.handarray = [];
%     handles.numberpp30 = str2double(answer);
%     for i = 1:handles.numberpp30 % Loop for the number of motors
%         msg = {['OPEN ' num2str(i)]}; % Open communication with motors
%         [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Send the commands
%         hand = answer{1};
%         handles.handarray = [handles.handarray; hand(1:end-2)]; % Generates an array of handles of the motors
%     end
% 
%     sarray = size(handles.handarray);
%     if sarray(1) == 1
%         harray = handles.handarray;
%         msg = {['SENDRCV ' harray ' DN']}; % Creates a command to get serial numbers
%         [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Send the commands
%         serialno = char(answer);
%         if strcmp(regexprep(serialno,'\r\n',''),'EX01') == 1
%             uiwait(warndlg('Just the horizontal stage is connected','PP-30 Warning','modal'));
%         else
%             uiwait(warndlg('Just the vertical stage is connected','PP-30 Warning','modal'));
%         end
%     end
% 
%     
%     for i = 1:handles.numberpp30 % Loop for the number of motors
%         msg = {['SENDRCV ' handles.handarray(i,:) ' DN']}; % Creates a command to get serial numbers
%         [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Send the commands
%         serialno = char(answer);
%         
%         command1 = ['SENDRCV ' handles.handarray(i,:) ' HSPD=2000']; % Creates a command to set max velocity to 2000 counts/s
%         command2 = ['SENDRCV ' handles.handarray(i,:) ' ACC=300']; % Creates a command to set acceleration to 300 counts/s^2
%         command3 = ['SENDRCV ' handles.handarray(i,:) ' SL=1']; % Creates a command to set StepNloop (close loop) configuration
%         command4 = ['SENDRCV ' handles.handarray(i,:) ' SLA=100']; % Creates a command to set maximum number of attempts
%         if strcmp(regexprep(serialno,'\r\n',''),'EX01') == 1
%             command5 = ['SENDRCV ' handles.handarray(i,:) ' SLR=28.604']; % Creates a command to set StepNloop ratio (taken from calibration program)
%         else
%             command5 = ['SENDRCV ' handles.handarray(i,:) ' SLR=35.480']; % Creates a command to set StepNloop ratio (taken from calibration program)
%         end
%         command6 = ['SENDRCV ' handles.handarray(i,:) ' SLT=20']; % Creates a command to set the maximum tolerance (difference between target and final position)
%         command7 = ['SENDRCV ' handles.handarray(i,:) ' SLE=20000']; % Creates a command to set the maximum error. Beyond that not correction is attempted
%         command8 = ['SENDRCV ' handles.handarray(i,:) ' POL=530']; % Creates a command to set polarity (see manual)
%         command9 = ['SENDRCV ' handles.handarray(i,:) ' HSPD']; % Creates a command to read maximum velocity
%         command10 = ['SENDRCV ' handles.handarray(i,:) ' ACC']; % Creates a command to read acceleration
%         command11 = ['SENDRCV ' handles.handarray(i,:) ' EX']; % Creates a command to read position
% 
%         msg = {command1,command2,command3,command4,command5,command6,command7,command8,command9,command10,command11}; % Concatenates the command
%         [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Send the commands
% 
%         if strcmp(regexprep(serialno,'\r\n',''),'EX01') == 1
%             velum = num2str(str2double(answer{9})/20,'%5.0f'); % Convert answer{10} to um/s and assign to velnum
%             set(handles.veloch,'String',velum); % Set velocity in panel
% 
%             accelum = num2str(str2double(answer{10})/20,'%5.0f'); % Convert answer{11} to um/s^2 and assign to accelnum
%             set(handles.acceh,'String',accelum); % Set acceleration in panel
% 
%             posum = num2str(str2double(answer{11})/20,'%5.0f'); % Convert answer{12} to um and assign to posum
%             set(handles.positionh,'String',posum); % Set horizontal position in panel
%             set(handles.scanstarth,'String',posum); % Set horizontal start scan position in panel
%             set(handles.scansteph,'String','1'); % Set horizontal step size in panel
%             set(handles.nsteph,'String','1'); % Set number of horizontal steps in panel
%             set(handles.goh,'Enable','on');
%             set(handles.killh,'Enable','on');
%             set(handles.homeh,'Enable','on');
%             set(handles.reseth,'Enable','on');
% 
%         else
%             velum = num2str(str2double(answer{9})/20,'%5.0f'); % Convert answer{10} to um/s and assign to velnum
%             set(handles.velocv,'String',velum); % Set velocity in panel
% 
%             accelum = num2str(str2double(answer{10})/20,'%5.0f'); % Convert answer{11} to um/s^2 and assign to accelnum
%             set(handles.accev,'String',accelum); % Set acceleration in panel
% 
%             posum = num2str(str2double(answer{11})/20,'%5.0f'); % Convert answer{12} to um and assign to posum
%             set(handles.positionv,'String',posum); % Set vertical position in panel
%             set(handles.scanstartv,'String',posum); % Set vertical start scan position in panel
%             set(handles.scanstepv,'String','1'); % Set vertical step size in panel
%             set(handles.nstepv,'String','1'); % Set number of vertical steps in panel
%             set(handles.gov,'Enable','on');
%             set(handles.killv,'Enable','on');
%             set(handles.homev,'Enable','on');
%             set(handles.resetv,'Enable','on');
%         end
% 
%     end
%         
% else
%         uiwait(warndlg(char(answer),'PP-30 Warning','modal'));
%         handles.numberpp30 = 0;
% end
%     
% set(handles.numberscans,'String','1'); % Set number of scans in panel 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%% RS-40 Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISABLING ANGLE CONTROL
set(handles.directiona,'Enable','off');  % Disable direction control
handles.computerip40 = '192.168.0.100'; % Set server computer IP or URL
handles.port40 = 26000; % Set server port
handles.commport = '8';
numberofmotors = 1;
handles.axis = '1';
handles.limitangle = 5; % Max limit angle
set(handles.goa,'Enable','off');
set(handles.killa,'Enable','off');
set(handles.homea,'Enable','off');
set(handles.reseta,'Enable','off');
handles.numberrs40 = 0;

% msg = {['INIT ' handles.commport ' ' num2str(numberofmotors)]}; % Creates a command to initialize
% [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg); % Send the command
% answerinit = strrep(strrep(char(answer),char(13),''),char(10),'');
% 
% if strcmp(answerinit,'Server not running or network problem') == 1
%     uiwait(warndlg(answerinit,'RS-40 Warning','modal'));
% elseif strcmp(answerinit,'Initialized successfully') == 1
%     msg = {'OPEN'}; % Creates a command to open communication
%     [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Open communication
%     answeropen = strrep(strrep(char(answer),char(13),''),char(10),'');
% 
%     if isempty(answeropen)
%         uiwait(warndlg('RS-40 not connected','RS-40 Warning','modal'));
%         msg = {'QUIT'}; % Creates a command to quit the server communication
%         [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); %Quit the communication
%     elseif strcmp(answeropen,'Unable to open controller!')
%         uiwait(warndlg(answeropen,'RS-40 Warning','modal'));
%         msg = {'QUIT'}; % Creates a command to quit the server communication
%         [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); %Quit the communication
%     else
%         for i = 1:numberofmotors % Loop for the number of motors
%             msg = {['EXECUTE ' num2str(i) ' getserialno']}; % Creates a command to read motor id String
%             [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Read motor id String
%             pause(0.5)
%             [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Read motor id String
%         end
% 
%         command1 = 'SETVEL 1 7.0'; % Creates a command to set max velocity to 10 mm/s
%         command2 = 'SETACCEL 1 3.0'; % Creates a command to set acceleration to 3 mm/s^2
%         command3 = 'GETVEL 1'; % Creates a command to read maximum velocity
%         command4 = 'GETACCEL 1'; % Creates a command to read acceleration
%         command5 = 'GETPOS 1'; % Creates a command to read positin
% 
%         msg = {command1,command2,command3,command4,command5}; % Concatenates the command
%         [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Send the commands
% 
%         velum = regexprep(answer{3},'\n',''); % Convert answer{3} to um/s and assign to velnum
%         set(handles.veloca,'string',velum); % Set velocity in panel
% 
%         accelum = regexprep(answer{4},'\n',''); % Convert answer{4} to um/s^2 and assign to accelnum
%         set(handles.accea,'string',accelum); % Set acceleration in panel
% 
%         posum = answer{5}; % Convert answer{5} to um and assign to posum
%         set(handles.positiona,'String',posum); % Set position in panel
% 
%         set(handles.goa,'Enable','on');
%         set(handles.killa,'Enable','on');
%         set(handles.homea,'Enable','on');
%         set(handles.reseta,'Enable','on');
%         handles.numberrs40 = 1;
%     end
% else
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%% Firefly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% clear FireFlyCameraClientLib
% asm = NET.addAssembly('C:\Users\lphys\Documents\MATLAB\Firefly\FireFlyCameraClientLib.dll');
% l = import('FireFlyCameraClientLib.*');
% 
% handles.ffClient = FireFlyCameraClientLib.FireFlyCameraClient();
% methods(handles.ffClient);
% 
% handles.ffClient.IsConnected();
% if (~handles.ffClient.IsConnected())
%     [isOperationSuccessful,errorMessage] = handles.ffClient.Connect();
% end
% [numCams,isOperationSuccessful,errorMessage] = handles.ffClient.GetNumberOfCameras();
% [cams,isOperationSuccessful,errorMessage] = handles.ffClient.GetListOfAvailableCameras();
% 
% numCams = cams.GetLength(0);
% handles.camNames = cell(1,numCams);
% for i=0:numCams-1
%     handles.camNames{i+1} = char(cams.Get(i));
% end
% if numCams == 1
%     set(handles.fireflysel,'Enable','off')
% else
%     set(handles.fireflysel,'Enable','on')
% end
% handles.camera = char(handles.camNames(1));
% 
% handles.image = zeros(480,640,'int32');
% axes(handles.firefly);
% handles.plot = imshow(handles.image,[0 100]);
% 
% guidata(hObject, handles);
% 
% handles.tmr2 = timer('TimerFcn',{@TmrFcn2,handles},'BusyMode','Queue','ExecutionMode','FixedRate','Period',1); % Create a timer to constantly update firefly image
% start(handles.tmr2); % Start the timer of firefly update
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.imageanalysis = imageanalysis; % Open another window (imageanalysis) and get its handle
handles.previmg = 'None'; % Store previous image to show change

handles.guifig = gcf;
handles.tmr = timer('TimerFcn',{@TmrFcn,handles.guifig},'BusyMode','Queue','ExecutionMode','FixedRate','Period',10); % Create a timer to constantly update the temperature of the CCD
guidata(handles.guifig,handles);
start(handles.tmr); % Start the timer of temperature update

set(gcf,'CloseRequestFcn',{@exitmenu_Callback,handles}); % Change the default value of internal function CloseRequestFcn to call exit_Callback function.
%In this way when user close the windows pressing the X in the top
%right corner, the program first disconnect the server.

handles.path = ['c:\data\' datestr(date,10) '\' datestr(date,5) '\' datestr(date,5) datestr(date,7) datestr(date,11) '\']; % Set the path as "c:\data\yyyy\mm\mmddyy\"
handles.run = ['Run' get(handles.runnum, 'String') '\'];
handles.root = [datestr(date,5) datestr(date,7) datestr(date,11)]; % Set the root name of the image files as "mmddyy"
handles.filenumber = []; % Initialize to empty the filenumber array
%handles.imagesize = [{num2str(handles.fullwidth)} , {num2str(handles.fullheight)}] ; 
handles.imageisbg = 0;

set(handles.newlogent,'Enable','off'); % Disable new log entry button
set(handles.takeimage,'Enable','on'); % Enable take image button
set(handles.width,'Enable','off'); % Disable width textbox
set(handles.height,'Enable','off'); % Disable height textbox
set(handles.scanstarth,'Enable','off'); % Disable scan start horizontal textbox
set(handles.scansteph,'Enable','off'); % Disable scan step size horizontal textbox
set(handles.nsteph,'Enable','off'); % Disable scan number of steps horizontal textbox
set(handles.scanstartv,'Enable','off'); % Disable scan start vertical textbox
set(handles.scanstepv,'Enable','off'); % Disable scan step size vertical textbox
set(handles.nstepv,'Enable','off'); % Disable scan number of steps textbox
set(handles.scanstartd,'Enable','on'); % Enab;e scan start delay textbox
set(handles.scanstepd,'Enable','on'); % Enable scan step size delay textbox
set(handles.nstepd,'Enable','on'); % Enable scan number of steps delay textbox
set(handles.numberscans,'Enable','off'); % Disable number of scans textbox
set(handles.goscan,'Enable','on'); % Enable go button textbox
set(handles.abortscan,'Enable','off'); % Disable abort button textbox
set(handles.regionsel,'Enable','off'); % Disable selection of ROI popup menu
set(handles.roi,'Enable','off'); % Disable ROI radio button
set(handles.fullchip,'Enable','off'); % Disable fullchip radio button
set(handles.slidertable,'Visible','off'); % Make table slider invisible
set(handles.numberscans, 'Enable', 'on'); % Enable number of scans dialogue

if( not(isnumeric(get(handles.numberscans, 'String'))) )
    set(handles.numberscans, 'String', 1);
    set(handles.scanstartd, 'String', 0);
    set(handles.scanstepd, 'String', 1000);
    set(handles.nstepd, 'String', 5);
end

set(handles.scannum, 'String', '1');

% For use in goscan_Callback
handles.fields_to_toggle = [
        handles.width, handles.height ...
        handles.fullchip, handles.roi ...
        handles.regionsel ... 
        handles.god handles.killd handles.homed handles.resetd ... 
        handles.numberscans ... 
        handles.scanstartd handles.scanstepd handles.nstepd ... 
        handles.beforeim handles.afterim ... 
        handles.goscan ... 
        handles.savingpath handles.autosave ... 
        handles.rootname handles.imagename handles.binning ... 
        handles.exposure ... 
        handles.takeimage handles. takebg ... 
        handles.closeshutter1 handles.openshutter1 ... 
        handles.closeshutter2 handles.openshutter2 ... 
        ];
enable_fields(handles);
set(handles.abortscan, 'Value', 0);

handles.children = get(handles.imageanalysis,'Children'); % Get the handles of the elements of the window imageanalysis
for i = 1:numel(handles.children)
    handles.axes1 = handles.children(i);
    if strcmp('axis1',get(handles.children(i),'Tag')) == 1
        break % Just keep the handles of the axis1, where the diffraction pattern will be shown
    end
end

hchildren = handles.children;

for i = 1:numel(hchildren) % Create handles for all elements of the window imageanalysis
    temp = get(hchildren(i),'Tag');
    if( not(isempty(temp)) )
        eval(['handles.' temp ' = hchildren(' num2str(i) ') ;']);
    end
end

htoolbarim = get(handles.uitoolbar1,'Children');

for j = 1:numel(htoolbarim) % Create handles for all elements of the toolbar
    temp2 = get(htoolbarim(j),'Tag');
    eval(['handles.' temp2 ' = htoolbarim(' num2str(j) ') ;']);
end

hchildrenstatpanel = get(handles.statpanel,'Children');

for m = 1:numel(hchildrenstatpanel)
    temp3 = get(hchildrenstatpanel(m),'Tag');
    eval(['handles.' temp3 ' = hchildrenstatpanel(' num2str(m) ') ;']);
end

hchildrenprogresspanel = get(handles.progresspanel, 'Children');
for m = 1:numel(hchildrenprogresspanel)
    temp4 = get(hchildrenprogresspanel(m),'Tag');
    eval(['handles.' temp4 ' = hchildrenstatpanel(' num2str(m) ') ;']);
end

% Disable UserData from bgsubtract when not scanning
set(handles.bgsubtract, 'UserData', NaN);
% Disable the bgsubtract button while no background is loaded
set(handles.bgsubtract, 'Enable', 'off');
set(handles.bgsubtract, 'Value', 0);
% Hide the progress boxes in imageanalysis (NOTE: THIS IS NEVER SHOWN, JUST
% FOR USERDATA ORGANIZATION)
set(handles.progresspanel, 'Visible', 'off');
set(handles.pumpontxt, 'UserData', NaN);
set(handles.pumpofftxt, 'UserData', NaN);

%handles.idle = 1; % Set idle to 1. It is use in the TmrFcn to updat
handles.directoryroi = 'C:\Users\lphys\Documents\MATLAB\experimentclient\'; % Set the directory to look for the ROI file
fidroi = fopen([handles.directoryroi 'rois.txt']); % Open ROI file
roiinfo = textscan(fidroi,'%s%s%s','delimiter','\t'); % Read ROI file
fclose(fidroi); % Close ROI file
handles.selString = {}; % Set selection String to empty
handles.selString = [handles.selString ; {roiinfo{1} roiinfo{2} roiinfo{3}}]; % Fill selection String
set(handles.regionsel,'String',[roiinfo{1} ; ' ']); % Set values of ROIs in the popup menu
%clc;

set(handles.contrast,'Value',120);

set(handles.text1,'string',['Position (' char(181) 'm)'])
set(handles.text2,'string',['Target (' char(181) 'm)'])
set(handles.text4,'string',['Destination (' char(181) 'm)'])
set(handles.text5,'string',['Velocity (' char(181) 'm/s)'])
set(handles.text6,'string',['Acceleration (' char(181) 'm/s' char(178) ')'])

set(handles.text7,'string',['Position (' char(181) 'm)'])
set(handles.text8,'string',['Target (' char(181) 'm)'])
set(handles.text49,'string',['Destination (' char(181) 'm)'])
set(handles.text11,'string',['Velocity (' char(181) 'm/s)'])
set(handles.text12,'string',['Acceleration (' char(181) 'm/s' char(178) ')'])

set(handles.text13,'string',['Position (' char(181) 'm)'])
set(handles.text14,'string',['Target (' char(181) 'm)'])
set(handles.text16,'string',['Destination (' char(181) 'm)'])
set(handles.text17,'string',['Velocity (' char(181) 'm/s)'])
set(handles.text18,'string',['Acceleration (' char(181) 'm/s' char(178) ')'])

set(handles.text37,'string','Angle (deg)')
set(handles.text38,'string','Target (deg)')
set(handles.text40,'string','Destination (deg)')
set(handles.text41,'string','Velocity (deg/s)')
set(handles.text42,'string',['Acceleration (deg/s' char(178) ')'])

% Choose default command line output for motioncontrol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes motioncontrol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = motioncontrol_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%% Start Toolbar  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % --------------------------------------------------------------------
function newlog_ClickedCallback(hObject, ~, handles)
% hObject    handle to newlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.path = ['c:\data\' datestr(date,10) '\' datestr(date,5) '\' datestr(date,5) datestr(date,7) datestr(date,11) '\']; % Set the path as "c:\data\yyyy\mm\mmddyy\"
handles.run = 'Run1';
handles.root = [datestr(date,5) datestr(date,7) datestr(date,11)]; % Set the root name of the image files as "mmddyy"
handles.filenumber = []; % Initialize to empty the filenumber array
[status,results] = system(['dir ' handles.path]); % Check if the directory for the present day exist
if status == 1 % If it doesn't exist
    system(['md ' handles.path]); % Create the directory
    handles.filelog = fopen([handles.path handles.root '.log'],'w'); % Create a new log file
    fclose(handles.filelog); % Close the new log file
    set(handles.savingpath,'String',handles.path); % Show log file path (and data path) on screen
    set(handles.runnum, 'String', '1'); % Show run number on screen
    set(handles.rootname,'String',handles.root); % Show root name of the image files on screen
    set(handles.imagename,'String','1'); % Show root name of the image files on screen
    set(handles.newlogent,'Enable','on'); % Enable new log entry button
    if ~isempty(handles.cameraname)
        set(handles.takeimage,'Enable','on'); % Enable take image button
        set(handles.scanstarth,'Enable','on'); % Enable scan start horizontal textbox
        set(handles.scansteph,'Enable','on'); % Enable scan step size horizontal textbox
        set(handles.nsteph,'Enable','on'); % Enable scan number of steps horizontal textbox
        set(handles.scanstartv,'Enable','on'); % Enable scan start vertical textbox
        set(handles.scanstepv,'Enable','on'); % Enable scan step size vertical textbox
        set(handles.nstepv,'Enable','on'); % Enable scan number of steps textbox
        set(handles.scanstartd,'Enable','on'); % Enable scan start delay textbox
        set(handles.scanstepd,'Enable','on'); % Enable scan step size delay textbox
        set(handles.nstepd,'Enable','on'); % Enable scan number of steps delay textbox
        set(handles.numberscans,'Enable','on'); % Enable number of scans textbox
        set(handles.goscan,'Enable','on'); % Enable go button textbox
        set(handles.abortscan,'Enable','on'); % Enable abort button textbox
        set(handles.roi,'Enable','on'); % Enable ROI radio button
        set(handles.fullchip,'Enable','on'); % Enable fullchip radio button
    end
    set(handles.positiond,'String',num2str(str2double(GetStagePosition(handles.PIServer, 1))*1000)); % Show delay stage position on screen
else % If it exist it warns you about it
    warndlg('Today''s log already exist, please go to open log menu or press open log button', 'Filename error')
end
set(handles.logtable,'data',[]); % Clear log table
set(handles.logtable,'Userdata',[]); % Clear log table
guidata(hObject, handles);

% --------------------------------------------------------------------
function openlog_ClickedCallback(hObject, ~, handles)
% hObject    handle to openlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[datalog,file,handles.path] = openlog; % Call function to open log
if ~isempty(datalog) % If log is not empty
    lastim = str2double(char(datalog{end,1})); % Read the number of the last image
    newim = lastim + 1; % Add one
    set(handles.imagename,'String',num2str(newim)); % Show the number of the next image
else % If log is empty
    set(handles.imagename,'String','1'); % Show the number of the next image to one
end

sizelog = size(datalog);
if sizelog(1) > 10
    set(handles.slidertable,'Visible','on')
    if sizelog(1) == 11
        set(handles.slidertable,'SliderStep',[1 0.1])
    else
        set(handles.slidertable,'SliderStep',[10/(ceil(sizelog(1)/10)*10-10) 0.1])
    end
    set(handles.logtable,'data',datalog(end-9:end,:));
else
    set(handles.logtable,'data',datalog);
end

if file ~= 0
    set(handles.newlogent,'Enable','on'); % Enable new log entry button
    if ~isempty(handles.cameraname)
        set(handles.takeimage,'Enable','on'); % Enable take image button
        set(handles.scanstarth,'Enable','on'); % Enable scan start horizontal textbox
        set(handles.scansteph,'Enable','on'); % Enable scan step size horizontal textbox
        set(handles.nsteph,'Enable','on'); % Enable scan number of steps horizontal textbox
        set(handles.scanstartv,'Enable','on'); % Enable scan start vertical textbox
        set(handles.scanstepv,'Enable','on'); % Enable scan step size vertical textbox
        set(handles.nstepv,'Enable','on'); % Enable scan number of steps textbox
        set(handles.scanstartd,'Enable','on'); % Enable scan start delay textbox
        set(handles.scanstepd,'Enable','on'); % Enable scan step size delay textbox
        set(handles.nstepd,'Enable','on'); % Enable scan number of steps delay textbox
        set(handles.numberscans,'Enable','on'); % Enable number of scans textbox
        set(handles.goscan,'Enable','on'); % Enable go button textbox
        set(handles.abortscan,'Enable','on'); % Enable abort button textbox
        set(handles.roi,'Enable','on'); % Enable ROI radio button
        set(handles.fullchip,'Enable','on'); % Enable fullchip radio button
    end
    handles.root = file(1:end-4); % Set handles.root to the filename without extension
    set(handles.savingpath,'String',handles.path); % Show path on screen
    set(handles.rootname,'String',handles.root); % Show filename without extension on screen
    i = 1;
    while( exist([handles.path 'run' num2str(i) '\'], 'dir') )
        i = i + 1;
    end
    set(handles.runnum, 'String', num2str(i));
    handles.run = ['Run' num2str(i) '\'];
end

set(handles.logtable,'UserData',datalog);

guidata(hObject, handles);

% % --------------------------------------------------------------------
function newlogent_ClickedCallback(hObject, ~, handles)
% hObject    handle to newlogent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datalog = get(handles.logtable,'UserData'); % Read datalog from table
if isempty(datalog) % If empty set empty Strings
    datalog = {'', '', '', '', '', '', '', '', '', ''} ;
end
if strcmp('',datalog(end,1)) == 1; % If last row and first column of the table is empty, set number to 1
   number = num2str(1) ;
else % If not empty, set number to last number + 1
   number = num2str(str2double(char(datalog(end,1))) + 1) ;
end
horizontal = get(handles.positionh,'String'); % Show horizontal position of the sample on the table
vertical = get(handles.positionv,'String'); % Show vertical position of the sample on the table
stage = get(handles.positiond,'String'); % Show delay stage position on the table
current = ' '; % Show current to empty String
exposure = get(handles.exposure,'String'); % Show expusore time on the table
image = ' '; % Show image name to empty String
pump = ' '; % Show pump power to empty String
probe = ' '; % Show probe power to empty String
notes = ' '; % Show notes to empty String

newline = {number horizontal vertical stage current exposure image pump probe notes}; % Set newline with the values defined above
datalog = [datalog ; newline]; % Set datalog to the previous datalog and concatenate new values

sizelog = size(datalog); % Size of the data log

if sizelog(1) > 10 % If number of rows is greater than 10, show the slider
    set(handles.slidertable,'Visible','on') % Show the slider
    if sizelog(1) == 11 % Change the step of the slider
        set(handles.slidertable,'SliderStep',[1 0.1]) % Step set to 1
    else
        set(handles.slidertable,'SliderStep',[10/(ceil(sizelog(1)/10)*10-10) 0.1]) % Step set proportionally to the number of rows
    end
    set(handles.logtable,'data',datalog(end-9:end,:)); % Show last 10 rows
else
    set(handles.logtable,'data',datalog); % Show all rows
end

set(handles.logtable,'UserData',datalog);

handles.filelog = fopen([handles.path handles.root '.log'],'a'); % Open log file to append
fprintf(handles.filelog,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',number, horizontal, vertical, stage, current, exposure, image, pump, probe, notes); % Write log
fclose(handles.filelog); % Close log file

guidata(hObject, handles) ;

% % --------------------------------------------------------------------
function curimg = takeimage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to takeimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curimg = NaN;
handles.runnumber = get(handles.runnum, 'String'); % Read run number from sscreen
handles.filenumber = get(handles.imagename,'String'); % Read number of image from screen
handles.scannumber = get(handles.scannum, 'String'); % Read scan number from screen
set(handles.filename_posd, 'String', um_to_fs(get(handles.positiond, 'String'), 2));

j = 0;
if handles.ccd.IsAcquisitionRunning() == 1 % Check if ccd acquisition is running
    pause(0.5)

    % NO LONGER USING DAQ TO TRIGGER CCD CAMERA A SPECIFIED NUMBER OF TIMES
    % LOOP STUFF AFTER THAT LOOKS LIKE IT JUST OBTAINS PRUMP AND PROBE
    % POWERS FROM DAQ   
%     nloops = num2str(uint16(str2double(get(handles.exposure,'String'))*40));
%     msg = {['TRIGGERCCD ' handles.devname(end) ' 01 ' nloops ' ' num2str(handles.triggeron)]}; % Create a message to trigger ccd
%     NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
% 
%     if (strcmp(get(handles.trigger,'Enable'),'on') == 1) && (strcmp(get(handles.trigger,'State'),'on') == 1)
%         pause(uint16(str2double(get(handles.exposure,'String'))))
%         msg = {'READ'}; % 
%         [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
%         k = 0;
%         power = char(answer);
%         while isempty(power) == 1 && k < 100
%             [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
%             power = char(answer);
%             k = k + 1;
%         end
%         [pump sprobe] = strtok(answer{1});
%         probe = strtok(sprobe);
%     else
%         pump = 'NaN';
%         probe = 'NaN';
%     end
%     
%     checkstatus_Callback([], [], handles)% Check status of shutters (uses
%     DAQ)
%     taking one image at the beginning, we throw this one out because the
%     first image from the camera is bad.
    [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout(); % Check if image is ready to be read
    while ready == 0 && j < 100 % If it is not ready, wait
        pause(0.1);
        tempMessage = cat(2, 'Checking whether camera is ready for image readout; Attempt ', num2str(j));
        set(handles.messages,'String', tempMessage);  
        j = j + 1;
        [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout();
    end
    
    [image,isOperationSuccessful,errorMessage] = handles.ccd.GetImageFromCamera(); % Read image from ccd server buffer
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
        set(handles.messages,'String','Getting Image...');
        pause(2.)
    end
    
    j = 0;
    [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout(); % Check if image is ready to be read
    while ready == 0 && j < 100 % If it is not ready, wait
        pause(0.1);
        tempMessage = cat(2, 'Checking whether camera is ready for image readout; Attempt ', num2str(j));
        set(handles.messages,'String', tempMessage);  
        j = j + 1;
        [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout();
    end
    
    closeshutter2_ClickedCallback([],[],handles);
 
    [image,isOperationSuccessful,errorMessage] = handles.ccd.GetImageFromCamera(); % Read image from ccd server buffer
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
        set(handles.messages,'String','Getting Image...');
        pause(2.)
    end

else % If ccd acquisition is not running
    stop(handles.tmr); % Stop the timer of temperature update
    [isOperationSuccessful,errorMessage] = handles.ccd.StartAcquisition(); % Start ccd acquisition
    set(handles.settemp,'Enable','off')
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
        pause(0.5)

        % % TRIGGERING CCD THROUGH DAQ, COMMENTING THIS OUT
        % nloops = num2str(uint16(str2double(get(handles.exposure,'String'))*40));
        % msg = {['TRIGGERCCD ' handles.devname(end) ' 01 ' nloops ' ' num2str(handles.triggeron)]}; % Create a message to trigger ccd
        % NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
        % 
        % if (strcmp(get(handles.trigger,'Enable'),'on') == 1) && (strcmp(get(handles.trigger,'State'),'on') == 1)
        %     pause(uint16(str2double(get(handles.exposure,'String'))))
        %     msg = {'READ'}; %
        %     [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
        %     k = 0;
        %     power = char(answer);
        %     while isempty(power) == 1 && k < 100
        %         [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
        %         power = char(answer);
        %         k = k + 1;
        %     end
        %     [pump sprobe] = strtok(answer{1});
        %     probe = strtok(sprobe);
        % else
        %     pump = 'NaN';
        %     probe = 'NaN';
        % end
        
        % no longer checking status through daq
%         checkstatus_Callback([], [], handles)% Check status of shutters
        
        [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout(); % Check if image is ready to be read
        while ready == 0 && j < 100 % If it is not ready, wait
            pause(0.1);
            tempMessage = cat(2, 'Checking whether camera is ready for image readout; Attempt ', num2str(j));
            set(handles.messages,'String', tempMessage);  
            j = j + 1;
            [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout();
        end

        [image,isOperationSuccessful,errorMessage] = handles.ccd.GetImageFromCamera(); % Read image from ccd server buffer
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        else
            set(handles.messages,'String','Getting Image...');
            pause(2.)
        end

        j = 0;

        [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout(); % Check if image is ready to be read
        while ready == 0 && j < 100 % If it is not ready, wait
            pause(0.1);
            tempMessage = cat(2, 'Checking whether camera is ready for image readout; Attempt ', num2str(j));
            set(handles.messages,'String', tempMessage);  
            j = j + 1;
            [ready,isOperationSuccessful,errorMessage] = handles.ccd.IsImageAvailableForReadout();
        end
        
        % no longer checking status through daq
        % checkstatus_Callback([], [], handles)% Check status of shutters
    
        closeshutter2_ClickedCallback([],[],handles);

        [image,isOperationSuccessful,errorMessage] = handles.ccd.GetImageFromCamera(); % Read image from ccd server buffer
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
            return;
        else
            set(handles.messages,'String','Getting Image...');
        end
        [isOperationSuccessful,errorMessage] = handles.ccd.StopAcquisition(); % Stop ccd acquisition
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
            return;
        else
            start(handles.tmr); % Start the timer of temperature update
            set(handles.settemp,'Enable','on')
        end
    end
end

handles.image = image.uint16; % Save image from buffer to handles.image
curimg = handles.image;
set(handles.filenamelabel,'UserData',handles.image); % Save image in UserData of filenamelabel


set(handles.contmin,'Enable','on'); % Enable min control in imageanalysis window
set(handles.contmax,'Enable','on'); % Enable max control in imageanalysis window
set(handles.lineprofile,'Enable','on'); % Enable lineprofile button control in imageanalysis window
set(handles.radialaverage,'Enable','on'); % Enable radial average button control in imageanalysis window
set(handles.statistic,'Enable','on'); % Enable statistic button control in imageanalysis window

% Skip plotting here in case this is the scan routine
if not(get(handles.goscan, 'Value'))
    plotdiffraction(handles); % Go to plotdiffraction routine
end
set(handles.messages,'String','Waiting...');

imsize = size(handles.image);

if ~isempty(get(handles.lineprofile,'UserData')) % If lineprofile graph is not empty
    mousecoord = get(handles.lineprofile,'UserData'); % Read mouse coordinate from UserData lineprofile
    if mousecoord(1) > imsize(2) || mousecoord(2) > imsize(2) || mousecoord(3) > imsize(1) || mousecoord(4) > imsize(1)
        smallimage = 'true';
    else
        smallimage = 'false';
    end
    if strcmp(smallimage,'true') == 1
        set(handles.lineprofile,'State','off');
        imageanalysis('lineprofile_OffCallback',hObject,eventdata,guidata(hObject))
    else
        handles.a = [mousecoord(1) mousecoord(2)];
        handles.b = [mousecoord(3) mousecoord(4)];
        plotline(handles); % Plot line profile
    end
end

if ~isempty(get(handles.radialaverage,'UserData')) % If radial average graph is not empty
    if imsize == get(handles.autoplot,'UserData')
        mousecoord = get(handles.radialaverage,'UserData'); % Read mouse coordinate from UserData radialaverage
        handles.a = [mousecoord(1) mousecoord(2)];
        handles.b = [mousecoord(3) mousecoord(4)];
        plotradial(handles); % Plot radial average
    else
        set(handles.radialaverage,'State','off');
        imageanalysis('radialaverage_OffCallback',hObject,eventdata,guidata(hObject))
    end
end

if ~isempty(get(handles.statistic,'UserData')) % If statistics is not empty
    mousecoord = get(handles.statistic,'UserData'); % Read mouse coordinate from UserData statistic
    if mousecoord(1) > imsize(2) || mousecoord(2) > imsize(2) || mousecoord(3) > imsize(1) || mousecoord(4) > imsize(1)
        smallimage = 'true';
    else
        smallimage = 'false';
    end
        
    if strcmp(smallimage,'true') == 1
        set(handles.statistic,'State','off');
        imageanalysis('statistic_OffCallback',hObject,eventdata,guidata(hObject))
    else
    handles.a = [mousecoord(1) mousecoord(2)];
    handles.b = [mousecoord(3) mousecoord(4)];
    plotrectangle(handles); % Plot rectangle
    end
end

set(handles.autoplot,'UserData',imsize);

if isequal(get(handles.autosave,'Value'),0) % If autoset is not tick
    set(handles.filenamelabel, 'String', 'temp'); % Set filename to temp
else % If autosave is tick
    [status,results] = system(['dir ' handles.path]); % Check if directory exist
    if status == 1 % If it doesn't exist
        system(['md ' handles.path]); % Create directory
    else
    end
    
    handles.path = get(handles.savingpath,'String'); % Read path from screen
    
    if isempty(handles.filenumber) % If filename was not set
        warndlg('Please type a proper filename', 'Filename error') % Warning dialog
    else

        handle.filenumber = get(handles.imagename,'String'); % Read image number from screen

        datalog = get(handles.logtable,'UserData');
        if isempty(datalog); % If log table is empty
            number = num2str(1); % Set number of file to 1
        else % If it is not empty
            number = num2str(str2double(char(datalog(end,1))) + 1); % Set number to previous number + 1
        end
      
        horizontal = get(handles.positionh,'String'); % Show horizontal position of the sample on the table
        vertical = get(handles.positionv,'String'); % Show vertical position of the sample on the table
        stage = get(handles.positiond,'String'); % Show delay stage position on the table
        true_time = um_to_fs(str2double(stage));
        time = num2str(round(true_time, 2));
        
        current = ' '; % Show current on the table
        exposure = get(handles.exposure,'String'); % Show exposure time on the table
        if(handles.imageisbg) % Show image name
            image = [handles.root '_' handles.filenumber '.tif'];  % If bg, don't include DS
        else
            image = [handles.root '_' time '_' handles.filenumber '.tif']; % If not BG, include time
        end
        notes = ' '; % Show notes to empty String
        
        set(handles.filenamelabel, 'String', image); % Show image name on screen

        
        newline = {number horizontal num2str(true_time) stage current exposure image notes}; % Set newline with the values defined above
        description = sprintf('Number: %s\tUnused: %s\tTime: %s\tStage: %s\tCurrent: %s\tExposure: %s\tImage: %s\tNotes: %s\r\n',number,horizontal, num2str(true_time),stage,current,exposure,image,notes);
        if ( get(handles.goscan, 'Value') ) 
            if( not(exist([handles.path handles.run handles.scannumber '\' time '\'], 'dir')) )
                system(['mkdir ' handles.path handles.run '1\' time]);
                system(['mkdir ' handles.path handles.run '2\' time]);
            end
            imgfilename = [handles.path handles.run handles.scannumber '\' time '\' ...
                handles.root '_' time '_' handles.filenumber '.tif'];
        elseif ( handles.imageisbg ) % If this is a background image
            exposure = get(handles.exposure, 'String');
            nacq = get(handles.numberscans, 'String');
            imgfilename = [handles.path 'bg_exp' exposure 's_nacq' nacq '\' handles.root '_' handles.filenumber '.tif'];
        else
            imgfilename = [handles.path handles.root '_' time '_' handles.filenumber '.tif'];
        end
        imwrite(uint16(handles.image),imgfilename,'Description',description); % Write image in harddrive
        datalog = [datalog ; newline]; % Set datalog to the previous datalog and concatenate new values

        sizelog = size(datalog);
        if sizelog(1) > 10
            set(handles.slidertable,'Visible','on')
            if sizelog(1) == 11
                set(handles.slidertable,'SliderStep',[1 0.1])
            else
                set(handles.slidertable,'SliderStep',[10/(ceil(sizelog(1)/10)*10-10) 0.1])
            end
            set(handles.logtable,'data',datalog(end-9:end,:));
        else
            set(handles.logtable,'data',datalog);
        end
        set(handles.slidertable,'Value',0)

        handles.filenumber = num2str(str2double(handles.filenumber)+1); % Increase the filenumber
        handles.scannumber = num2str(mod(str2double(handles.scannumber), 2) + 1); % Toggle scannumber between 1 and 2
        set(handles.imagename,'String',handles.filenumber); % Show new number on screen
        set(handles.scannum, 'String', handles.scannumber); % Show new number on screen
        handles.filelog = fopen([handles.path handles.root '.log'],'a'); % Open log file to append
        fprintf(handles.filelog,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',number, horizontal, time, stage, current, exposure, image, notes); % Write log
        fclose(handles.filelog); % Close log file
        set(handles.logtable,'UserData',datalog);
    end
end

guidata(hObject, handles);

function takebg_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to takebg (see GCBO)

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if( not(get(handles.autosave, 'Value')) )
    uiwait(errordlg('Please toggle autosave', 'Autosave Needed', 'modal'));
    return;
end

handles.imageisbg = 1;
exposure = get(handles.exposure, 'String');
nacq = get(handles.numberscans, 'String');
path = [handles.path 'bg_exp' exposure 's_nacq' nacq];
if (exist(path, 'dir')) % If the background image already exists
    uiwait(errordlg(['Background image with these settings already exists! Delete ' ...
        path ' to retake the background'],'Image Exists','modal'));
else
    disable_fields(handles);
    system(['mkdir ' path]);
    nscans = str2double(nacq);
    for i = 1:nscans
        if (abortcheck(handles))
            break;
        end;
        set(handles.messages, 'String', ['Taking image ' num2str(i) ' of ' num2str(nscans)]);
        takeimage_ClickedCallback(hObject, eventdata, handles);
    end
    
    enable_fields(handles);
    set(handles.abortscan, 'Enable', 'off');
    
    if(abortcheck(handles))
        set(handles.messages, 'String', 'Aborted. Deleting directory');
        set(handles.abortscan, 'Value', 0);
        
        system(['del ' path '\*.tif']);
        system(['rmdir ' path ]);
    else
        set(handles.messages, 'String', 'Background images successfully completed! Computing average');
        last_img = str2double(get(handles.imagename, 'String')) - 1;
        nscans = str2double(get(handles.numberscans, 'String'));
        handles.image = compute_avg(handles, [path '\'], [handles.root '_'], last_img:-1:last_img - nscans + 1, [path '\' handles.root '_avg.tif']);
        set(handles.filenamelabel, 'String', [handles.root '_avg.tif']);
        plotdiffraction(handles);
    end
end

handles.imageisbg = 0;

guidata(hObject, handles);

function avg_img = compute_avg(handles, src, root, img_indices, dest)
    % Takes tif files from src, avereages them, and puts them in dest
    i = 1;
    temp_img = imread([src root num2str(img_indices(1)) '.tif']);
    img_list = NaN([size(temp_img) size(img_indices, 2)]);
    for cur_img = img_indices
        img_list(:, :, i) = imread([src root num2str(cur_img) '.tif']);
        i = i + 1;
    end
    avg_img = mean(img_list, 3);
    imwrite(uint16(avg_img), dest);
    
% % --------------------------------------------------------------------
function openshutter1_ClickedCallback(~, ~, handles)
    % hObject    handle to openshutter1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    set(handles.messages,'String',char('Opening Shutter 1...'));
    [isOperationSuccessful,errorMessage] = OpenShutter(handles.UniblitzServer,1); % Open shutter 1
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 1 unable to open. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    else
        % updates the shutter status radio buttons
        set(handles.shutterindic1, 'Value', 1);
    end
    
    % checkstatus_Callback([], [], handles)% Check status of shutters

% % --------------------------------------------------------------------
function closeshutter1_ClickedCallback(~, ~, handles)
    % hObject    handle to closeshutter1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    [isOperationSuccessful,errorMessage] = CloseShutter(handles.UniblitzServer,1); % Close shutter 1
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 1 unable to close. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    end

    % checkstatus_Callback([], [], handles)% Check status of shutters

% % --------------------------------------------------------------------
function openshutter2_ClickedCallback(~, ~, handles)
    % hObject    handle to openshutter2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    [isOperationSuccessful,errorMessage] = OpenShutter(handles.UniblitzServer,2); % Open shutter 2
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 2 unable to open. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    end
    % checkstatus_Callback([], [], handles)% Check status of shutters

% % --------------------------------------------------------------------
function closeshutter2_ClickedCallback(~, ~,handles)
    % hObject    handle to closeshutter2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    [isOperationSuccessful,errorMessage] = CloseShutter(handles.UniblitzServer,2); % Close shutter 2
    % checks if the closing was successful
    if ~(isOperationSuccessful)
        errorMessage = append('Shutter 2 unable to close. <', errorMessage, '>')
        uiwait(warndlg(errorMessage, 'Shutter Warning', 'modal'))
    end

    % checkstatus_Callback([], [], handles)% Check status of shutters

% % --------------------------------------------------------------------
% function sample_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to sample (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles.sample = 1;
% hmyquest = myquestdlg; % Open a dialog question box
% hands = get(hmyquest,'Children'); % Get the handles of the new window
% 
% for i = 1:numel(hands)
%     eval([get(hands(i),'Tag') 'status = get(hands(' num2str(i) '),''Value'');']);
% end
%     
% while yesstatus == 0 && nostatus == 0 % Keeps looping while no button is pressed
%     pause(0.2)
%     for i = 1:numel(hands)
%         eval([get(hands(i),'Tag') 'status = get(hands(' num2str(i) '),''Value'');']);
%     end
%     
%     if yesstatus == 1 % If yes is pressed
%         set(handles.destinationh,'String','10000'); % Move linear and rotation stages
%         set(handles.operationh,'Value',1);
%         delete(hmyquest);
%         goh_Callback(hObject, eventdata, handles);
%         
%         set(handles.destinationa,'String','90.000000'); % Move linear and rotation stages
%         set(handles.operationa,'Value',1);
%         goa_Callback(hObject, eventdata, handles);
%         handles.sample = 0;
%     elseif nostatus == 1 % If No is pressed
%         delete(hmyquest);
%     end
% end
% 
% guidata(hObject,handles);
% 
% %%%% End Toolbar  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%% Start Menu  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % --------------------------------------------------------------------
% function File_Callback(~, ~, ~)
% % hObject    handle to File (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --------------------------------------------------------------------
% function newlogmenu_Callback(hObject, eventdata, handles)
% % hObject    handle to newlogmenu (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% newlog_ClickedCallback(hObject, eventdata, handles); % Go to newlog routine
% 
% % --------------------------------------------------------------------
% function openlogmenu_Callback(hObject, eventdata, handles)
% % hObject    handle to openlogmenu (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% openlog_ClickedCallback(hObject, eventdata, handles); % Go to openlog routine
% 
% 
% % --------------------------------------------------------------------
function exitmenu_Callback(~, ~, handles)
% hObject    handle to exitmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % DONT THINK WE'RE USING THIS ANYMORE
% for i = 1:handles.numberpp30
%     msg = {['CLOSE '  handles.handarray(i,:)]};
%     [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); %Close the communication
%     if i == handles.numberpp30
%         msg = {'QUIT'}; % Creates a command to quit the server communication
%         [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); %Quit the communication
%     end 
% end

if handles.numberrs40 ~= 0
    msg = {'CLOSE'}; % Creates a command to close the server communication
    [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); %Close the communication
    msg = {'QUIT'}; % Creates a command to close the server communication
    [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); %Quit the communication
end

if handles.ccd.IsAcquisitionRunning() == 1 % Check if acquisition of the ccd is running
    [isOperationSuccessful,errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
        set(handles.messages,'String','Stopping acquisition');
    end
end

% % not using firefly i guess?
% if (handles.ffClient.IsAcquisitionRunning(handles.camera)) % Check if acquisition of the firefly is running
%     [isOperationSuccessful,errorMessage] = handles.ffClient.StopAcquisition(handles.camera); % Stop acquisition
%     if (~isOperationSuccessful)
%         set(handles.messages,'String',char(errorMessage));
%     else
%         set(handles.messages,'String','Stopping acquisition');
%     end    
% end
% % both of these timers are just for firefly
% stop(handles.tmr2); % Stop timer
% delete(handles.tmr2); % Delete timer
% 
% stop(handles.tmr); % Stop timer
% delete(handles.tmr); % Delete timer

% if handles.NIDAQ == 1
%     msg = {'QUIT'}; % Create a message to close communication with NIDAQ
%     [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
% end

delete(gcf); % Exit the program

ia = findobj('type','figure','name','imageanalysis');
if ~isempty(ia); % If imageanalysis window is still running, close it
    delete(handles.imageanalysis); % Exit the image analysis program
end

% %%%% End Menu  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function positionh_Callback(~, ~, ~)
% hObject    handle to positionh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionh as text
%        str2double(get(hObject,'String')) returns contents of positionh as a double


% --- Executes during object creation, after setting all properties.
function positionh_CreateFcn(hObject, ~, ~)
% hObject    handle to positionh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function targeth_Callback(~, ~, ~)
% hObject    handle to targeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targeth as text
%        str2double(get(hObject,'String')) returns contents of targeth as a double


% --- Executes during object creation, after setting all properties.
function targeth_CreateFcn(hObject, ~, ~)
% hObject    handle to targeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in operationh.
function operationh_Callback(~, ~, handles)
% hObject    handle to operationh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operationh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationh

if get(handles.operationh,'Value') == 1 % If operation is 1 (destination)
    set(handles.directionh,'Enable','off'); % Disable direction control
else % If operation is 2 (displacement)
    set(handles.directionh,'Enable','on'); % Enable direction control
end

% --- Executes during object creation, after setting all properties.
function operationh_CreateFcn(hObject, ~, ~)
% hObject    handle to operationh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in directionh.
function directionh_Callback(hObject, ~, handles)
% hObject    handle to directionh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directionh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directionh

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function directionh_CreateFcn(hObject, ~, ~)
% hObject    handle to directionh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function destinationh_Callback(hObject, ~, handles)
% hObject    handle to destinationh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationh as text
%        str2double(get(hObject,'String')) returns contents of destinationh as a double

set(handles.targeth,'String',get(handles.destinationh,'String')); % Show horizontal target destination on screen

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function destinationh_CreateFcn(hObject, ~, ~)
% hObject    handle to destinationh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function veloch_Callback(hObject, ~, handles)
% hObject    handle to veloch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of veloch as text
%        str2double(get(hObject,'String')) returns contents of veloch as a double

velum = get(handles.veloch,'String'); % Get velocity value from panel
velcounts = num2str(str2double(velum)*20,'%5.0f'); % Convert velocity to counts/s

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(1,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' HSPD='  velcounts]}; % Creates a command to set the velocity
pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set the velocity
msg = {['SENDRCV ' harray ' HSPD']}; % Creates a command to get the velocity
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Get the velocity
velum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert the velocity to um/s
set(handles.veloch,'String',velum); % Set the velocity to panel

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function veloch_CreateFcn(hObject, ~, ~)
% hObject    handle to veloch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function acceh_Callback(hObject, ~, handles)
% hObject    handle to acceh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acceh as text
%        str2double(get(hObject,'String')) returns contents of acceh as a double

accelum = get(handles.acceh,'String'); % Get acceleration value from panel
accelcounts = num2str(str2double(accelum)*20,'%5.0f'); % Convert acceleration to counts/s^2

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(1,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' ACC='  accelcounts]}; % Creates a command to set the acceleration
pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set the acceleration
msg = {['SENDRCV ' harray ' ACC']}; % Creates a command to get the acceleration
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Get the acceleration
accelum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert the acceleration to um/s^2
set(handles.acceh,'String',accelum); % Set the acceleration to panel

guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function acceh_CreateFcn(hObject, ~, ~)
% hObject    handle to acceh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in reseth.
function reseth_Callback(hObject, ~, handles)
% hObject    handle to reseth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(1,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' EX=0'],['SENDRCV ' harray ' EX']}; % Creates a command for setting the position to 0 and check it afterward
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set position and check
posum = answer{2}; % Assign answer{2} to posum
set(handles.positionh,'String',posum); % Set position in panel

guidata(hObject, handles)

% --- Executes on button press in goh.
function goh_Callback(hObject, ~, handles)
% hObject    handle to goh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.goh,'Enable','off'); % Set the go button off
set(handles.homeh,'Enable','off'); % Set the home button off

if get(handles.homeh,'Value') == 1 % Check the status of the Home button
    destum = '0'; % If Home was pressed set destum to 0
    set(handles.homeh,'Value',0); % Change the status back to release
    set(handles.operationh,'Value',1); % Set Operation to destination
    set(handles.directionh,'Enable','off') % Disable direction
else
    destum = get(handles.destinationh,'String'); % Get destination from panel
end

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(1,:);
else
    harray = handles.handarray;
end

if isempty(destum) ~= 1 % If destum is 0 (not destination set) do nothing
    msg = {['SENDRCV ' harray ' EX']}; % Creates the command to check the position
    [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check the position
    posum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert position to um
    set(handles.positionh,'String',posum); % Set position in panel

    if get(handles.operationh,'Value') == 2 % If Operation mode is displacement (relative move)
        if str2double(get(handles.destinationh,'String')) < 0 % If destination is negative convert to positive. No negative numbers are allowed in displacement operation
            tempvalue = get(handles.destinationh,'String');
            positive = tempvalue(2:end);
            set(handles.destinationh,'String',positive);
        end
        if get(handles.directionh,'Value') == 1 % Get direction
            posumnew = num2str(str2double(posum)+str2double(get(handles.destinationh,'String')),'%5.0f'); % If forward do position + displacement
            jog = 'J+';
        else
            posumnew = num2str(str2double(posum)-str2double(get(handles.destinationh,'String')),'%5.0f'); % If backward do position - displacement
            jog = 'J-';
        end
        set(handles.targeth,'String',posumnew); % Set target as the posumnew
        relative = str2double(get(handles.destinationh,'String'));    
    else
        set(handles.targeth,'String',destum); % Copy destination in target panel
        if str2double(posum) < str2double(get(handles.targeth,'String'))
            jog = 'J+';
        else
            jog = 'J-';
        end
        relative = abs(str2double(get(handles.targeth,'String')) - str2double(posum));
    end
    destcounts = num2str(str2double(get(handles.targeth,'String'))*20); % Get target and convert to encoder counts
    msg = {['SENDRCV ' harray ' ' jog]}; % Create command to move the stage
    pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage
    stop = 0;
    while stop == 0 && relative > 100 % Loop to update position as it moves
        msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check status and position
        poscount = answer{1}; % Assign answer 1 (position) to variable poscount
        posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
        set(handles.positionh,'String',posum); % Set position in panel
        pause(0.05); % Wait 50 ms
    
        if get(handles.killh,'Value') == 1 % Leave the loop if kill button is pressed
            stop = 1;
        end
        
        if strcmp(jog,'J+') == 1 && str2double(get(handles.targeth,'String')) - 5 < str2double(posum) % Leave the loop if target is reached
            stop = 1;
        end
        
        if strcmp(jog,'J-') == 1 && str2double(get(handles.targeth,'String')) + 5 > str2double(posum) % Leave the loop if target is reached
            stop = 1;
        end
    end    
    msg = {['SENDRCV ' harray ' STOP']}; % Creates command to stop
    pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Stop stage
    pause(0.5) % Wait 0.5 s
    
    if get(handles.killh,'Value') ~= 1
        msg = {['SENDRCV ' harray ' X' destcounts]}; % Create command to move the stage
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage

        msg = {['SENDRCV ' harray ' SLS']};
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage

        while str2double(answer{1}(1:end)) ~= 0 % If Status is 11 or 10 (Still correcting)
            msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
            [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check position
            poscount = answer{1}; % Assign answer 1 (position) to variable poscount
            posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
            set(handles.positionh,'String',posum); % Set position in panel
            msg = {['SENDRCV ' harray ' SLS']}; %
            [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % 
        end
    end

    msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
    [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check position
    poscount = answer{1}; % Assign answer 1 (position) to variable poscount
    posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
    set(handles.positionh,'String',posum); % Set position in panel
    set(handles.killh,'Value',0); % Set the kill button in "release" status
    set(handles.goh,'Enable','on'); % Enable go button
    set(handles.homeh,'Enable','on'); % Disable go button
end

guidata(hObject, handles);

% --- Executes on button press in killh.
function killh_Callback(hObject, ~, handles)
% hObject    handle to killh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --- Executes on button press in homeh.
function homeh_Callback(hObject, eventdata, handles)
% hObject    handle to homeh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

goh_Callback(hObject, eventdata, handles); % Go to goh_Callback function

function positionv_Callback(~, ~, ~)
% hObject    handle to positionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionv as text
%        str2double(get(hObject,'String')) returns contents of positionv as a double

% --- Executes during object creation, after setting all properties.
function positionv_CreateFcn(hObject, ~, ~)
% hObject    handle to positionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function targetv_Callback(~, ~, ~)
% hObject    handle to targetv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetv as text
%        str2double(get(hObject,'String')) returns contents of targetv as a double

% --- Executes during object creation, after setting all properties.
function targetv_CreateFcn(hObject, ~, ~)
% hObject    handle to targetv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in operationv.
function operationv_Callback(~, ~, handles)
% hObject    handle to operationv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operationv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationv

if get(handles.operationv,'Value') == 1 % If operation is 1 (destination)
    set(handles.directionv,'Enable','off'); % Disable direction control
else % If operation is 2 (displacement)
    set(handles.directionv,'Enable','on'); % Enable direction control
end

% --- Executes during object creation, after setting all properties.
function operationv_CreateFcn(hObject, ~, ~)
% hObject    handle to operationv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in directionv.
function directionv_Callback(hObject, ~, handles)
% hObject    handle to directionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directionv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directionv

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function directionv_CreateFcn(hObject, ~, ~)
% hObject    handle to directionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function destinationv_Callback(hObject, ~, handles)
% hObject    handle to destinationv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationv as text
%        str2double(get(hObject,'String')) returns contents of destinationv as a double

set(handles.targetv,'String',get(handles.destinationv,'String')); % Show vertical target destination on screen

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function destinationv_CreateFcn(hObject, ~, ~)
% hObject    handle to destinationv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function velocv_Callback(hObject, ~, handles)
% hObject    handle to velocv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of velocv as text
%        str2double(get(hObject,'String')) returns contents of velocv as a double

velum = get(handles.velocv,'String'); % Get velocity value from panel
velcounts = num2str(str2double(velum)*20,'%5.0f'); % Convert velocity to counts/s

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(2,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' HSPD='  velcounts]}; % Creates a command to set the velocity
pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set the velocity
msg = {['SENDRCV ' harray ' HSPD']}; % Creates a command to get the velocity
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Get the velocity
velum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert the velocity to um/s
set(handles.velocv,'String',velum); % Set the velocity to panel

guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function velocv_CreateFcn(hObject, ~, ~)
% hObject    handle to velocv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function accev_Callback(hObject, ~, handles)
% hObject    handle to accev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accev as text
%        str2double(get(hObject,'String')) returns contents of accev as a double

accelum = get(handles.accev,'String'); % Get acceleration value from panel
accelcounts = num2str(str2double(accelum)*20,'%5.0f'); % Convert acceleration to counts/s^2

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(2,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' ACC='  accelcounts]}; % Creates a command to set the acceleration
pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set the acceleration
msg = {['SENDRCV ' harray ' ACC']}; % Creates a command to get the acceleration
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Get the acceleration
accelum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert the acceleration to um/s^2
set(handles.accev,'String',accelum); % Set the acceleration to panel

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function accev_CreateFcn(hObject, ~, ~)
% hObject    handle to accev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in resetv.
function resetv_Callback(hObject, ~, handles)
% hObject    handle to resetv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(2,:);
else
    harray = handles.handarray;
end

msg = {['SENDRCV ' harray ' EX=0'],['SENDRCV ' harray ' EX']}; % Creates a command for setting the position to 0 and check it afterward
[answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Set position and check
posum = answer{2}; % Assign answer{2} to posum
set(handles.positionv,'String',posum); % Set position in panel

guidata(hObject, handles);

% --- Executes on button press in gov.
function gov_Callback(hObject, ~, handles)
% hObject    handle to gov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.gov,'Enable','off'); % Disable go button
set(handles.homev,'Enable','off'); % Disable home button

if get(handles.homev,'Value') == 1 % Check the status of the Home button
    destum = '0'; % If Home was pressed set destum to 0
    set(handles.homev,'Value',0); % Change the status back to release
    set(handles.operationv,'Value',1); % Set Operation to destination
    set(handles.directionv,'Enable','off') % Disable direction
else
    destum = get(handles.destinationv,'String'); % Get destination from panel
end

sarray = size(handles.handarray);
if sarray(1) == 2
    harray = handles.handarray(2,:);
else
    harray = handles.handarray;
end

if isempty(destum) ~= 1 % If destum is 0 (not destination set) do nothing
    msg = {['SENDRCV ' harray ' EX']}; % Creates the command to check the position
    [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check the position
    posum = num2str(str2double(answer{1})/20,'%5.0f'); % Convert position to um
    set(handles.positionv,'String',posum); % Set position in panel

    if get(handles.operationv,'Value') == 2 % If Operation mode is displacement (relative move)
        if str2double(get(handles.destinationv,'String')) < 0 % If destination is negative convert to positive. No negative numbers are allowed in displacement operation
            tempvalue = get(handles.destinationv,'String');
            positive = tempvalue(2:end);
            set(handles.destinationv,'String',positive);
        end
        if get(handles.directionv,'Value') == 1 % Get direction
            posumnew = num2str(str2double(posum)+str2double(get(handles.destinationv,'String')),'%5.0f'); % If forward do position + displacement
            jog = 'J+';
        else
            posumnew = num2str(str2double(posum)-str2double(get(handles.destinationv,'String')),'%5.0f'); % If backward do position - displacement
            jog = 'J-';
        end
        set(handles.targetv,'String',posumnew); % Set target as the posumnew
        relative = str2double(get(handles.destinationv,'String'));
    else
        set(handles.targetv,'String',destum); % Copy destination in target panel
        if str2double(posum) < str2double(get(handles.targetv,'String'))
            jog = 'J+';
        else
            jog = 'J-';
        end
        relative = abs(str2double(get(handles.targetv,'String')) - str2double(posum));
    end
    destcounts = num2str(str2double(get(handles.targetv,'String'))*20); % Get target and convert to encoder counts
    msg = {['SENDRCV ' harray ' ' jog]}; % Create command to move the stage
    pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage
    stop = 0;
    while stop == 0 && relative > 100 % Loop to update position as it moves
        msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check status and position
        poscount = answer{1}; % Assign answer 1 (position) to variable poscount
        posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
        set(handles.positionv,'String',posum); % Set position in panel
        pause(0.05); % Wait 50 ms
    
        if get(handles.killv,'Value') == 1 % Leave the loop if kill button is pressed
            stop = 1;
        end
        
        if strcmp(jog,'J+') == 1 && str2double(get(handles.targetv,'String')) - 5 < str2double(posum) % Leave the loop if target is reached
            stop = 1;
        end
        
        if strcmp(jog,'J-') == 1 && str2double(get(handles.targetv,'String')) + 5 > str2double(posum) % Leave the loop if target is reached
            stop = 1;
        end
    end
    msg = {['SENDRCV ' harray ' STOP']}; % Creates command to stop
    pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Stop stage
    pause(0.5) % Wait 0.5 s
    
    if get(handles.killv,'Value') ~= 1
        msg = {['SENDRCV ' harray ' X' destcounts]}; % Create command to move the stage
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage

        msg = {['SENDRCV ' harray ' SLS']};
        [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Move the stage

        while str2double(answer{1}(1:end)) ~= 0 % If Status is 11 or 10 (Still correcting)
            msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
            [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check position
            poscount = answer{1}; % Assign answer 1 (position) to variable poscount
            posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
            set(handles.positionv,'String',posum); % Set position in panel
            msg = {['SENDRCV ' harray ' SLS']}; %
            [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % 
        end
    end
    
    msg = {['SENDRCV ' harray ' EX']}; % Creates command to check position
    [answer handles.input_socket30] = pp30(handles.computerip30,handles.port30,msg,handles.input_socket30); % Check position
    poscount = answer{1}; % Assign answer 1 (position) to variable poscount
    posum = num2str(str2double(poscount)/20,'%5.0f'); % Convert poscount to um
    set(handles.positionv,'String',posum); % Set position in panel
    set(handles.killv,'Value',0); % Set the kill button in "release" status
    set(handles.gov,'Enable','on'); % Enable go button
    set(handles.homev,'Enable','on'); % Disable go button
end

guidata(hObject, handles);

% --- Executes on button press in killv.
function killv_Callback(hObject, ~, handles)
% hObject    handle to killv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function killv_CreateFcn(~, ~, ~)
% hObject    handle to killv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in homev.
function homev_Callback(hObject, eventdata, handles)
% hObject    handle to homev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gov_Callback(hObject, eventdata, handles); % Go to gov_Callback function

function positiond_Callback(~, ~, ~)
% hObject    handle to positiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positiond as text
%        str2double(get(hObject,'String')) returns contents of positiond as a double


% --- Executes during object creation, after setting all properties.
function positiond_CreateFcn(hObject, ~, ~)
% hObject    handle to positiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function targetd_Callback(~, ~, ~)
% hObject    handle to targetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetd as text
%        str2double(get(hObject,'String')) returns contents of targetd as a double


% --- Executes during object creation, after setting all properties.
function targetd_CreateFcn(hObject, ~, ~)
% hObject    handle to targetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in operationd.
function operationd_Callback(hObject, ~, handles)
% hObject    handle to operationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operationd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationd

if get(handles.operationd,'Value') == 1 % If operation is 1 (destination)
    set(handles.directiond,'Enable','off'); % Disable direction control
else % If operation is 2 (displacement)
    set(handles.directiond,'Enable','on'); % Enable direction control
end

guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function operationd_CreateFcn(hObject, ~, ~)
% hObject    handle to operationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in directiond.
function directiond_Callback(hObject, ~, handles)
% hObject    handle to directiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directiond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directiond

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function directiond_CreateFcn(hObject, ~, ~)
% hObject    handle to directiond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function destinationd_Callback(hObject, ~, handles)
% hObject    handle to destinationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationd as text
%        str2double(get(hObject,'String')) returns contents of destinationd as a double

set(handles.targetd,'String',get(handles.destinationd,'String')) ;

guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function destinationd_CreateFcn(hObject, ~, ~)
% hObject    handle to destinationd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function velocd_Callback(hObject, ~, handles)
% hObject    handle to velocd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of velocd as text
%        str2double(get(hObject,'String')) returns contents of velocd as a double

velocity = str2double(get(handles.velocd,'String')); % Read delay stage velocity from screen
minsetvel = 10;
maxsetvel = str2double(GetStageMaximumVelocity(handles.PIServer,1))*1000; % Read delay stage max velocity from delay stage server
if velocity < minsetvel % If set velocity is less than min velocity
    SetStageVelocity(handles.PIServer, 1, minsetvel/1000); % Set velocity to min velocity
elseif velocity > maxsetvel % If set velocity is greater than max velocity
    SetStageVelocity(handles.PIServer, 1, maxsetvel/1000); % Set velocity to max velocity
else
    SetStageVelocity(handles.PIServer, 1, num2str(velocity/1000)); % Set velocity
end

set(handles.velocd,'String',num2str(round(str2double(GetStageVelocity(handles.PIServer, 1))*1000))); % Show velocity on screen

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function velocd_CreateFcn(hObject, ~, ~)
% hObject    handle to velocd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function acced_Callback(hObject, ~, handles)
% hObject    handle to acced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acced as text
%        str2double(get(hObject,'String')) returns contents of acced as a double

acceleration = str2double(get(handles.acced,'String')); % Read delay stage acceleration from screen
minsetacce = 10;
maxsetacce = str2double(GetStageMaximumAcceleration(handles.PIServer,1))*1000; % Read delay stage max acceleration from delay stage server
if acceleration < minsetacce % If set acceleration is less than min acceleration
    SetStageAcceleration(handles.PIServer, 1, minsetacce/1000); % Set acceleration to min acceleration
elseif acceleration > maxsetacce % If set acceleration is greater than max acceleration
    SetStageAcceleration(handles.PIServer, 1, maxsetacce/1000); % Set acceleration to max acceleration
else
    SetStageAcceleration(handles.PIServer, 1, num2str(acceleration/1000)); % Set acceleration
end

set(handles.acced,'String',num2str(round(str2double(GetStageAcceleration(handles.PIServer, 1))*1000))); % Show acceleration on screen

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function acced_CreateFcn(hObject, ~, ~)
% hObject    handle to acced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in resetd.
function resetd_Callback(hObject, ~, handles)
% hObject    handle to resetd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InitializeAllStages(handles.PIServer); % Initialized delay stage
pause(0.02);

posum = num2str(round(str2double(GetStagePosition(handles.PIServer,1))*1000)); % Read delay stage position from delay stage server
set(handles.positiond,'String',posum); % Show position on screen

velums = num2str(round(str2double(GetStageVelocity(handles.PIServer,1))*1000)); % Read delay stage velocity from delay stage server
set(handles.velocd,'String',velums); % Show velocity on screen

guidata(hObject, handles);

% --- Executes on button press in god.
function god_Callback(hObject, ~, handles)
% hObject    handle to god (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.god,'Enable','off'); % Set the go button off
set(handles.homed,'Enable','off'); % Set the home button off

if get(handles.operationd,'Value') == 1 % If Operation mode is destination
    set(handles.targetd,'String',get(handles.destinationd,'String')); % Copy destination in target panel
    target = str2double(get(handles.targetd,'String'))/1000; % Read target from screen and copy in target variable
    if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000 % If target is beyond limits
        errordlg('Target is beyond the limits', 'Error'); % Show error dialog
    else
        MoveStageToAbsolutePosition(handles.PIServer,1,target); % Move absolute
        while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1 % Loop until reach target
            pause(0.1);
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
            if get(handles.killd,'Value') == 1
                break;
            end
        end
        StopStage(handles.PIServer, 1); % Stop delay stage
        set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
    end
else % If Operation mode is displacement
    if get(handles.directiond,'Value') == 1 % If direction is forward
        destination = str2double(GetStagePosition(handles.PIServer, 1))*1000 + str2double(get(handles.destinationd,'String')); % Destination = position + displacement
        set(handles.targetd,'String',num2str(round(destination))); % Show target on screen
        target = str2double(get(handles.targetd,'String'))/1000; % Read target from screen
        
        if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000 % If target is beyond limits
            errordlg('Target is beyond the limits', 'Error'); % Show error dialog
        else
            relmov = str2double(get(handles.destinationd,'String'))/1000;
            MoveStageToRelativePosition(handles.PIServer, 1, relmov); % Move relative
        
            while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1 % Loop until reach target
                pause(0.02) ;
                set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen                
                if get(handles.killd,'Value') == 1
                    break;
                end    
            end
            StopStage(handles.PIServer, 1); % Stop delay stage
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
        end

    else % If direction is backward
        destination = str2double(GetStagePosition(handles.PIServer, 1))*1000 - str2double(get(handles.destinationd,'String')); % Destination = position - displacement
        set(handles.targetd,'String',num2str(round(destination))); % Show target on screen
        target = str2double(get(handles.targetd,'String'))/1000; % Read target on screen
        
        if target < str2double(GetStageMinimumPosition(handles.PIServer, 1)) * 1000 || target > str2double(GetStageMaximumPosition(handles.PIServer, 1)) * 1000 % If target is beyond limits
            errordlg('Target is beyond the limits', 'Error'); % Show error dialog
        else
            relmov = -1 * str2double(get(handles.destinationd,'String'))/1000;
            MoveStageToRelativePosition(handles.PIServer, 1, relmov); % Move relative

            while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1 % Loop until reach target
                pause(0.02);
                set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
                if get(handles.killd,'Value') == 1
                    break;
                end    
            end
            StopStage(handles.PIServer, 1); % Stop delay stage
            set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
        end
    end
end

set(handles.killd,'Value',0); % Set the kill button in "release" status
set(handles.god,'Enable','on'); % Set the go button on
set(handles.homed,'Enable','on'); % Set the home button on

guidata(hObject, handles);

% --- Executes on button press in killd.
function killd_Callback(hObject, ~, handles)
% hObject    handle to killd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --- Executes on button press in homed.
function homed_Callback(hObject, ~, handles)
% hObject    handle to homed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

homepos = (str2double(GetStageMaximumPosition(handles.PIServer, 1)) + str2double(GetStageMinimumPosition(handles.PIServer, 1)))/2; % Set home exactly between limuits
set(handles.targetd,'String',num2str(round(homepos*1000))); % Show home position on screen
target = str2double(get(handles.targetd,'String'))/1000; % Copy home position on target
MoveStageToAbsolutePosition(handles.PIServer,1,target); % Move to target
while strcmp(isStageOnTarget(handles.PIServer, 1),'false') == 1 % Loop until reach target
    pause(0.02);
    set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
    if get(handles.killd,'Value') == 1
        break;
    end    
end
StopStage(handles.PIServer, 1); % Stop delay stage
set(handles.positiond,'String',num2str(round(str2double(GetStagePosition(handles.PIServer, 1))*1000))); % Update position on screen
set(handles.killd,'Value',0); % Set the kill button in "release" status

guidata (hObject, handles);

function positiona_Callback(~, ~, ~)
% hObject    handle to positionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionv as text
%        str2double(get(hObject,'String')) returns contents of positionv as a double

% --- Executes during object creation, after setting all properties.
function positiona_CreateFcn(hObject, ~, ~)
% hObject    handle to positiona (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function targeta_Callback(~, ~, ~)
% hObject    handle to positionv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionv as text
%        str2double(get(hObject,'String')) returns contents of positionv as a double

% --- Executes during object creation, after setting all properties.
function targeta_CreateFcn(hObject, ~, ~)
% hObject    handle to targeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in operationa.
function operationa_Callback(~, ~, handles)
% hObject    handle to operationa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operationa contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationa

if get(handles.operationa,'Value') == 1 % If operation is 1 (destination)
    set(handles.directiona,'Enable','off'); % Disable direction control
else  % If operation is 2 (displacement)
    set(handles.directiona,'Enable','on'); % Enable direction control
end


% --- Executes during object creation, after setting all properties.
function operationa_CreateFcn(hObject, ~, ~)
% hObject    handle to operationa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in directiona.
function directiona_Callback(~, ~, ~)
% hObject    handle to directiona (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directiona contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directiona


% --- Executes during object creation, after setting all properties.
function directiona_CreateFcn(hObject, ~, ~)
% hObject    handle to directiona (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function destinationa_Callback(~, ~, handles)
% hObject    handle to destinationa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationa as text
%        str2double(get(hObject,'String')) returns contents of destinationa as a double

set(handles.destinationa,'String',num2str(str2double(get(handles.destinationa,'String')),'%9.6f')); % Show angular destination in proper format

% --- Executes during object creation, after setting all properties.
function destinationa_CreateFcn(hObject, ~, ~)
% hObject    handle to destinationa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function veloca_Callback(~, ~, handles)
% hObject    handle to veloca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of veloca as text
%        str2double(get(hObject,'String')) returns contents of veloca as a double

velum = get(handles.veloca,'String'); % Get velocity value from panel
velum = num2str(str2double(velum),'%9.6f');
msg = {['SETVEL ' handles.axis ' ' velum]}; % Creates a command to set the velocity
rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Set the velocity
msg = {['GETVEL ' handles.axis]}; % Creates a command to get the velocity
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Get the velocity
velum = answer{1}; % Convert the velocity to um/s
set(handles.veloca,'String',velum(1:end-1)); % Set the velocity to panel

% --- Executes during object creation, after setting all properties.
function veloca_CreateFcn(hObject, ~, ~)
% hObject    handle to veloca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function accea_Callback(~, ~, handles)
% hObject    handle to accea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accea as text
%        str2double(get(hObject,'String')) returns contents of accea as a double

accelum = get(handles.accea,'String'); % Get acceleration value from panel
accelum = num2str(str2double(accelum),'%9.6f');
msg = {['SETACCEL '  handles.axis ' ' accelum]}; % Creates a command to set the acceleration
rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Set the acceleration
msg = {['GETACCEL ' handles.axis]}; % Creates a command to get the acceleration
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Get the acceleration
accelum = answer{1}; % Convert the acceleration to um/s^2
set(handles.accea,'String',accelum(1:end-1)); % Set the acceleration to panel

% --- Executes during object creation, after setting all properties.
function accea_CreateFcn(hObject, ~, ~)
% hObject    handle to accea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in reseta.
function reseta_Callback(~, ~, handles)
% hObject    handle to reseta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msg = {['SETORIGIN ' handles.axis],['GETPOS ' handles.axis]}; % Creates a command for setting the position to 0 and check it afterward
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Set position and check
posum = answer{2}; % Assign answer{2} to posum
set(handles.positiona,'String',posum) ; % Set position in panel

% --- Executes on button press in goa.
function goa_Callback(~, ~, handles)
% hObject    handle to goa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.goa,'Enable','off'); % Set the go button off
set(handles.homea,'Enable','off'); % Set the home button off

if get(handles.homea,'Value') == 1 % Check the status of the Home button
    destum = 0; % If Home was pressed set destum to 0
else
    destum = get(handles.destinationa,'String'); % Get destination from panel
end

if isempty(destum) ~= 1 % If destum is 0 (not destination set) do nothing
    set(handles.targeta,'String',destum); % Copy destination in target panel
    if get(handles.operationa,'Value') == 2 && get(handles.homea,'Value') ~= 1% If Operation mode is displacement (relative move)
        if str2double(get(handles.destinationa,'String')) < 0 % If destination is negative convert to positive. No negative numbers are allowed in displacement operation
            tempvalue = get(handles.destinationa,'String');
            positive = tempvalue(2:end);
            set(handles.destinationa,'String',positive);
        end
        posum = get(handles.positiona,'String');
        if get(handles.directiona,'Value') == 1 % Get direction
            posumnew = num2str(str2double(posum(1,1:end-1))+str2double(get(handles.destinationa,'String')),'%9.6f'); % If forward do position + displacement
            movstr = get(handles.destinationa,'String'); 
        else
            posumnew = num2str(str2double(posum(1,1:end-1))-str2double(get(handles.destinationa,'String')),'%9.6f'); % If forward do position + displacement
            movstr = ['-' get(handles.destinationa,'String')]; % If backward do position - displacement
        end
        set(handles.targeta,'String',posumnew);
        if (str2double(posumnew) > handles.limitangle || str2double(posumnew) < -1*handles.limitangle) %&& handles.sample == 0
            errordlg(['Angles lower than -' num2str(handles.limitangle) ' deg or greater than ' num2str(handles.limitangle) ' deg are not allowed'],'Large angle error');
        else 
            set(handles.targeta,'String',posumnew);
            msg = {['MOVEREL ' handles.axis ' ' movstr]}; % Create command to move the stage
            rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Move the stage
        end
    else
        if (str2double(get(handles.targeta,'String')) > handles.limitangle || str2double(get(handles.targeta,'String')) < -1*handles.limitangle) && handles.sample == 0
            errordlg(['Angles lower than -' num2str(handles.limitangle) ' deg or greater than ' num2str(handles.limitangle) ' deg are not allowed']);
        else 
        msg = {['MOVEABS ' handles.axis ' ' get(handles.targeta,'String')]}; % Create command to move the stage
        rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Move the stage
        end
    end
    
    msg = {['EXECUTE ' handles.axis ' NSTATUS']}; % Create command to check status
    [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Check status of the stage (i.e. "moving", "idle", etc)

    while str2double(answer{1}(1)) ~= 0 || get(handles.killa,'Value') == 1 % Loop to update position as it moves
        msg = {['EXECUTE ' handles.axis ' NSTATUS'],['GETPOS ' handles.axis]}; % Creates command to check status and position
        [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Check status and position
        posum = answer{2}; % Assign answer 2 (position) to variable poscount
        set(handles.positiona,'String',posum); % Set position in panel
        pause(0.05); % Wait 50 ms
    
        if get(handles.killa,'Value') == 1
            break;
        end
    end
    msg = {['GETPOS ' handles.axis]}; % Creates command to check position
    [answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Check position
    posum = answer{1}; % Assign answer 1 (position) to variable poscount
    set(handles.positiona,'String',posum); % Set position in panel
    set(handles.killa,'Value',0); % Set the kill button in "release" status
    set(handles.homea,'Value',0); % Change the status back to release
    set(handles.goa,'Enable','on'); % Set the go button on
    set(handles.homea,'Enable','on'); % Set the home button on
end

% --- Executes on button press in killa.
function killa_Callback(~, ~, handles)
% hObject    handle to killa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msg = {['EXECUTE ' handles.axis ' NABORT']}; % Creates command to abort
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Execute abort
pause(1); % Pause 500 ms
answer{1} = '';
msg = {['GETPOS ' handles.axis]}; % Creates command to check position
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Check position
msg = {['GETPOS ' handles.axis]}; % Creates command to check position
[answer handles.input_socket40] = rs40(handles.computerip40,handles.port40,msg,handles.input_socket40); % Check position
posum = answer{1}; % Assign answer 1 (position) to variable poscount
set(handles.positiona,'String',posum); % Set position in panel

% --- Executes on button press in homea.
function homea_Callback(hObject, eventdata, handles)
% hObject    handle to homea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

goa_Callback(hObject, eventdata, handles); % Go to goa_Callback function

function rootname_Callback(hObject, ~, handles)
% hObject    handle to rootname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rootname as text
%        str2double(get(hObject,'String')) returns contents of rootname as a double

set(handles.rootname,'String',handles.root); % Show root varaible on screen

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rootname_CreateFcn(hObject, ~, ~)
% hObject    handle to rootname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in autosave.
function autosave_Callback(hObject, ~, handles)
% hObject    handle to autosave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autosave

tabledata = get(handles.logtable,'data'); % Read datalog from screen
if isempty(tabledata) == 1 % If empty
    tabledata = {'', '', '', '', '', '', '', ''}; % Fill with empty Strings
end
if strcmp('',tabledata(end,1)) == 1; % If last row and first column of the table is empty
   number = num2str(1); % Set number to 1
else % If not empty
   number = num2str(str2num(char(tabledata(end,1))) + 1); % Increase number value by one
end
set(handles.imagename,'String',number); % Show number on screen

guidata(hObject, handles);

function savingpath_Callback(hObject, ~, handles)
% hObject    handle to savingpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savingpath as text
%        str2double(get(hObject,'String')) returns contents of savingpath as a double

handles.path = get(handles.savingpath,'String'); % Read path from screen

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function savingpath_CreateFcn(hObject, ~, ~)
% hObject    handle to savingpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function imagename_Callback(hObject, ~, handles)
% hObject    handle to imagename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imagename as text
%        str2double(get(hObject,'String')) returns contents of imagename as a double

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function imagename_CreateFcn(hObject, ~, ~)
% hObject    handle to imagename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exposure_Callback(hObject, ~, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure as text
%        str2double(get(hObject,'String')) returns contents of exposure as a double

if isnan(str2double(get(handles.exposure,'String'))) == 1 || str2double(get(handles.exposure,'String')) < 0.1 % If exposure is not a number or is less than 0.1
    % Do nothing
else
    if handles.ccd.IsAcquisitionRunning() == 1 % Check if acquisition is running
        [isOperationSuccessful, errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        end
    end
    [isOperationSuccessful, errorMessage] = handles.ccd.SetExposureTime(str2double(get(handles.exposure,'String'))); % Set exposure time
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
    end
end

[exptime,isOperationSuccessful, errorMessage] = handles.ccd.GetExposureTime(); % Check exposure time
if (~isOperationSuccessful)
else
    set(handles.exposure,'String',num2str(exptime)); % Show new exposure time
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, ~, ~)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function width_Callback(hObject, ~, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width as text
%        str2double(get(hObject,'String')) returns contents of width as a double

if str2double(get(handles.width,'String')) > handles.fullwidth % If width is greater than fullchip's width
    set(handles.width,'String',num2str(handles.fullwidth)); % Set width to fullchip's width
else
end
handles.imagesize(1) = cellstr(get(handles.width,'String')); % Set imagesize(1) to width

guidata(hObject, handles);
   
% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, ~, ~)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function height_Callback(hObject, ~, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height as text
%        str2double(get(hObject,'String')) returns contents of height as a double

if str2double(get(handles.height,'String')) > handles.fullheight % If height is greater than fullchip's height
    set(handles.height,'String',num2str(handles.fullheight)); % Set height to fullchip's height
else
end
handles.imagesize(2) = cellstr(get(handles.height,'String')); % Set imagesize(2) to height

guidata(hObject, handles);
   
% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, ~, ~)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in regionsel.
function regionsel_Callback(hObject, ~, handles)
% hObject    handle to regionsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regionsel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regionsel

handles = regionsel(handles);
roisel = get(handles.regionsel,'Value'); % Set roisel as the value of regionsel
set(handles.width,'String',handles.selString{2}(roisel)); % Show width of regionsel
set(handles.height,'String',handles.selString{3}(roisel));% Show height of regionsel
 
   
if handles.ccd.IsAcquisitionRunning() == 1 % If acquisition is running
    [isOperationSuccessful, errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
    
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    end
end

[isOperationSuccessful, errorMessage] = handles.ccd.SetImageROI(str2double(get(handles.width,'String')),str2double(get(handles.height,'String')),str2double(get(handles.binning,'String'))); % Set ROI

if (~isOperationSuccessful)
    set(handles.messages,'String',errorMessage);
end

[width,height,binning,isOperationSuccessful, errorMessage] = handles.ccd.GetImageROI(); % Read width, height and binning from server

if (~isOperationSuccessful)
    set(handles.messages,'String',errorMessage);
else
    set(handles.width,'String',num2str(width)); % Show width on screen
    set(handles.height,'String',num2str(height)); % Show height on screen
    set(handles.binning,'String',num2str(binning)); % Show binning on screen
    set(handles.messages,'String',['CCD dimensions: width = ' num2str(width) ' x height = ' num2str(height)]);
end

handles.size(1) = cellstr(get(handles.width,'String')); % Set handles.size(1) value to width
handles.size(2) = cellstr(get(handles.height,'String')); % Set handles.size(2) value to height

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function regionsel_CreateFcn(hObject, ~, ~)
% hObject    handle to regionsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in chippanel.
function chippanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in chippanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: String 'SelectionChanged' (read only)
% %	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if handles.ccd.IsAcquisitionRunning() == 1 % If acquisition is running
    [isOperationSuccessful, errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    end
end

if strcmp(get(get(handles.chippanel,'SelectedObject'),'Tag'),'fullchip') == 1 % If full chip is selected
    set(handles.width,'String',num2str(handles.fullwidth)); % Show fullwidth on screen
    set(handles.height,'String',num2str(handles.fullheight)); % Show fullheight on screen
    set(handles.regionsel,'Enable','off'); % Disable region selection
    set(handles.width,'Enable','off');% Disable width
    set(handles.height,'Enable','off');% Disable height
else % If full chip is not selected
    set(handles.regionsel,'Enable','on'); % Enable region selection
    set(handles.width,'Enable','on'); % Enable width
    set(handles.height,'Enable','on');% Enable height
    set(handles.regionsel,'Value',1); % Set region selection to first value
    regionsel_Callback(hObject, eventdata, handles); % Go to regionsel
end        

[isOperationSuccessful, errorMessage] = handles.ccd.SetImageROI(str2double(get(handles.width,'String')),str2double(get(handles.height,'String')),str2double(get(handles.binning,'String'))); % Set ROI
if (~isOperationSuccessful)
    set(handles.messages,'String',char(errorMessage));
end

[width,height,binning,isOperationSuccessful, errorMessage] = handles.ccd.GetImageROI(); % Check ROI
if (~isOperationSuccessful)
    set(handles.messages,'String',errorMessage);
else
    set(handles.width,'String',num2str(width)); % Show width on screen
    set(handles.height,'String',num2str(height)); % Show height on screen
    set(handles.binning,'String',num2str(binning)); % Show binning on screen
    set(handles.messages,'String',['CCD dimensions: width = ' num2str(width) ' x height = ' num2str(height)]);
end

handles.size(1) = cellstr(get(handles.width,'String')); % Set handles.size(1) value to width
handles.size(2) = cellstr(get(handles.height,'String')); % Set handles.size(2) value to height

guidata(hObject, handles);
 
 function binning_Callback(hObject, ~, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binning as text
%        str2double(get(hObject,'String')) returns contents of binning as a double

binning = str2double(get(handles.binning,'String')); % Read binning from screen
if handles.ccd.IsAcquisitionRunning() == 1 % If acquisition is running
    [isOperationSuccessful, errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
    if (~isOperationSuccessful)
        set(handles.messages,'String',char(errorMessage));
    else
        [isOperationSuccessful, errorMessage] = handles.ccd.SetImageROI(str2double(get(handles.width,'String')),str2double(get(handles.height,'String')),binning); % Set ROI
        if (~isOperationSuccessful)
            set(handles.messages,'String',errorMessage);
        else

        end

        [width,height,binning,isOperationSuccessful, errorMessage] = handles.ccd.GetImageROI(); % Check ROI
        if (~isOperationSuccessful)
            set(handles.messages,'String',errorMessage);
        else
            set(handles.width,'String',num2str(width)); % Show width on screen
            set(handles.height,'String',num2str(height)); % Show height on screen
            set(handles.binning,'String',num2str(binning)); % Show binning on screen
        end
        handles.size(1) = cellstr(get(handles.width,'String')); % Set handles.size(1) value to width
        handles.size(2) = cellstr(get(handles.height,'String')); % Set handles.size(2) value to height
    end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function binning_CreateFcn(hObject, ~, ~)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slidertable_Callback(hObject, eventdata, handles)
% hObject    handle to slidertable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

datalog = get(handles.logtable,'UserData');
sizelog = size(datalog);
slipos = 1-get(handles.slidertable,'Value');
in = round((ceil(sizelog(1)/10)*10-10)*slipos+1);
if in+10-1 > sizelog(1)
    in = sizelog(1)-9;
end

set(handles.logtable,'data',datalog(in:in+10-1,:))

% --- Executes during object creation, after setting all properties.
function slidertable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidertable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when selected cell(s) is changed in logtable.
function logtable_CellSelectionCallback(~, eventdata, handles)
% hObject    handle to logtable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

tabledata = get(handles.logtable,'Data');

if size(eventdata.Indices,1) == 0 || size(eventdata.Indices,2) == 0
    return
else
    if eventdata.Indices(2) == 2
      set(handles.destinationh,'String',tabledata{eventdata.Indices(1),eventdata.Indices(2)}) ;
      set(handles.operationh,'Value',1) ;
    elseif eventdata.Indices(2) == 3
      set(handles.destinationv,'String',tabledata{eventdata.Indices(1),eventdata.Indices(2)}) ;
      set(handles.operationv,'Value',1) ;
    elseif eventdata.Indices(2) == 4
      set(handles.destinationd,'String',tabledata{eventdata.Indices(1),eventdata.Indices(2)}) ;
      set(handles.operationd,'Value',1) ;
    else
      return
    end
end

% --- Executes when entered data in editable cell(s) in logtable.
function logtable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to logtable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: String(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error String when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

shortdata = get(handles.logtable,'data'); % Read datalog from screen
datalog = get(handles.logtable,'UserData'); % Read datalog from screen
sizelog = size(datalog);

for i = 1:sizelog(1)
    if strcmp(shortdata(eventdata.Indices(1)),datalog(i,1)) == 1
        datalog(i,:) = shortdata(eventdata.Indices(1),:);
        break;
    end
end

handles.filelog = fopen([handles.path handles.root '.log'],'w'); % Open log file
for i = 1:size(datalog,1) % Loop for reading datalog values
   number = char(datalog(i,1));
   horizontal = char(datalog(i,2));
   vertical = char(datalog(i,3));
   stage = char(datalog(i,4));
   current = char(datalog(i,5));
   exposure = char(datalog(i,6));
   image = char(datalog(i,7));
   notes = char(datalog(i,8));
   fprintf(handles.filelog,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',number ,horizontal, vertical, stage, current, exposure, image, notes); % Write datalog on log file
end
fclose(handles.filelog); % Close log file

guidata(hObject, handles);

function scanstarth_Callback(~, ~, ~)
% hObject    handle to scanstarth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstarth as text
%        str2double(get(hObject,'String')) returns contents of scanstarth as a double


% --- Executes during object creation, after setting all properties.
function scanstarth_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstarth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scansteph_Callback(~, ~, ~)
% hObject    handle to scansteph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scansteph as text
%        str2double(get(hObject,'String')) returns contents of scansteph as a double


% --- Executes during object creation, after setting all properties.
function scansteph_CreateFcn(hObject, ~, ~)
% hObject    handle to scansteph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nsteph_Callback(~, ~, ~)
% hObject    handle to nsteph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsteph as text
%        str2double(get(hObject,'String')) returns contents of nsteph as a double


% --- Executes during object creation, after setting all properties.
function nsteph_CreateFcn(hObject, ~, ~)
% hObject    handle to nsteph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scanstartv_Callback(~, ~, ~)
% hObject    handle to scanstartv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstartv as text
%        str2double(get(hObject,'String')) returns contents of scanstartv as a double


% --- Executes during object creation, after setting all properties.
function scanstartv_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstartv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scanstepv_Callback(~, ~, ~)
% hObject    handle to scanstepv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstepv as text
%        str2double(get(hObject,'String')) returns contents of scanstepv as a double


% --- Executes during object creation, after setting all properties.
function scanstepv_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstepv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nstepv_Callback(~, ~, ~)
% hObject    handle to nstepv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nstepv as text
%        str2double(get(hObject,'String')) returns contents of nstepv as a double


% --- Executes during object creation, after setting all properties.
function nstepv_CreateFcn(hObject, ~, ~)
% hObject    handle to nstepv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scanstartd_Callback(~, ~, ~)
% hObject    handle to scanstartd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstartd as text
%        str2double(get(hObject,'String')) returns contents of scanstartd as a double


% --- Executes during object creation, after setting all properties.
function scanstartd_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstartd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scanstepd_Callback(~, ~, ~)
% hObject    handle to scanstepd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstepd as text
%        str2double(get(hObject,'String')) returns contents of scanstepd as a double


% --- Executes during object creation, after setting all properties.
function scanstepd_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstepd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nstepd_Callback(hObject, ~, handles)
% hObject    handle to nstepd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nstepd as text
%        str2double(get(hObject,'String')) returns contents of nstepd as a double

guidata(hObject, handles);

function numberscans_Callback(hObject, ~, handles)
% hObject    handle to numberscans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberscans as text
%        str2double(get(hObject,'String')) returns contents of numberscans as a double

handles.nscans = str2double(get(handles.numberscans,'String')); % Read number of scans from screen

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function numberscans_CreateFcn(hObject, ~, ~)
% hObject    handle to numberscans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function nstepd_CreateFcn(hObject, ~, ~)
% hObject    handle to nstepd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in beforeim.
function beforeim_Callback(~, ~, ~)
% hObject    handle to beforeim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beforeim


% --- Executes on button press in afterim.
function afterim_Callback(~, ~, ~)
% hObject    handle to afterim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of afterim

% --- Executes on button press in goscan.
function goscan_Callback(hObject, eventdata, handles)
% hObject    handle to goscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Check if autosave enabled
    if( not(get(handles.autosave, 'Value')) )
        uiwait(errordlg('Please toggle autosave', 'Autosave Needed', 'modal'));
        return;
    end
    % Check if background exists
    exposure = get(handles.exposure, 'String');
    nacq = get(handles.numberscans, 'String');
    path = [handles.path 'bg_exp' exposure 's_nacq' nacq];
    if( not(exist([path '\' handles.root '_avg.tif'], 'file')) )
        uiwait(errordlg('Background image with these parameters not found!', 'Background Missing', 'modal'));
        return;
    end
    
    mainpath = [handles.path handles.run]; % Create 1 and 2 folders as needed
    % Move to next free run
    while ( (exist([mainpath '1\'], 'dir')) )
        i = num2str(str2double(get(handles.runnum, 'String')) + 1);
        handles.run = ['Run' i '\'];
        set(handles.runnum, 'String', i);
        mainpath = [handles.path handles.run];
    end
    mkdir([mainpath '1']);
    mkdir([mainpath '2']);
    system(['copy ' path '\' handles.root '_avg.tif ' mainpath 'bg_exp' exposure 's_nacq' nacq '.tif']);
    set(handles.bgsubtract, 'UserData', imread([mainpath 'bg_exp' exposure 's_nacq' nacq '.tif'])); % Save background filepath to userdata
    set(handles.bgsubtract, 'Enable', 'on');
    
    disable_fields(handles);
    uiwait(msgbox('Be ready to check the shutter state for the first scan!'));
    handles.previmg = 'None'; % Used to plot image change over different images
    % Enable ccd acquisition if not already running
%     pause(0.1)
%     if handles.ccd.IsAcquisitionRunning() == 1 % Check if acquisition is running
%     else
%         [isOperationSuccessful,errorMessage] = handles.ccd.StartAcquisition(); % Start acquisition
%         if (~isOperationSuccessful)
%             set(handles.messages,'String',char(errorMessage));
%             pause(2);
%         else
%         end
%     end

    DS_init = str2double(get(handles.scanstartd, 'String')) / 1000; % Convert um to mm for the server
    step_size = str2double(get(handles.scanstepd, 'String')) / 1000; % Convert um to mm for the server
    nsteps = str2double(get(handles.nstepd, 'String'));
    DS_final = DS_init + step_size * (nsteps - 1); % Calculate the final position
    
    DS_minpos = str2double(GetStageMinimumPosition(handles.PIServer, 1));
    DS_maxpos = str2double(GetStageMaximumPosition(handles.PIServer, 1));

    % Check if input positions are valid
    if (DS_init < DS_minpos || DS_init > DS_maxpos)
        errordlg('Initial position is beyond the limits', 'Error')
        return
    end
    if (DS_final < DS_minpos || DS_final > DS_maxpos)
        errordlg('Final position is beyond the limits', 'Error')
        return
    end

    % Move to initial position
    set(handles.messages, 'String', 'Moving DS to initial position');
    move_ds(handles, DS_init);
    
    nscans = str2double(get(handles.numberscans, 'String')) * 2;
    imtot = nsteps * nscans;
    beforeim_enabled = get(handles.beforeim, 'Value');
    afterim_enabled = get(handles.afterim, 'Value');
    scans_per_ds = 1 + beforeim_enabled + afterim_enabled;
    imtot = imtot * scans_per_ds;
    handles.img1list = NaN; % Begin with null values
    handles.img2list = NaN;
    set(handles.pumpontxt, 'UserData', NaN); 
    set(handles.pumpofftxt, 'UserData', NaN); 
    
    k = 1;
    j = 1;
    for i = DS_init:step_size:DS_final
        if abortcheck(handles)
            break;
        end
        set(handles.messages, 'String', ['Beginning step ' num2str(j) ' of ' num2str(nsteps)]);
        % Move the delay stage to the next position
        move_ds(handles, i);
        % Check if abort
        if abortcheck(handles)
            break;
        end
        % If before image is enabled, take the image
        if beforeim_enabled
            handles.imtype = 'before';
            set(handles.messages, 'String', ['Taking before image (' num2str(k) ' of ' num2str(imtot) ')']); 
            %takeimage_ClickedCallback(hObject, eventdata, handles);
            %pause(1);
            k = k + 1;
        end
        if abortcheck(handles)
            break;
        end
        for loop_counter = 1:nscans
        % Take main image
            handles.imtype = 'main';
            set(handles.messages, 'String', ['Taking main image (' num2str(loop_counter) ' of ' ...
                num2str(nscans) ')']);
            image = takeimage_ClickedCallback(hObject, eventdata, handles);
            
            % If this is the first image, then prepare the matrix list
            if k == 1
                handles.img1list = NaN([size(image), nscans / 2]); % make a matrix of nscans/2 slots for images
                handles.img2list = handles.img1list;
                set(handles.pumpontxt, 'UserData', handles.img1list);
                set(handles.pumpofftxt, 'UserData', handles.img1list);
            end
            
            % Use loop counter to determine current image type
            if mod(loop_counter, 2)
                % Note: k is the number of images taken
                handles.img1list(:, :, (k + 1) / 2) = image;
                handles.image = mean(handles.img1list(:, :, (k + 1) / 2), 3); % Plot average image
            else
                handles.img2list(:, :, k / 2) = image;
                handles.image = mean(handles.img2list(:, :, k /2), 3);
            end
            
            % Check pumptoggle to determine which is pumpon
            if get(handles.pumptoggle, 'Value') 
                set(handles.pumpontxt, 'UserData', handles.img1list);
                set(handles.pumpofftxt, 'UserData', handles.img2list);
            else
                set(handles.pumpontxt, 'UserData', handles.img2list);
                set(handles.pumpofftxt, 'UserData', handles.img1list);
            end
            
            % Plot the current average and the delta image
            handles.image = uint16(handles.image);
            plotdiffraction(handles);
            
            %pause(1);
            k = k + 1;
            if abortcheck(handles)
                break;
            end
        end        
        
        if abortcheck(handles)
            break;
        end
        
        last_img = str2double(get(handles.imagename, 'String')) - 1;
        stage = get(handles.positiond, 'String');
        time = um_to_fs(stage, 2);
        compute_avg(handles, [mainpath '1\' time '\'], [handles.root '_' time '_'], ...
            last_img - 1:-2:(last_img - nscans), [mainpath '1\' handles.root '_' time '_avg.tif'] );
        compute_avg(handles, [mainpath '2\' time '\'], [handles.root '_' time '_'], ...
            last_img:-2:(last_img - nscans + 1), [mainpath '2\' handles.root '_' time '_avg.tif'] );
        
        % If after image is enabled, take the image
        if afterim_enabled
            handles.imtype = 'after';
            set(handles.messages, 'String', ['Taking after image (' num2str(k) ' of ' num2str(imtot) ')']);
            %takeimage_ClickedCallback(hObject, eventdata, handles);
            k = k + 1;
        end
        j = j + 1;
    end
%   handles.ccd.StopAcquisition(); % Stop acquisition

    enable_fields(handles);
    set(handles.settemp,'Enable','on'); % Enable set temperature
    
    if(abortcheck(handles))
        set(handles.messages, 'String', 'Aborted');
        set(handles.abortscan, 'Value', 0);
    else
        msg = 'Scan completed!';
        if(get(handles.autosave, 'Value')) % If autosave is enabled
            if (get(handles.pumptoggle, 'Value'))
                msg = [msg ' Saving with first image as pump ON'];
                onpath = [handles.path handles.run '1'];
                offpath = [handles.path handles.run '2'];
            else
                msg = [msg ' Saving with first image as pump OFF'];
                onpath = [handles.path handles.run '2'];
                offpath = [handles.path handles.run '1'];
            end
            system(['MOVE ' onpath ' ' handles.path handles.run 'Pump_On']);
            system(['MOVE ' offpath ' ' handles.path handles.run 'Pump_Off']);
            
        end
        
        set(handles.messages,'String', msg);

    end
    
    runnum = str2double(get(handles.runnum, 'String')); % Move runnum to the next available number
    while( exist([handles.path 'Run' num2str(runnum)], 'dir') ) 
        runnum = runnum + 1;
    end
    set(handles.runnum, 'String', num2str(runnum)); 
    handles.run = ['Run' num2str(runnum) '\']; % Update run directory
    handles.previmg = 'None';
    
    %set(handles.bgsubtract, 'UserData', NaN);
    
    guidata(hObject, handles);

function res = abortcheck(handles)
    % ABORTCHECK  Checks if the user wants to abort the scan
    % 
    % handles: handles object
    % res: 1 if the user wants to abmotioncontrolort, 0 otherwise

    res = 0;
    if get(handles.abortscan, 'Value') == 1
        res = 1;
    end

function move_ds(handles, position)
    % MOVE_DS  Moves the delay stage to the specified position
    %
    % DS: handles object
    % position: position to move the stage to

    % Move the stage to the specified position
    MoveStageToAbsolutePosition(handles.PIServer, 1, position);
    
    set(handles.targetd, 'String', num2str(position * 1000));
    % Wait until the stage is on target
    while strcmp(isStageOnTarget(handles.PIServer, 1), 'false') && get(handles.abortscan, 'Value') == 0
        pause(0.02);
        set(handles.positiond, 'String', num2str(round(str2double(GetStagePosition(handles.PIServer, 1)) * 1000)));
    end
    set(handles.positiond,'String', num2str(round(str2double(GetStagePosition(handles.PIServer, 1)) * 1000)));
    StopStage(handles.PIServer, 1);
    

function enable_fields(handles)
    for field=handles.fields_to_toggle
        set(field, 'Enable', 'on');
    end
    set(handles.abortscan, 'Enable', 'off');
%     start(handles.tmr); % Start timer

function disable_fields(handles)
    for field=handles.fields_to_toggle
        set(field, 'Enable', 'off');
    end
    set(handles.abortscan, 'Enable', 'on');
%     stop(handles.tmr); % Stop timer

function fs = um_to_fs(um, rounding)
    c = 0.299792458; % Speed of light is 0.3 um/fs
    
    % If input argument is a string, convert to a double first 
    if isa(um, 'char')
        fs = 2 * str2double(um) / c;
    else % Otherwise convert as normal
        fs = 2 * um / c; 
    end
    
    % If rounding is desired
    if exist('rounding', 'var')
        fs = round(fs, rounding);
    end
    
    % If input was a string, output should also be a string
    if isa(um, 'char')
        fs = num2str(fs);
    end

% --- Executes on button press in abortscan.
function abortscan_Callback(hObject, ~, handles)
% hObject    handle to abortscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'Value', 1);

guidata(hObject, handles);

function scanstatus_Callback(~, ~, ~)
% hObject    handle to scanstatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanstatus as text
%        str2double(get(hObject,'String')) returns contents of scanstatus as a double


% --- Executes during object creation, after setting all properties.
function scanstatus_CreateFcn(hObject, ~, ~)
% hObject    handle to scanstatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function messages_Callback(hObject, eventdata, handles)
% hObject    handle to messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of messages as text
%        str2double(get(hObject,'String')) returns contents of messages as a double

% --- Executes during object creation, after setting all properties.
function messages_CreateFcn(hObject, ~, ~)
% hObject    handle to messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function targettemp_Callback(~, ~, ~)
% hObject    handle to targettemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targettemp as text
%        str2double(get(hObject,'String')) returns contents of targettemp as a double


% --- Executes during object creation, after setting all properties.
function targettemp_CreateFcn(hObject, ~, ~)
% hObject    handle to targettemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in settemp.
function settemp_Callback(hObject, ~, handles)
% hObject    handle to settemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.ccd.IsAcquisitionRunning() == 1 % Check if acquisition is running
    set(handles.message, 'String', char('Stopping Acquisition...'));
    pause(0.1);
    [isOperationSuccessful,errorMessage] = handles.ccd.StopAcquisition(); % Stop acquisition
    if ~(isOperationSuccessful)
        
        set(handles.message, 'String', char(errorMessage));
        return;
    else
        set(handles.message, 'String', char('Stopping Acquisition...'));
        pause(0.5);
    end
end

stop(handles.tmr); % Stop timer

targettnum = str2double(get(handles.targettemp,'String')); % Read target temperature from screen

if isnan(targettnum) == 1 || targettnum < handles.mintemp || targettnum > handles.maxtemp % If temp is not a number or less than min or greater than max
    errordlg(['Temperature is not a valid, minimum: ' num2str(handles.mintemp) ', maximum: ' num2str(handles.maxtemp)], 'Error'); % Show error dialog
else
    [isOperationSuccessful, errorMessage] = handles.ccd.SetTargetCCDTemperature(targettnum); % Set new target temperature
    if (~isOperationSuccessful)
        set(handles.message,'String',char(errorMessage));
    end
    
    [trgTempr,isOperationSuccessful, errorMessage] = handles.ccd.GetTargetCCDTemperature(); % Check new target temperaure
    if (~isOperationSuccessful)
        set(handles.message,'String',char(errorMessage));
    else
        set(handles.targettemp,'String',num2str(trgTempr));
    end
end

start(handles.tmr); % Restart timer

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function actualtemp_CreateFcn(~, ~, ~)
% hObject    handle to actualtemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in shutterindic1.
function shutterindic1_Callback(~, ~, ~)
% hObject    handle to shutterindic1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shutterindic1


% --- Executes on button press in shutterindic2.
function shutterindic2_Callback(~, ~, ~)
% hObject    handle to shutterindic2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shutterindic2


% USES DAQ TO CHECK THE SHUTTER STATUS
function checkstatus_Callback(~, ~, handles)
% hObject    handle to exitmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

errorMessage = append('Software trying to check shutter status using DAQ, this should not be happening.')
uiwait(warndlg(errorMessage, 'DAQ  Warning', 'modal'))

% channels = '01';
% msg = {['DIGITALIN ' handles.devname(end) '1 ' channels]}; % Message to check status of the shutters
% [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
% hand = answer{1};
% hand = char(hand);
% hand = strrep(hand,char(13),'');
% hand = strrep(hand,char(10),'');
% newstr = strrep(hand,' ',';');
% newstr2 = '';
% for m = 1:numel(newstr)
%     if strcmp(newstr(m),';')
%         newstr2 = [newstr2 ';'];
%     else
%         if ~isnan(str2double(newstr(m)))
%             newstr2 = [newstr2 newstr(m)];
%         else
%             newstr2 = [newstr2 ''];
%         end
%     end
% end
% 
% newstr2 = newstr2(1:ceil(2*numel(channels)-1));
% if strcmp(newstr2(1),'S')
%     msg = {'QUIT'}; % Create a message to close communication with NIDAQ
%     [answer handles.input_socketni] = NIDAQ(handles.computeripNIDAQ,handles.portni,msg,handles.input_socketni); % Send the commands
% else
%     eval(['values = sum([' newstr ']);'])
%     binvalues = fliplr(dec2bin(values,numel(channels)));
%     stat = zeros(numel(channels),1);
%     for i = 1:numel(channels)
%         if strcmp(binvalues(i),'1') == 1
%             stat(i) = 0;
%         else
%             stat(i) = 1;
%         end
%     end
%     
%     set(handles.shutterindic1,'Value',stat(1)); % Show value of the shutter 1 on screen
%     set(handles.shutterindic2,'Value',stat(2)); % Show value of the shutter 2 on screen
% end

% --- Executes on slider movement.
function contrast_Callback(hObject, eventdata, handles)
% hObject    handle to contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
       % get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes during object creation, after setting all properties.
function contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function TmrFcn(src,event,handles) %Timer function
handles = guidata(handles);
[currTempr,isOperationSuccessful, errorMessage] = handles.ccd.GetCurrentCCDTemperature(); % Read current temperature from ccd server
set(handles.actualtemp,'String',num2str(currTempr,'%6.2f')); % Show temperature on screen
guidata(handles.guifig, handles);


function TmrFcn2(obj,event,handles) %Timer function

handles.camera = char(handles.camNames(get(handles.fireflysel,'Value')));
[isRunning,isOperationSuccessful,errorMessage] = handles.ffClient.IsAcquisitionRunning(handles.camera);
if (~isRunning)
    [isOperationSuccessful,errorMessage] = handles.ffClient.StartAcquisition(handles.camera);
    if(isOperationSuccessful)
        [newImage,isOperationSuccessful,errorMessage] = handles.ffClient.GetImageFromCamera(handles.camera);
    end
else
    [newImage,isOperationSuccessful,errorMessage] = handles.ffClient.GetImageFromCamera(handles.camera);
end

newImage = int32(newImage);
handles.image = newImage;
max = get(handles.contrast,'Value');
if max < 1
    max = 1;
end
set(handles.firefly,'CLim',[0 max])
set(handles.plot,'CData',handles.image);


% --- Executes on selection change in fireflysel.
function fireflysel_Callback(hObject, eventdata, handles)
% hObject    handle to fireflysel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fireflysel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fireflysel


% --- Executes during object creation, after setting all properties.
function fireflysel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fireflysel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over goscan.
function goscan_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to goscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on goscan and none of its controls.
function goscan_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to goscan (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function scannum_Callback(hObject, eventdata, handles)
% hObject    handle to scannum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scannum as text
%        str2double(get(hObject,'String')) returns contents of scannum as a double


% --- Executes during object creation, after setting all properties.
function scannum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scannum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function runnum_Callback(hObject, eventdata, handles)
% hObject    handle to runnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of runnum as text
%        str2double(get(hObject,'String')) returns contents of runnum as a double


% --- Executes during object creation, after setting all properties.
function runnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pumptoggle.
function pumptoggle_Callback(hObject, eventdata, handles)
% hObject    handle to pumptoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Swap order of pumpontxt and pumpofftxt
temp = get(handles.pumpontxt, 'String');
set(handles.pumpontxt, 'String', get(handles.pumpofftxt, 'String'));
set(handles.pumpofftxt, 'String', temp);

% Hint: get(hObject,'Value') returns toggle state of pumptoggle



function filename_posd_Callback(hObject, eventdata, handles)
% hObject    handle to filename_posd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_posd as text
%        str2double(get(hObject,'String')) returns contents of filename_posd as a double


% --- Executes during object creation, after setting all properties.
function filename_posd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_posd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
