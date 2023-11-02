% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.1 $  $Date: 2021/05/25  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $
% $Revision: 4.0.0 $  $Date: _2022_06_14___23_38_10_Tue  Generalized plotter $


function BarPlots = ACD_AUX_BarPlotter(Contributions,YLabels,FigH1,BarWidth,Title,SortEnabled,NTopContributors,SeqNum)
if ~exist('SeqNum','var')
    SeqNum = 1:NTopContributors;
end

if FigH1 ~= -1
    figure(FigH1);
else
end

BarHValues = Contributions;
BarHValuesTemp = [];
if size(BarHValues,1) < size(BarHValues,2) 
    BarHValues = BarHValues';
end

if ~exist('SortEnabled','var')
    SortEnabled = true;
end
Contributions2 = BarHValues - nanmin(BarHValues);


BarCount = NTopContributors;
BarHValuesVect = [BarHValues';1:length(BarHValues)];
if SortEnabled == true
    [BarHValuesTemp.Value,BarHValuesTemp.Index] = sortrows(BarHValues,-1);
else
    BarHValuesTemp.Value = BarHValues;
    BarHValuesTemp.Index = 1:length(BarHValues);
end
CombinedBarHValues = nansum(nansum((BarHValues)));

PlotCounter = 1;
BarPlots = [];
for featureCtr=1:BarCount
    BarPlots(end+1).PlotCounter = PlotCounter;
    BarPlots(end  ).Contribution = BarHValuesTemp.Value(featureCtr);
    BarPlots(end  ).PlotFeatureIndex = BarHValuesTemp.Index(featureCtr);
    Color = Contributions2(BarPlots(end).PlotFeatureIndex) ;
    Color = Color - min(Contributions2);
    Color = Color / max(Contributions2);
    if isnan(Color)
        ColorVect = [0 0 0];
    else
        ColorVect = [Color 0 1-Color];
    end
    BarPlots(end  ).FaceColor = ColorVect;
    PlotCounter = PlotCounter + 1;
end

if SortEnabled == true
    BarPlots = ACD_SortByStructField(BarPlots,'Contribution',1);
end

MaxStrLength = -1;
% BarPlots(6) = [];
for iCtr=1:length(BarPlots)
    %     iCtr
    if ~isnan(BarPlots(iCtr).Contribution)
        barh(iCtr,BarPlots(iCtr).Contribution,'FaceColor',BarPlots(iCtr).FaceColor,'BarWidth',BarWidth);
    else
        barh(iCtr,0,'FaceColor',BarPlots(iCtr).FaceColor,'BarWidth',BarWidth);
    end
    MaxStrLength = double(max([MaxStrLength strlength(YLabels{BarPlots(iCtr).PlotFeatureIndex})]));
    hold on;
end
yyaxis left;
grid on;
set(gca,'LineWidth',2);
yticks(1:length(BarPlots));
YPlotLabels = {};
MaxStrLength = double(MaxStrLength)+2;
for iCtr=1:length(BarPlots)
    Index = BarPlots(iCtr).PlotFeatureIndex;
%     if isnan(Contributions(Index))
%         TempStr = "";
%     else
	    TempStr = YLabels{Index};
%     end
	TempStr = strrep(TempStr,'_','-');
    Pointer = (BarCount-iCtr+1);
	TempIndex = num2str((Pointer));
	switch TempIndex 
		case '1'
            TempIndexStr = '1st';
		case '2'
            TempIndexStr = '2nd';
		otherwise
			TempIndexStr = [TempIndex 'th'];
	end
    YPlotLabels{iCtr} = sprintf(['\\color{red}%s) \\color{black}%' num2str(MaxStrLength) 's'],TempIndexStr,TempStr);
end
yticklabels(YPlotLabels);
axis square;
axis([0 max(ACD_ExtractStructField(BarPlots,'Contribution')) 0 length(BarPlots)+1]);
yyaxis right;
axis([0 max(ACD_ExtractStructField(BarPlots,'Contribution')) 0 length(BarPlots)+1]);
axis square;
yticks(1:length(BarPlots));
YPlotLabels = {};
for iCtr=1:length(BarPlots)
    if isnan(BarPlots(iCtr).Contribution*100)
        YPlotLabels{iCtr} = "";
    else
        YPlotLabels{iCtr} = sprintf('\\color{blue}%6.2f%',BarPlots(iCtr).Contribution*100/(CombinedBarHValues));
    end
end
yticklabels(YPlotLabels);

ContribMax = max(ACD_ExtractStructField(BarPlots,'Contribution'))*1.1;
ContribMax = ceil(ContribMax*100)/100;
axis([0 ContribMax 0 length(BarPlots)+1]);
xticks([]);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontName','Courier New','FontWeight','bold','FontSize',11);

if exist('Title','var')
    title(Title);
end
end
