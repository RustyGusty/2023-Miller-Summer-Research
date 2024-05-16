function plotdiffraction(handles)

 if get(handles.autoscale,'Value')
     contmin = uint16(min(handles.image(:))) ;
     contmax = uint16(max(handles.image(:))) ;
 else
     contmin = uint16(get(handles.contmin,'Value')) ;
     contmax = uint16(get(handles.contmax,'Value')) ;
 end
 
axes(handles.axes1) ;

if( get(handles.bgsubtract, 'Value') && not(all(all(isnan(get(handles.bgsubtract, 'UserData'))))) ) % If want to enable background subtracting
    imagesc(handles.image - get(handles.bgsubtract, 'UserData'), [contmin contmax]);
else
    imagesc(handles.image, [contmin contmax]);
end

if( isfield(handles, 'previmg') && not(strcmp(handles.previmg, 'None' )) )
    
    previmg = imread(handles.previmg);
    deltaimg = handles.image - previmg;
    precision = class(previmg);

    set(handles.axes2,'UserData',1)
    
    axes(handles.axes2);
    imagesc(deltaimg, [contmin contmax]);

end