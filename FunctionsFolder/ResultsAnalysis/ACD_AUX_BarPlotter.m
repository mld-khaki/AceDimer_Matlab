% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function BarPlots = ACD_AUX_BarPlotter_v16p0(Contributions,YLabels,FigH1,BarWidth,Title)
figure(FigH1);

BarHValues = Contributions;
BarHValuesTemp = [];
if size(BarHValues,1) < size(BarHValues,2) 
    BarHValues = BarHValues';
end

BarCount = length(Contributions);
BarHValuesVect = [BarHValues';1:length(BarHValues)];
[BarHValuesTemp.Value,BarHValuesTemp.Index] = sortrows(BarHValues,-1);
CombinedBarHValues = sum(sum((BarHValues)));

PlotCounter = 1;
BarPlots = [];
for featureCtr=1:BarCount
    BarPlots(end+1).PlotCounter = PlotCounter;
    BarPlots(end  ).Contribution = BarHValuesTemp.Value(featureCtr);
    BarPlots(end  ).PlotFeatureIndex = BarHValuesTemp.Index(featureCtr);
    Color = BarHValues(BarPlots(end).PlotFeatureIndex) ;
    Color = Color - min(BarHValues);
    Color = Color / max(BarHValues);
    BarPlots(end  ).FaceColor = [Color 0 1-Color];
    PlotCounter = PlotCounter + 1;
end

BarPlots = ACD_SortByStructField(BarPlots,'Contribution',1);
SelectedFeatures = ACD_ExtractStructField(BarPlots,'PlotFeatureIndex');

MaxStrLength = -1;
% BarPlots(6) = [];
for iCtr=1:length(BarPlots)
    %     iCtr
    barh(iCtr,BarPlots(iCtr).Contribution,'FaceColor',BarPlots(iCtr).FaceColor,'BarWidth',BarWidth);
    MaxStrLength = double(max([MaxStrLength strlength(YLabels{BarPlots(iCtr).PlotFeatureIndex})]));
    hold on;
end
yyaxis left;
grid on;
set(gca,'LineWidth',2);
yticks(1:length(BarPlots));
YPlotLabels = {};
MaxStrLength = double(MaxStrLength)+2;
for iCtr=2:length(BarPlots)
    Index = BarPlots(iCtr).PlotFeatureIndex;
	TempStr = YLabels{Index};
	TempStr = strrep(TempStr,'_','-');
	TempIndex = (BarCount-iCtr+1);
	switch TempIndex 
		case 1,	TempIndexStr = '1st';
		case 2, TempIndexStr = '2nd';
		otherwise
			TempIndexStr = [num2str(TempIndex) 'th'];
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
    YPlotLabels{iCtr} = sprintf('\\color{blue}%6.2f%',BarPlots(iCtr).Contribution*100/(CombinedBarHValues));
end
yticklabels(YPlotLabels);

ContribMax = max(ACD_ExtractStructField(BarPlots,'Contribution'))*1.1;
ContribMax = ceil(ContribMax*100)/100;
axis([0 ContribMax 0 length(BarPlots)+1]);
xticks([]);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontName','Courier New','FontWeight','bold','FontSize',11);
end
