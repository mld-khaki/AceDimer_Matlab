% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function    [ContributionsFeaturesNewOrder, UpdatedCount] = ACD_CalculateNextSetCount_CPP_v16p0(PreviousRunResults,TestResults,ClassesData,Options)
CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Options.Version) ~= 1
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

TopPercentage = 0.1;

TestTrainBypassMode = false;
if strcmpi(Options.ProcessMode,'Training') == 1 % train mode
    SingleCalcTime = PreviousRunResults.AnalysisInfo.EndTime / sum(~isnan(PreviousRunResults.AnalysisOutput.AccuraciesVector));
elseif strcmpi(Options.ProcessMode,'BypassTiming') == 1 % bypass mode
    SingleCalcTime = 10e-3;
    TestTrainBypassMode = true;
elseif strcmpi(Options.ProcessMode,'Testing') == 1 % Test mode
    SingleCalcTime = PreviousRunResults.AnalysisInfo.EndTime / sum(~isnan(PreviousRunResults.AnalysisOutput.AccuraciesVector));
    TestTrainBypassMode = true;
end
if isinf(SingleCalcTime)
    error('Error in calculation of SingleCalcTime');
end

FeaturesIndex = ClassesData.CD_GetUsableFeaturesIndex_v16p0();
FeaturesVector = ClassesData.CD_GetUsableFeaturesVector_v16p0();

FeaturesCount = length(FeaturesIndex);
UsableFeaturesCount = length(FeaturesIndex ~= 0);

NextFeatureCount = UsableFeaturesCount;
NPComputable = 0;
while(NPComputable == 0)
    if Options.Forward1Reverse0 == 1
        TempCombCount = ACD_AUX_CalcCombCount_v16p0(NextFeatureCount,Options.CurAttributeCount);
    else
        TempCombCount = ACD_AUX_CalcCombCount_v16p0(NextFeatureCount,NextFeatureCount-Options.AttributeCount);
    end
    ComputationTime = TempCombCount * SingleCalcTime;
    if ComputationTime <= Options.HoursLimit*60*60
        NPComputable = 1;
    else
        NextFeatureCount = NextFeatureCount - 1;
    end
end

if TestTrainBypassMode == false
    IgnoreBaseContribution = false;
    
    FeatureContWOrgOrder = ACD_ContributionEvaluation_IndividualClassBased_v16p0(ClassesData,FeaturesVector,1-TopPercentage,...
        PreviousRunResults.AnalysisOutput.AccuraciesVector,...
		PreviousRunResults.AnalysisOutput.ConfusionMatrices,...
		PreviousRunResults.AnalysisInfo.AllPossibleCombinations,...
		1,IgnoreBaseContribution,Options);

    FeatureContWOrgOrder = FeatureContWOrgOrder - nanmean(FeatureContWOrgOrder);
    FeatureContWOrgOrder = FeatureContWOrgOrder ./ nanstd(FeatureContWOrgOrder);
    
    FeatureContWOrgOrder = FeatureContWOrgOrder - nanmin(FeatureContWOrgOrder);
    
    Contribution = FeatureContWOrgOrder;
    
    
    FeaturesVectorExtended = FeaturesVector;
    Contributions.FeaturesNewOrder = FeaturesVector;
    
    %add current contribution to each feature
    for iCtr=1:length(FeaturesVector)
        FeaturesVectorExtended(iCtr).Contribution = Contribution(iCtr);
        Contributions.FeaturesNewOrder(iCtr).Rank = 0;
        Contributions.FeaturesNewOrder(iCtr).Enabled = 0;
    end
    
    
    SelectedFeatures = 0;
    for jCtr=1:NextFeatureCount
        [~,NextHighFeatureIndex] = ACD_StructMax(FeaturesVectorExtended,'Contribution');
        FeaturesVectorExtended(NextHighFeatureIndex).Contribution = -inf;
        if FeaturesVectorExtended(NextHighFeatureIndex).Enabled == 0
            continue;
        else
            SelectedFeatures = SelectedFeatures+1;
            Contributions.FeaturesNewOrder(NextHighFeatureIndex).Rank = SelectedFeatures;
            Contributions.FeaturesNewOrder(NextHighFeatureIndex).Enabled = 1;
        end
        
    end
else
    Contributions = [];
    FeaturesOrg = ClassesData.CD_GetUsableFeaturesVector_v16p0();
    Contributions.Index = 1:length(FeaturesOrg);
    if iscell(FeaturesOrg) && length(FeaturesOrg) == 1
        FeaturesOrg = FeaturesOrg{1};
    end

    Contributions.FeaturesNewOrder = FeaturesOrg;
end

ContributionsFeaturesNewOrder = Contributions.FeaturesNewOrder;
UpdatedCount = sum(ACD_ExtractStructField(ContributionsFeaturesNewOrder,'Enabled') == 1);
% just to ensure I won't get the following error (may not be necessary)

end
