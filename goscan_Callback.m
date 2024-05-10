% --- Executes on button press in goscan.
function goscan_Callback(hObject, eventdata, handles)
    % hObject    handle to goscan (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
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
        k = 1;
        for loop_counter = 1:nscans
            if abortcheck(handles)
                break;
            end
            j = 1;
            for i = DS_init:step_size:DS_final
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
                    takeimage_ClickedCallback(hObject, eventdata, handles);
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
                    handles.previmg = takeimage_ClickedCallback(hObject, eventdata, handles);
                    %pause(1);
                    k = k + 1;
                    if abortcheck(handles)
                        break;
                    end
                end
                if abortcheck(handles)
                    break;
                end
                % If after image is enabled, take the image
                if afterim_enabled
                    handles.imtype = 'after';
                    set(handles.messages, 'String', ['Taking after image (' num2str(k) ' of ' num2str(imtot) ')']);
                    takeimage_ClickedCallback(hObject, eventdata, handles);
                    k = k + 1;
                end
                j = j + 1;
            end
        end
    %   handles.ccd.StopAcquisition(); % Stop acquisition
    
        enable_fields(handles);
        set(handles.abortscan, 'Enable', 'off');
        set(handles.settemp,'Enable','on'); % Enable set temperature
        runnum = str2double(get(handles.runnum, 'String')); % Move runnum to the next available number
        while( exist([handles.path 'Run' num2str(runnum)], 'dir') ) 
            runnum = runnum + 1;
        end
        set(handles.runnum, 'String', num2str(runnum)); 
        handles.run = ['Run' num2str(runnum) '\']; % Update run directory
        if(abortcheck(handles))
            set(handles.messages, 'String', 'Aborted');
            set(handles.abortscan, 'Value', 0);
        else
            set(handles.messages,'String','Scan completed!');
        end
        guidata(hObject, handles);
    
    function res = abortcheck(handles)
        % ABORTCHECK  Checks if the user wants to abort the scan
        % 
        % handles: handles object
        % res: 1 if the user wants to abort, 0 otherwise
    
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
    
    % --- Executes on button press in abortscan.
    function abortscan_Callback(hObject, ~, handles)
    % hObject    handle to abortscan (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    set(hObject, 'Value', 1);
    
    guidata(hObject, handles);