% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function TotalConMat = ACD_FeatureContributionVisualizer_v16p0(InputResults,Title,InpFeatureNames,Top_N_Percent)
CurrentVersion = 'AceDimer16p0';

CurClass = 'StagesRW';
PlotFigure2 = 0;
PlotFigure1 = 0;
PlotFigure3 = 1;
% Top_N_Percent = 0.75;
BinCount = 50;
BarCount = 10;
CurrentCls = 'Rett Samples';


AccuraciesVector = InputResults.AccuraciesVector;

TopNPercentThreshold = nanmax(AccuraciesVector)*(Top_N_Percent);
nansum(AccuraciesVector > TopNPercentThreshold)
SelectedClassifiers = AccuraciesVector(AccuraciesVector > TopNPercentThreshold);


[AnalysisRes] = ACD_AUX_CalculateContributions_v16p0(CurrentVersion,...
    InputResults,...
    1,false,Top_N_Percent);


% FeatureContWOrgOrder = FeatureRounder(FeatureContWOrgOrder);

FeatureContWOrgOrder = AnalysisRes.FeatureContWOrgOrder*100 / nansum(AnalysisRes.FeatureContWOrgOrder);



MaxStrLength = -1;
YStruct = struct;
YStruct.Labels = {};
YStruct.Inds = [];
YStruct.Contribution = [];
FeatureNames = ACD_ExtractStructField_Cells(AnalysisRes.OutFeatures,'Name');
RankInd = ACD_ExtractStructField(AnalysisRes.OutFeatures,'Rank');
ContributionVect = ACD_ExtractStructField(AnalysisRes.OutFeatures,'Contribution');

FeatureCnt = nanmin([BarCount,nansum(~isnan(RankInd))]);
RemovedContributions = [];
for iCtr=1:FeatureCnt
    CurInd = find(RankInd == iCtr);
    assert(length(CurInd) == 1);
    YStruct.Labels{iCtr} = InpFeatureNames{CurInd};
    YStruct.Inds(iCtr) = CurInd;
    YStruct.Contribution(iCtr) = ContributionVect(CurInd);
    RemovedContributions(end+1) = CurInd;
end
ContributionVect(RemovedContributions) = [];
YStruct.Contribution(end+1) = nansum(ContributionVect);
YStruct.Labels{end+1} = sprintf('Remaining %u features',length(ContributionVect));

%%
if PlotFigure3 == 1
    FigH3 = figure;
    ACD_Subplot();

    ACD_AUX_BarPlotter_v16p0(YStruct.Contribution,YStruct.Labels,FigH3,0.5	);
    ACD_title('Features contributing to the highest accuracy classifer\nTraining and Test performed on = %s\n',Title);
    xlabel([sprintf('\\bfMaximum Acheived Accuracy = \\color{red}%4.2f%%',100*max(AccuraciesVector)) newline...
        sprintf('\\bf\\color{black}Random Accuracy = \\color{red}%4.2f%%',100*max(AnalysisRes.BaseContribution)) ...
        ]);
    ACD_ylabel('Feature Contribution Percentage');

    FigH3.Position = 0.8*(100 + [0,0,1300,600]);
%     FileName = sprintf('HumanSpany_Contributors_to_HighestAccuracy');
%     ACD_FigureSaverV5(FigH3,'.','filename',FileName,...
%         'Position',[0, 0, 900, 750]);
%     close(FigH3);
%     RemoveBorders([FileName '.png'],0,255*[1 1 1]);
end

end
%% 
function ACD_Subplot()
MaxF = 9;
SFig = reshape(1:MaxF^2,MaxF,MaxF);
SFig(1:2,:) = [];
SFig(:,[1 MaxF]) = [];
subplot(MaxF,MaxF,SFig(:));
end
