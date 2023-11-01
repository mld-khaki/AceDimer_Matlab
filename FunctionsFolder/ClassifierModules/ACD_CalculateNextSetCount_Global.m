% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function    [ContributionsFeaturesNewOrder, NextFeatureCount] = ACD_CalculateNextSetCount_Global_v16p0(PreviousRunResults,AnalysisInfo,ClassesData,Options)
CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Options.Version) ~= 1
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

TopPercentage = 0.1;

TestTrainBypassMode = false;
if strcmpi(Options.ProcessMode,'Training') == 1 % train mode
    SingleCalcTime = AnalysisInfo.EndTime / sum(~isnan(PreviousRunResults.AccuraciesVector));
    TestTrainBypassMode = true;
elseif strcmpi(Options.ProcessMode,'BypassTiming') == 1 % bypass mode
    SingleCalcTime = 10e-3;
elseif strcmpi(Options.ProcessMode,'Testing') == 1 % Test mode
    SingleCalcTime = AnalysisInfo.EndTime / sum(~isnan(PreviousRunResults.AccuraciesVector));
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
PrvComputationTime = [];
PrvNextFeatureCount = [];
ComputationTime = inf;
while(NPComputable == 0)
    if Options.Forward1Reverse0 == 1
        TempCombCount = nchoosek(NextFeatureCount,Options.CurAttributeCount);
    else
        TempCombCount = nchoosek(NextFeatureCount,NextFeatureCount-Options.AttributeCount);
	end
	PrvComputationTime = ComputationTime;
    ComputationTime = TempCombCount * SingleCalcTime;

	if ComputationTime <= Options.HoursLimitMin*60*60 && PrvComputationTime <= Options.HoursLimitMax*60*60
		NextFeatureCount = PrvNextFeatureCount;
        NPComputable = 1;
	elseif ComputationTime > Options.HoursLimitMin*60*60 && ComputationTime <= Options.HoursLimitMax*60*60
        NPComputable = 1;
	else %if NextFeatureCount ~= UsableFeaturesCount
		PrvNextFeatureCount = NextFeatureCount;
        NextFeatureCount = NextFeatureCount - 1;
    end
end

if TestTrainBypassMode == true
    IgnoreBaseContribution = false;
    
% 		PreviousRunResults.ConfusionMatrices,...
    FeatureContWOrgOrder = ACD_ContributionEvaluation_Global_v16p0(ClassesData,FeaturesVector,1-TopPercentage,...
        PreviousRunResults.AccuraciesVector,...
		AnalysisInfo.AllPossibleCombinations,...
		1,IgnoreBaseContribution,Options);
    FeatureContWOrgOrder_Org = FeatureContWOrgOrder;
    
    FeatureContWOrgOrder = FeatureContWOrgOrder - nanmean(FeatureContWOrgOrder);
    FeatureContWOrgOrder = FeatureContWOrgOrder ./ nanstd(FeatureContWOrgOrder);
    
    FeatureContWOrgOrder = FeatureContWOrgOrder - nanmin(FeatureContWOrgOrder);
    
    tmpContribution = FeatureContWOrgOrder;
    
    
    FeaturesVectorExtended = FeaturesVector;
    Contributions.FeaturesNewOrder = FeaturesVector;
    
    %add current contribution to each feature
    for iCtr=1:length(FeaturesVector)
        FeaturesVectorExtended(iCtr).Contribution = tmpContribution(iCtr);
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

FeatureContWOrgOrder_Org = FeatureContWOrgOrder_Org*100 ./ nansum(FeatureContWOrgOrder_Org);

ContributionsFeaturesNewOrder = Contributions.FeaturesNewOrder;
for iCtr=1:length(FeatureContWOrgOrder_Org)
    ContributionsFeaturesNewOrder(iCtr).Contributions = FeatureContWOrgOrder_Org(iCtr);
end
NextFeatureCount = sum(ACD_ExtractStructField(ContributionsFeaturesNewOrder,'Enabled') == 1);
% just to ensure I won't get the following error (may not be necessary)

end
