function handles = plotdiffraction(handles)
if(isempty(handles.image))
    return;
end

axes(handles.axes1) ;

onprogress = str2double(get(handles.onprogress, 'String'));
offprogress = str2double(get(handles.offprogress, 'String'));
ispumpon = get(handles.onindicator, 'Value');

if get(handles.bgsubtract, 'Value') && not(isempty(get(handles.bgsubtract, 'UserData'))) % If want to enable background subtracting
    if( get(handles.bgavg, 'Value')) % If want to subtract the running average
       nimage = max(onprogress, offprogress);
       pumpbglist = get(handles.pumpongeneric, 'UserData'); % List of all pump background images
       bglist = get(handles.bgavg, 'UserData'); % list of all background images
       if not(isempty(pumpbglist) || isempty(bglist)) % Failsafe in case the individual lists don't exist
            pumpbgimg = mean(pumpbglist(:, :, 1:nimage), 3);
            bgimg = mean(bglist(:, :, 1:nimage), 3);
       else
              bgimg = get(handles.bgsubtract, 'UserData'); % average image
              pumpbgimg = bgimg(:, :, 2); % If pump on, get pumpbg
              bgimg = bgimg(:, :, 1);
       end
    else
       bgimg = get(handles.bgsubtract, 'UserData'); % average image
       pumpbgimg = bgimg(:, :, 2); % If pump on, get pumpbg
       bgimg = bgimg(:, :, 1);
    end
    
    bgimg = uint16(bgimg);
    pumpbgimg = uint16(pumpbgimg);
    % Here, bgimg is the generic bgimg, and pumpbgimg is the pump bgimg
    if ispumpon
       if get(handles.pumpongeneric, 'Value')
           handles.image = handles.image - bgimg; % Additional subtraction of generic
       end
       handles.image = handles.image - pumpbgimg;
    else
        handles.image = handles.image - bgimg;
    end
end

 if get(handles.autoscale,'Value')
     contmin = uint16(min(handles.image(:))) ;
     contmax = uint16(max(handles.image(:))) ;
     set(handles.contmin,'Value',contmin);
     set(handles.contmax,'Value',contmax);
 else
     contmin = uint16(get(handles.contmin,'Value')) ;
     contmax = uint16(get(handles.contmax,'Value')) ;
 end
 
if contmax <= contmin
    contmax = contmin + 1;
end

imagesc(handles.image, [contmin contmax]);

plotmask(handles); % Replot mask
plotrectangle(handles); % Reset statistic with desired background subtraction

axes(handles.axes2);

% Check if both pumpontxt and pumpofftxt have filled their first cell to
% begin subtraction
pumponlist = get(handles.pumpontxt, 'UserData');
pumpofflist = get(handles.pumpofftxt, 'UserData');
if not(isempty(pumponlist)) && not(isempty(pumpofflist))
    % Set on_i to the first NaN image
    for on_i = 1:size(pumponlist, 3)
        if isnan(pumponlist(:, :, on_i))
            break
        end
    end
    for off_i = 1:size(pumpofflist, 3)
        if isnan(pumpofflist(:, :, off_i))
            break
        end
    end
    
    on_avg = mean(pumponlist(:, :, 1:on_i-1), 3);
    off_avg = mean(pumpofflist(:, :, 1:off_i-1), 3);
    diff = on_avg - off_avg;
    contmin = uint16(min(diff(:))) ;
    contmax = uint16(max(diff(:))) ;
    if contmax <= contmin
        contmax = contmin + 1;
    end
    imagesc(on_avg - off_avg, [contmin contmax]);
end
