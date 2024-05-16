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