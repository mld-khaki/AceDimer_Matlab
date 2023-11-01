% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function TotalConMat = ACD_ConfusionMatrixVisualizer_v16p0(InputResults,Title,InpClassStrings,Top_N_Percent)

Options = struct;

if exist('Title','var')
	Options.Dataset = Title;
end
Options.GoodAccuracyThreshold = Top_N_Percent;

Options.ClassLabels = InpClassStrings;
Options.ClassLabels(end+1:2*end) = Options.ClassLabels(end:-1:1);

AccuracyVector = InputResults.AccuraciesVector;

MaxAccThreshold = Options.GoodAccuracyThreshold * nanmax(InputResults.AccuraciesVector);

GoodOnes = find(AccuracyVector > MaxAccThreshold);
fprintf('\nThe good classifiers'' count is: %u\n',length(GoodOnes));
Sample = InputResults.ConfusionMatrices(1).Fold01;

TotalConMat = zeros(size(Sample));

BaselineValue = ACD_ContributionBaseValue_v16p0(InputResults.ClassesData.InputClasses);
Count = 0;
for iCtr=1:length(GoodOnes)
    Count = Count+1;
    
    for fCtr=1:InputResults.Options.FoldCount,	fStr = sprintf('Fold%02u',fCtr);
        LastOne = InputResults.ConfusionMatrices(iCtr).(fStr);
%         nansum(LastOne,1)
        AddedMatrix = LastOne'* (AccuracyVector(iCtr) - BaselineValue);% ./ nansum(LastOne(:));
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
title(sprintf('Confusion Matrix for\n%s Classification',Options.Dataset));

%%
ClassCount = nansum(LastOne,2);
ClassCount = sprintf('%u Instances',ClassCount(1)*InputResults.ClassesData.MetaData.FoldCnt);

RTWT_Real = {};
RTWT_Pred = {};
for iCtr=1:length(Options.ClassLabels)
    RTWT_Pred{iCtr} = ['\bfPredicted\newline' Options.ClassLabels{iCtr}];
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
