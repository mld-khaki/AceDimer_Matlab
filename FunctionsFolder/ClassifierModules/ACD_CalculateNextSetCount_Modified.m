% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function    [ContributionsFeaturesNewOrder, UpdatedCount,AnalysisData] = ACD_CalculateNextSetCount_Modified_v16p0(PreviousRunResults,ClassesData,Options,DispInfoLevel)
CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Options.Version) ~= 1
	error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

TestTrainBypassMode = false;
if strcmpi(Options.ProcessMode,'Training') == 1 % train mode
	SingleCalcTime = PreviousRunResults.AnalysisInfo.Timing_EndTime / sum(~isnan(PreviousRunResults.AnalysisOutput.AccuraciesVector));
elseif strcmpi(Options.ProcessMode,'BypassTiming') == 1 % bypass mode
	SingleCalcTime = 10e-3;
	TestTrainBypassMode = true;
elseif strcmpi(Options.ProcessMode,'Testing') == 1 % Test mode
	SingleCalcTime = PreviousRunResults.AnalysisInfo.Timing_EndTime / sum(~isnan(PreviousRunResults.AnalysisOutput.AccuraciesVector));
	TestTrainBypassMode = true;
end
if isinf(SingleCalcTime)
	error('Error in calculation of SingleCalcTime');
end

FeaturesIndex = ClassesData.CD_GetUsableFeaturesIndex_v16p0();
FeaturesVector = ClassesData.CD_GetUsableFeaturesVector_v16p0();

FeaturesCount = length(FeaturesIndex);
UsableFeaturesCount = length(FeaturesIndex ~= 0);

NextFeatureSetCount = UsableFeaturesCount;
NPComputable = 0;
while(NPComputable == 0)
	if Options.Forward1Reverse0 == 1
		TempCombCount = ACD_AUX_CalcCombCount_v16p0(NextFeatureSetCount,Options.CurAttributeCount);
	else
		TempCombCount = ACD_AUX_CalcCombCount_v16p0(NextFeatureSetCount,NextFeatureSetCount-Options.AttributeCount);
	end
	ComputationTime = TempCombCount * SingleCalcTime;
	if ComputationTime <= Options.HoursLimit*60*60
		NPComputable = 1;
	else
		NextFeatureSetCount = NextFeatureSetCount - 1;
	end
end

TopPercentage = 0.9;
AnalysisData = struct;
AnalysisData(1).Direction = 'Forward';

if TestTrainBypassMode == false
	IgnoreBaseContribution = false;
	BypassAccuracyCheck = false;
	FeatureContWOrgOrder = ACD_ContributionEvaluation_IndividualClassBased_v16p0(ClassesData,FeaturesVector,1-TopPercentage,...
		PreviousRunResults.AnalysisOutput.AccuraciesVector,...
		PreviousRunResults.AnalysisOutput.ConfusionMatrices,...
		PreviousRunResults.AnalysisInfo.AllPossibleCombinations,...
		BypassAccuracyCheck,...
		IgnoreBaseContribution,Options);
	
	%     FeatureContWOrgOrder = FeatureContWOrgOrder - nanmean(FeatureContWOrgOrder);
	%     FeatureContWOrgOrder = FeatureContWOrgOrder ./ nanstd(FeatureContWOrgOrder);
	FeatureContWOrgOrder = FeatureContWOrgOrder - nanmin(FeatureContWOrgOrder);
	FeatureContWOrgOrder = FeatureContWOrgOrder ./ nanmax(FeatureContWOrgOrder);
	
	FeatureContWOrgOrder = FeatureContWOrgOrder - nanmin(FeatureContWOrgOrder);
	AnalysisData(1).Direction = 'Forward';
	AnalysisData(1).FeatureContributions = FeatureContWOrgOrder;
	AnalysisData(1).FeatureCnt = length(ClassesData.CD_GetUsableFeaturesIndex_v16p0());
	
	
	Contributions = struct;
	Contributions.FeaturesNewOrder = FeaturesVector;
	
	
	CurrentEnabledFeatures = length(ClassesData.CD_GetUsableFeaturesIndex_v16p0());
	TempResultsBackwardPhase = PreviousRunResults;
	CumulativeContribWOrgOrder = FeatureContWOrgOrder;
	while(1)
		Options2 = Options;
		Options2.ChanceAccuracy = 1/length(unique(ClassesData.TestingCls));
		Options2.ProcessMode = 'Training';
		Options2.Forward1Reverse0 = false;
		Options2.AutoOptimizeHyperParameters = true;
		Options2.CurAttributeCount = length(ClassesData.CD_GetUsableFeaturesIndex_v16p0())-1;
		Options2.IgnoreBaseContribution = false;
		
		FeatureContWOrgOrder = ACD_ContributionEvaluation_IndividualClassBased_v16p0(ClassesData,FeaturesVector,1-TopPercentage,...
			PreviousRunResults.AnalysisOutput.AccuraciesVector,...
			PreviousRunResults.AnalysisOutput.ConfusionMatrices,...
			PreviousRunResults.AnalysisInfo.AllPossibleCombinations,...
			BypassAccuracyCheck,...
			IgnoreBaseContribution,Options);
		[TempResultsBackwardPhase,~] = ACD_NeuronCombinedClassifier_Global_v16p0(TempResultsBackwardPhase.AnalysisInfo,ClassesData,DispInfoLevel,Options2);
		% 	TempResultsBackwardPhase = [];
		% 	TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector = 1:length(CD.CD_GetUsableFeaturesIndex_v16p0());
		% 	TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector = TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector - nanmin(TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector);
		% 	TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector = TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector ./ nanmax(TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector);
		
		FeatureContWOrgOrderBack = zeros(1,length(ClassesData.Features));
		FeatureContWOrgOrderBack(ClassesData.CD_GetUsableFeaturesIndex_v16p0()) = TempResultsBackwardPhase.AnalysisOutput.AccuraciesVector;
		FeatureContWOrgOrderBack = FeatureContWOrgOrderBack - nanmean(FeatureContWOrgOrderBack);
		FeatureContWOrgOrderBack(FeatureContWOrgOrderBack < 0) = 0;
		FeatureContWOrgOrderBack = FeatureContWOrgOrderBack ./ nanmax(FeatureContWOrgOrderBack);

		CumulativeContribWOrgOrder = CumulativeContribWOrgOrder - FeatureContWOrgOrderBack;
		
		AnalysisData(end+1).Direction = 'Backward';
		AnalysisData( end ).FeatureContributions = FeatureContWOrgOrderBack;
		AnalysisData( end ).FeatureCnt = length(ClassesData.CD_GetUsableFeaturesIndex_v16p0());
		AnalysisData( end ).CumulativeContributions = CumulativeContribWOrgOrder;

		save(['.\AnalysisData_' datestr(now,'_yyyy_mm_dd__HH_MM_SS__') '.mat'],'AnalysisData');
		GoToNextRemoval = 0;
		while(GoToNextRemoval == 0)
			[~,NextRemoveCandidate] = nanmin(CumulativeContribWOrgOrder);
			CumulativeContribWOrgOrder(NextRemoveCandidate) = inf;
			if ClassesData.CD_GetFeatureEnabledStatus_v16p0(NextRemoveCandidate) == true
				CurrentEnabledFeatures = CurrentEnabledFeatures-1;
				GoToNextRemoval = 1;
				Contributions.FeaturesNewOrder(NextRemoveCandidate).Rank = CurrentEnabledFeatures;
				ClassesData = ClassesData.CD_DisableFeature_v16p0(NextRemoveCandidate);
				Contributions.FeaturesNewOrder(NextRemoveCandidate).Enabled = 0;
			end
		end
		
		if CurrentEnabledFeatures <= NextFeatureSetCount
			break;
		end
	end
else
	Contributions = [];
	FeaturesOrg = ClassesData.GetUsableFeaturesVector();
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
