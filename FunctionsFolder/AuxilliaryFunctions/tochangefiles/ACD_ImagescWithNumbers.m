function Out = ACD_ImagescWithNumbers(InpIMG,Opts)
OptionsOrg = [];
OptionsOrg.NumberFormat = '%5.2f';
OptionsOrg.FontSize = 18;
OptionsOrg.Displacement = 0.5;
OptionsOrg.ColorMap = 'jet';

if ~exist('Opts','var')
    Opts = OptionsOrg;
end

OrgFields = fieldnames(OptionsOrg);
for iCtr=1:length(OrgFields)
    if ~isfield(Opts,OrgFields{iCtr})
        Opts.(OrgFields{iCtr}) = OptionsOrg.(OrgFields{iCtr});
    end
end

ColorMap = colormap(Opts.ColorMap);
image(ACD_imshow2imagesc(InpIMG,ColorMap));
colormap(ColorMap);
CurTexts = {};
for iCtr = 1:size(InpIMG,1)
    for jCtr = 1:size(InpIMG,2)
        [Color] = ACD_GetEquivalentColorFromColorMAP(ColorMap,InpIMG,InpIMG(jCtr,iCtr));
        %         Color = (nanmean(Color(:))*[1 1 1];
        CurTexts{end+1} = text(iCtr-Opts.Displacement+1, jCtr, sprintf([' ' Opts.NumberFormat],InpIMG(jCtr,iCtr)), ...
            'FontWeight','bold', 'FontSize', Opts.FontSize,'Color',imcomplement(Color));
    end
end

axis square;

end
% everytime you zoom in, this function is executed
function zoomCallBack(~, evd)
% Since i expect to zoom in ax(4)-ax(3) gets smaller, so fontsize
% gets bigger.
ax = axis(evd.Axes); % get axis size
% change font size accordingly
for kCtr=1:length(CurTexts)
    set(CurTexts{kCtr},'FontSize',40/(ax(4)-ax(3)));
end
end
