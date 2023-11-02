% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function    [ContributionsFeaturesNewRank, NextFeatureCount] = ACD_CalculateNextSetCount_Global_v3p0p0(PrvResults,DblPrvResults,TestAnalysisInfo,TestResults,ClassesData,Options)
CurrentVersion = 'AceDimerv3p0p0';

if strcmpi(CurrentVersion,Options.Version) ~= 1
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

TopPercentage = 0.1;

TestTrainBypassMode = false;
if strcmpi(Options.ProcessMode,'Training') == 1 % train mode
    SingleCalcTime = TestAnalysisInfo.EndTime / nansum(TestResults.ProgressStatus);
    TestTrainBypassMode = true;
elseif strcmpi(Options.ProcessMode,'BypassTiming') == 1 % bypass mode
    SingleCalcTime = 10e-3;
elseif strcmpi(Options.ProcessMode,'Testing') == 1 % Test mode
    SingleCalcTime = TestAnalysisInfo.EndTime / nansum(TestResults.ProgressStatus);
    TestTrainBypassMode = false;
end
if isinf(SingleCalcTime)
    error('Error in calculation of SingleCalcTime');
end

ContributionsFeaturesNewRank = [];

UsableFeaturesCount = nansum(ACD_ExtractStructField(ClassesData.Features,'Enabled'));

NextFeatureCount = UsableFeaturesCount;
NPComputable = 0;
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
    
    % if the mode is not training, the entire AccuraciesVector is not
    % filled and it is not possible to calculate contributions using the
    % new (AceDimer V2) method
    if strcmpi(Options.ProcessMode,'Training') == 0
        DblPrvResults = [];
    end
    
% 		PrvResults.ConfusionMatrices,...
    ContributionResults = ACD_AUX_CalculateContributions_v3p0p0('AceDimerv3p0p0',PrvResults,DblPrvResults,true,IgnoreBaseContribution,Options.Top_N_Percent);

    
    FeatureContWOrgOrder_Org = ContributionResults.FeatureContWOrgOrder;
    
    FeatureContWOrgOrder = FeatureContWOrgOrder_Org;
    FeatureContWOrgOrder = FeatureContWOrgOrder - nanmin(FeatureContWOrgOrder);
    
    FeaturesContributionVector = FeatureContWOrgOrder;
    Contributions.Features = ContributionResults.Features;
    
    for jCtr=1:length(Contributions.Features)
        Contributions.Features(jCtr).Enabled = 0;
    end
    SelectedFeatures = 0;
    for jCtr=1:NextFeatureCount
        [~,NextHighFeatureIndex] = nanmax(FeaturesContributionVector);
        FeaturesContributionVector(NextHighFeatureIndex) = -inf;

        SelectedFeatures = SelectedFeatures+1;
        Contributions.Features(NextHighFeatureIndex).Rank = SelectedFeatures;
        Contributions.Features(NextHighFeatureIndex).Enabled = 1;
    end
    
    FeatureContWOrgOrder_Org = FeatureContWOrgOrder_Org*100 ./ nansum(FeatureContWOrgOrder_Org);

    ContributionsFeaturesNewRank = Contributions.Features;
    for iCtr=1:length(FeatureContWOrgOrder_Org)
        ContributionsFeaturesNewRank(iCtr).Contributions = FeatureContWOrgOrder_Org(iCtr);
        ContributionsFeaturesNewRank(iCtr).ContributionsSet = Contributions.Features(iCtr).Contributions;
    end
else
    Contributions = [];
    FeaturesOrg = ClassesData.CD_GetUsableFeaturesVector_v3p0p0();
    Contributions.Index = 1:length(FeaturesOrg);
    if iscell(FeaturesOrg) && length(FeaturesOrg) == 1
        FeaturesOrg = FeaturesOrg{1};
    end

    Contributions.Features = FeaturesOrg;
end


end
