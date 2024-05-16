function plotdiffraction(handles)

 if get(handles.autoscale,'Value')
     contmin = uint16(min(handles.image(:))) ;
     contmax = uint16(max(handles.image(:))) ;
 else
     contmin = uint16(get(handles.contmin,'Value')) ;
     contmax = uint16(get(handles.contmax,'Value')) ;
 end
 
axes(handles.axes1) ;

if( get(handles.bgsubtract, 'Value') ) % If want to enable background subtracting
    handles.image = handles.image - get(handles.bgsubtract, 'UserData');
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
    for off_i = 1:size(pumponlist, 3)
        if isnan(pumpofflist(:, :, off_i))
            break
        end
    end
    
    on_avg = mean(pumponlist(:, :, 1:on_i-1), 3);
    off_avg = mean(pumpofflist(:, :, 1:off_i-1), 3);
    
    imagesc(on_avg - off_avg, [contmin contmax]);
end