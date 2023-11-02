% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.1 $  $Date: 2021/05/25  11:05 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function TotalConMat = ACD_ConfusionMatrixVisualizer_v3p0p0(InputResults,Title,InpClassStrings,Top_N_Percent)

Options = struct;

if exist('Title','var')
	Options.Dataset = Title;
end

InpRes = InputResults(end);

Options.GoodAccuracyThreshold = Top_N_Percent;

Options.ClassLabels = InpClassStrings;
Options.ClassLabels(end+1:2*end) = Options.ClassLabels(end:-1:1);

AccuracyVector = InpRes.AccuraciesVector;

MaxAccThreshold = Options.GoodAccuracyThreshold * nanmax(InpRes.AccuraciesVector);

GoodOnes = find(AccuracyVector > MaxAccThreshold);
fprintf('\nThe good classifiers'' count is: %u\n',length(GoodOnes));
Sample = InpRes.ConfusionMatrices(1).Fold01;

TotalConMat = zeros(size(Sample));

BaselineValue = ACD_ContributionBaseValue_v3p0p0(InpRes.ClassesData.InputClasses);
Count = 0;
for iCtr=1:length(GoodOnes) , GoodInd = GoodOnes(iCtr);
    Count = Count+1;
    
    for fCtr=1:InpRes.Options.FoldCount,	fStr = sprintf('Fold%02u',fCtr);
        LastOne = InpRes.ConfusionMatrices(GoodInd).(fStr);
%         nansum(LastOne,1)
        AddedMatrix = LastOne'* (AccuracyVector(GoodInd) - BaselineValue);% ./ nansum(LastOne(:));
        AddedMatrix(AddedMatrix < 0) = 0;
    end
    TotalConMat = TotalConMat + AddedMatrix;
end

% TotalConMat = 100*TotalConMat ./ nansum(TotalConMat,1);
for iCtr=1:size(TotalConMat,1)
    TotalConMat(iCtr,:) = 100*TotalConMat(iCtr,:) ./ nansum(TotalConMat(iCtr,:));
end

% colormap('default'
tmpOptions = [];
tmpOptions.NumberFormat = '%5.2f%%';
tmpOptions.FontSize = 12;
tmpOptions.Displacement = 1.5;
tmpOptions.ColorMap = ACD_ColorMapHeat();

FigH = figure;
FigH.Position = 50 + [0,0,700,500];

ACD_ImagescWithNumbers(TotalConMat,tmpOptions)

% imagesc(TotalConMat)
% colormap('jet');
h = colorbar;
ylabel(h, 'Accuracy in Predicting Class');
caxis([nanmin(TotalConMat(:)) nanmax(TotalConMat(:))]);
% axis equal;
title(sprintf('Confusion Matrix for\n%s Classification\nAverage Top Classifier''s Accuracy = \\color{red}%5.2f%%',Options.Dataset,nanmean(AccuracyVector(GoodOnes))*100));

%%
ClassCount = nansum(LastOne,2);
ClassCount = sprintf('%u Instances',ClassCount(1)*InpRes.ClassesData.MetaData.FoldCnt);

RTWT_Real = {};
RTWT_Pred = {};
for iCtr=1:length(Options.ClassLabels)
    RTWT_Pred{iCtr} = ['\bfPredicted\newline' Options.ClassLabels{iCtr}]; %#ok<*AGROW>
    RTWT_Real{iCtr} = [' {\bfClass}\newline '   '{\bf' Options.ClassLabels{iCtr} '}' '\newline' ClassCount '\newlineEqual to 100%'];
end

hold on;
for iCtr=0.5:length(Options.ClassLabels)+1.5
    plot([iCtr iCtr],[0 length(Options.ClassLabels)+1],'k','LineWidth',1);
    plot([0 length(Options.ClassLabels)+1],[iCtr iCtr],'k','LineWidth',1);
end

set(gca,'xaxisLocation','top')
xticks(1:length(Options.ClassLabels));
xticklabels(RTWT_Pred);
yticks(1:length(Options.ClassLabels));
yticklabels(RTWT_Real);
end
