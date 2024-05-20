function handles = plotrectangle(handles)

% Check if statistic rectangle has been selected
coords = get(handles.statistic, 'UserData');
if ~isempty(coords)
    xin = coords(1, 1);
    xfin = coords(2, 1);
    yin = coords(1, 2);
    yfin = coords(2, 2);

    axes(handles.axes1) ;
    handles.rectangle = rectangle('Position',[xin yin xfin-xin yfin-yin], 'EdgeColor','r','LineWidth',1);
    
    statmat = double(handles.image);
    
    % If mask has been enabled, ignore those pixels
    maskcoords = get(handles.maskselect, 'UserData');
    if ~isempty(maskcoords)
        maskxin = maskcoords(1, 1);
        maskxfin = maskcoords(2, 1);
        maskyin = maskcoords(1, 2);
        maskyfin = maskcoords(2, 2);
        statmat(maskyin:maskyfin,maskxin:maskxfin) = NaN;
    end
    statmat = statmat(yin:yfin, xin:xfin);
    resstatmat = reshape(statmat,numel(statmat),1);
    set(handles.smin,'String',num2str(min(resstatmat),'%5.0f'));
    set(handles.smax,'String',num2str(max(resstatmat),'%5.0f'));
    set(handles.smean,'String',num2str(mean(resstatmat, 'omitnan'),'%5.0f'));
    set(handles.sstd,'String',num2str(std(resstatmat, 'omitnan'),'%5.0f'));
end