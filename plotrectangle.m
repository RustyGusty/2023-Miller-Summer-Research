function handles = plotrectangle(handles)

xin = min(round(handles.a(1)),round(handles.a(2)));
xfin = max(round(handles.a(1)),round(handles.a(2)));
yin = min(round(handles.b(1)),round(handles.b(2)));
yfin = max(round(handles.b(1)),round(handles.b(2)));

axes(handles.axes1) ;
handles.rectangle = rectangle('Position',[xin yin xfin-xin yfin-yin], 'EdgeColor','r','LineWidth',1);
statmat = handles.image(yin:yfin,xin:xfin);
resstatmat = reshape(statmat,numel(statmat),1);
set(handles.smin,'String',num2str(min(resstatmat),'%5.0f'));
set(handles.smax,'String',num2str(max(resstatmat),'%5.0f'));
set(handles.smean,'String',num2str(mean(resstatmat),'%5.0f'));
set(handles.sstd,'String',num2str(std(double(resstatmat)),'%5.0f'));

set(handles.statistic,'UserData',[xin, xfin, yin, yfin]);