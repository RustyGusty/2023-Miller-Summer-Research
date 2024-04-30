function scanloop (handles, DS_init, DS_fin, nsteps, varargin)
    % SCANLOOP  Runs the ccd with the delay stage from DS_init to DS_fin in nsteps steps
    %
    % handles: GUI handles (namely connected ccd and DS)
    % DS_init:
    % DS_fin: is the final value of the parameter to be scanned
    % nsteps: is the number of steps of the scan
    % varargin: additional arguments needed for the scan, if any

    % Check if input positions are valid
    if (DS_init < GetStageMinimumPosition(handles.PIServer, 1) || DS_init > GetStageMaximumPosition(handles.PIServer, 1))
        errordlg('Initial position is beyond the limits', 'Error')
        return
    end
    if (DS_fin < GetStageMinimumPosition(handles.PIServer, 1) || DS_fin > GetStageMaximumPosition(handles.PIServer, 1))
        errordlg('Final position is beyond the limits', 'Error')
        return
    end

    move_stage(handles.PIServer, DS_init);

    for i = linspace(DS_init, DS_fin, nsteps)
        % Move the delay stage to the next position
        move_ds(handles.PIServer, i);
        % Acquire the image (TODO)

        % Update GUI Parameters (TODO)
    end
end

function move_ds(DS, position)
    % MOVE_DS  Moves the delay stage to the specified position
    %
    % DS: delay stage object
    % position: position to move the stage to

    % Move the stage to the specified position
    MoveStageToAbsolutePosition(DS, 1, position);

    % Wait until the stage is on target
    while strcmp(isStageOnTarget(DS, 1), 'false')
        pause(0.02);
        set(handles.positiond, 'String', num2str(round(str2double(GetStagePosition(DS, 1)) * 1000)));
    end
end