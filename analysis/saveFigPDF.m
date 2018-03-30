function saveFigPDF(h,sz,savepath);

% function saveFigPDF(h,sz,savepath);
% h = figure handle;
% sz = 2 element vector of width x height in pixels
% savepath = the filename (string)

if size(sz,1) == 2
    sz = sz';
end

set(h,'PaperPositionMode','auto');         
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','points');
set(h,'PaperSize',[sz]);
set(h,'Position',[0 0 sz]);
print(h,savepath,'-dpdf','-r300');

