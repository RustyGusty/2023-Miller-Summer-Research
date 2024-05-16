function handles = plotmask(handles)

xin = min(round(handles.maska(1)),round(handles.maska(2)));
xfin = max(round(handles.maska(1)),round(handles.maska(2)));
yin = min(round(handles.maskb(1)),round(handles.maskb(2)));
yfin = max(round(handles.maskb(1)),round(handles.maskb(2)));

axes(handles.axes1) ;
handles.maskrectangle = rectangle('Position',[xin yin xfin-xin yfin-yin], 'EdgeColor','r', 'FaceColor', 'k', 'LineWidth',1);

set(handles.maskselect,'UserData',[xin, xfin, yin, yfin]);