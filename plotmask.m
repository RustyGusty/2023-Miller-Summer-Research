function handles = plotmask(handles)

coords = get(handles.maskselect, 'UserData');
if ~isempty(coords)
    xin = coords(1, 1);
    xfin = coords(2, 1);
    yin = coords(1, 2);
    yfin = coords(2, 2);
    axes(handles.axes1);
    handles.maskrectangle = rectangle('Position',[xin yin xfin-xin yfin-yin], 'EdgeColor','r', 'FaceColor', 'k', 'LineWidth',1);
end