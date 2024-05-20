function handles = plotdiffraction(handles)
if(isempty(handles.image))
    return;
end

img = handles.image;

axes(handles.axes1) ;

onprogress = str2double(get(handles.onprogress, 'String'));
offprogress = str2double(get(handles.offprogress, 'String'));
ispumpon = get(handles.onindicator, 'Value');

if get(handles.bgsubtract, 'Value') && not(isempty(get(handles.bgsubtract, 'UserData'))) % If want to enable background subtracting
    if( get(handles.bgavg, 'Value')) % If want to subtract the running average
       nimage = max(onprogress, offprogress);
       pumpbglist = get(handles.pumpongeneric, 'UserData'); % List of all pump background images
       bglist = get(handles.bgavg, 'UserData'); % list of all background images
       pumpbghandles.image = mean(pumpbglist(:, :, 1:nimage), 3);
       bghandles.image = mean(bglist(:, :, 1:nimage), 3);
    else
       bghandles.image = get(handles.bgsubtract, 'UserData'); % average image
       pumpbghandles.image = bghandles.image(:, :, 2); % If pump on, get pumpbg
       bghandles.image = bghandles.image(:, :, 1);
    end
    
    bghandles.image = uint16(bghandles.image);
    pumpbghandles.image = uint16(pumpbghandles.image);
    % Here, bghandles.image is the generic bghandles.image, and pumpbghandles.image is the pump bghandles.image
    if ispumpon
       if get(handles.pumpongeneric, 'Value')
           handles.image = handles.image - bghandles.image; % Additional subtraction of generic
       end
       handles.image = handles.image - pumpbghandles.image;
    else
        handles.image = handles.image - bghandles.image;
    end
end

 if get(handles.autoscale,'Value')
     contmin = uint16(min(handles.image(:))) ;
     contmax = uint16(max(handles.image(:))) ;
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
if not(isnan(pumponlist(:, :, 1))) & not(isnan(pumpofflist(:, :, 1)))
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

