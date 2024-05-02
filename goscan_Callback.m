function goscan_Callback (hObject, eventdata, handles)
    % GOSCAN_CALLBACK  Runs the ccd with the delay stage looping given the initial position, step size, and number of steps

    disable_fields(handles);

    % Enable ccd acquisition if not already running
    pause(0.1)
    if handles.ccd.IsAcquisitionRunning() == 1 % Check if acquisition is running
    else
        [isOperationSuccessful,errorMessage] = handles.ccd.StartAcquisition(); % Start acquisition
        if (~isOperationSuccessful)
            set(handles.messages,'String',char(errorMessage));
        else
        end
    end

    DS_init = str2double(get(handles.scanstartd)) / 1000; % Convert um to mm for the server
    step_size = str2double(get(handles.scanstepd)) / 1000; % Convert um to mm for the server
    nsteps = str2double(get(handles.nstepd));
    DS_final = DS_init + step_size * (nsteps - 1); % Calculate the final position

    % Check if input positions are valid
    if (DS_init < GetStageMinimumPosition(handles.PIServer, 1) || DS_init > GetStageMaximumPosition(handles.PIServer, 1))
        errordlg('Initial position is beyond the limits', 'Error')
        return
    end
    if (DS_fin < GetStageMinimumPosition(handles.PIServer, 1) || DS_fin > GetStageMaximumPosition(handles.PIServer, 1))
        errordlg('Final position is beyond the limits', 'Error')
        return
    end

    % Move to initial position
    move_ds(handles, DS_init);

    imtot = nsteps * handles.nscans;
    beforeim_enabled = get(handles.beforeim, 'Value');
    afterim_enabled = get(handles.afterim, 'Value');
    scans_per_ds = 1 + before_im_enabled + after_im_enabled;
    imtot = imtot * scans_per_ds;
    k = 1;
    for loop_counter = 1:imtot
        if abortcheck(handles)
            break;
        end
        for i = DS_init:step_size:DS_final
            % Notify the user of the current loop count
            set(handles.messages, 'String', ['Scan ' num2str((loop_counter-1) * nsteps + i) ' of ' num2str(nsteps * handles.nscans)]);
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
                k = k + 1;
            end
            if abortcheck(handles)
                break;
            end
            % Open pump shutter
            openshutter2_ClickedCallback(hObject, eventdata, handles);
            % Take main image
            handles.imtype = 'main';
            set(handles.messages, 'String', ['Taking main image (' num2str(k) ' of ' num2str(imtot) ')']);
            takeimage_ClickedCallback(hObject, eventdata, handles);
            k = k + 1;
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
        end
    end
    handles.ccd.StopAcquisition(); % Stop acquisition

    enable_fields(handles);
    set(handles.settemp,'Enable','on'); % Enable set temperature
    set(handles.messages,'String','Scan completed!');
    guidata(hObject, handles);
end

function res = abortcheck(handles)
    % ABORTCHECK  Checks if the user wants to abort the scan
    % 
    % handles: handles object
    % res: 1 if the user wants to abort, 0 otherwise

    res = 0;
    if get(handles.abortscan, 'Value') == 1
        res = 1;
        set(handles.abortscan, 'Value', 0);
    end
end

function move_ds(handles, position)
    % MOVE_DS  Moves the delay stage to the specified position
    %
    % DS: handles object
    % position: position to move the stage to

    % Move the stage to the specified position
    MoveStageToAbsolutePosition(DS, 1, position);

    % Wait until the stage is on target
    while strcmp(isStageOnTarget(DS, 1), 'false') && get(handles.abortscan, 'Value') == 0
        pause(0.02);
        set(handles.positiond, 'String', num2str(round(str2double(GetStagePosition(DS, 1)) * 1000)));
    end
    set(handles.positiond, 'String', num2str(round(str2double(GetStagePosition(DS, 1)) * 1000)));
end

function enable_fields(handles)
    set(handles.width,'Enable','on'); % Enable width
    set(handles.height,'Enable','on'); % Enable height
    set(handles.fullchip,'Enable','on'); % Enable fullchip
    set(handles.roi,'Enable','on'); % Enable roi
    set(handles.regionsel,'Enable','on'); % Enable region selection
    set(handles.god,'Enable','on'); % Enable go stage
    set(handles.killd,'Enable','on'); % Enable kill stage
    set(handles.homed,'Enable','on'); % Enable home stage
    set(handles.resetd,'Enable','on'); % Enable reset stage
    start(handles.tmr); % Start timer
end

function disable_fields(handles)
    set(handles.width,'Enable','off'); % Disable width
    set(handles.height,'Enable','off'); % Disable height
    set(handles.fullchip,'Enable','off'); % Disable fullchip
    set(handles.roi,'Enable','off'); % Disable roi
    set(handles.regionsel,'Enable','off'); % Disable region selection
    set(handles.god,'Enable','off'); % Disable go stage
    set(handles.killd,'Enable','off'); % Disable kill stage
    set(handles.homed,'Enable','off'); % Disable home stage
    set(handles.resetd,'Enable','off'); % Disable reset stage
    stop(handles.tmr); % Stop timer
end