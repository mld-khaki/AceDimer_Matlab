% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/25  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $
% $Revision: 3.3.0 $  $Date: _2022_05_09___18_45_33_Mon  Conforming to the ACD_AUX_CalculateContributions_v3p3p0 updating the calculation of each feature's confusion matrix
% $Revision: 3.3.1 $  $Date: 2022/04/17  Speed optimization


function [AnalysisOut, Rankings] = ACD_ResultsTabulator(Version,AnalysisResults,Top_N_Percent)
CurrentVersion = 'AceDimerV3p0p0';
IgnoreBaseContribution = true;
if strcmpi(CurrentVersion,Version) == 0
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end
% Running ResultsTabulator without SR structure array
% [AnalysisVar,SRVar] = ResultsTabulator('.\Scenario_A\','.\Data\NeuroMetrics_Raw.mat','StagesRW',0.95)
%
% these two modes are only used for debugging:
%
% Running ResultsTabulator without SR structure array
% [AnalysisVar,SRVar] = ResultsTabulator('.\Scenario_A\','.\Data\NeuroMetrics_Raw.mat','StagesRW',0.95,SRVar)
%
% Running ResultsTabulator without SR structure array and Analysis outputvariable for recalculation
% [AnalysisVar,SRVar] = ResultsTabulator('.\Scenario_A\','.\Data\NeuroMetrics_Raw.mat','StagesRW',0.95,SRVar,AnalysisVar)
%
AnalysisOut = struct;



% if ~ischar(InputData)
% 	InputDataVar = InputData;
% else
% 	InputDataVar = load(InputData);
% end

ResultStats = struct;
FeaturesAr = struct;
if exist('AnalysisInp','var')
	MaxAccuracy = AnalysisInp.MaxAccuracy;
end

if ~isfield(AnalysisResults,'Rounds')
	error('AnalysisResults input does not have AceDimer''s round information!');
end


MaxAccuracy = -inf;
FeaturesCountsOrg = zeros(1,length(AnalysisResults.Rounds(1).Features));
FeaturesCounts = FeaturesCountsOrg;

MaxThreshold = nanmean(AnalysisResults.Rounds(1).AccuraciesVector);

for roundCtr=1:length(AnalysisResults.Rounds)
	[MaxVal, MaxInd] = nanmax (AnalysisResults.Rounds(roundCtr).AccuraciesVector); %#ok<*NANMAX> 
	
	ResultStats(roundCtr).MaxAccuracy = MaxVal;
	ResultStats(roundCtr).AvgAccuracy = nanmean(AnalysisResults.Rounds(roundCtr).AccuraciesVector);
	ResultStats(roundCtr).FeatureCnt  = roundCtr+1;
	
	MaxAccFeatureIndices = AnalysisResults.Rounds(roundCtr).AnalysisInfo.AllPossibleCombinations(MaxInd,:);
	
	TopestFeatures = {};
	for iCtr=1:length(MaxAccFeatureIndices)
		TopestFeatures{iCtr} = AnalysisResults.Rounds(roundCtr).ClassesData.Features(MaxAccFeatureIndices(iCtr)).Name; %#ok<*AGROW> 
	end
	
	ResultStats(roundCtr).TopFeatures  = TopestFeatures;
	ResultStats(roundCtr).TopFeatureNumbers = MaxAccFeatureIndices;
	
% 	TopClassifierIndices = find(AnalysisResults.Rounds(roundCtr).AccuraciesVector >= MaxThreshold);
    TopClassifierIndices = 1:length(AnalysisResults.Rounds(roundCtr).AccuraciesVector);
	CurFeaturesCounts = FeaturesCountsOrg;

    tmpAllCombs = AnalysisResults.Rounds(roundCtr).AnalysisInfo.AllPossibleCombinations;
    tmpAllCombs = tmpAllCombs(TopClassifierIndices,:);
	for jCtr=1:size(tmpAllCombs,1)
		CurFeaturesCounts(tmpAllCombs(jCtr,:)) = CurFeaturesCounts(tmpAllCombs(jCtr,:)) + 1;
	end
	
	
	FeaturesCounts = FeaturesCounts + CurFeaturesCounts;
	ResultStats(roundCtr).FeatureCountsAgg = FeaturesCounts;
	ResultStats(roundCtr).FeatureCountsCurrent = CurFeaturesCounts;

	CurFeaturesCounts(CurFeaturesCounts == 0) = [];
	
	
	ResultStats(roundCtr).TopClassifierCount = length(TopClassifierIndices);
	ResultStats(roundCtr).HighestAccuracy = MaxVal;
	
	ResultStats(roundCtr).FeatureCntSTD = nanstd(CurFeaturesCounts);
	ResultStats(roundCtr).FeatureCntAVG = nanmean(CurFeaturesCounts); %#ok<*NANMEAN> 
	
	NormCurFeaturesCounts = CurFeaturesCounts / length(TopClassifierIndices);
	ResultStats(roundCtr).FeatureCntSTD_Nrmlzd = nanstd(NormCurFeaturesCounts); %#ok<*NANSTD> 
	ResultStats(roundCtr).FeatureCntAVG_Nrmlzd = nanmean(NormCurFeaturesCounts); %#ok<NANMEAN> 
	ResultStats(roundCtr).AvailableFeatures = nansum(CurFeaturesCounts > 0); %#ok<*NANSUM> 
	
    CurRoundAnalysisResults = AnalysisResults.Rounds(roundCtr);

    if roundCtr == 1
        PrvRoundAnalysisResults = [];
    else
        PrvRoundAnalysisResults = AnalysisResults.Rounds(roundCtr-1);
    end
%     ContAnalysisRes = ACD_AUX_CalculateContributions_v3p0p0(Version,...
% 		AnalysisResults.Rounds(SelRes),AnalysisResults.Rounds(SelRes-1),...
% 		true,false,Top_N_Percent);%,InputDataVar.D_FeatureWeights);

    ContAnalysisRes = ACD_AUX_CalculateContributions_v3p3p1(Version,...
		CurRoundAnalysisResults,PrvRoundAnalysisResults,...
		true,IgnoreBaseContribution,Top_N_Percent);%,InputDataVar.D_FeatureWeights);

	ResultStats(roundCtr).FeatureContWOrgOrder = ContAnalysisRes.FeatureContWOrgOrder;
    ResultStats(roundCtr).IndividualFeaturesCount = ContAnalysisRes.IndividualFeaturesCount;

	ResultStats(roundCtr).HighAccMean = nanmean(AnalysisResults.Rounds(roundCtr).AccuraciesVector(TopClassifierIndices));
	ResultStats(roundCtr).HighAccCnt = length(TopClassifierIndices);
	
	FeaturesAr(roundCtr).FeaturesDesc = AnalysisResults.Rounds(roundCtr).Features;
	FeaturesAr(roundCtr).Features = ContAnalysisRes.Features;
	if ~exist('Rankings','var')
		Rankings = {ContAnalysisRes.Features};
	else
		Rankings{roundCtr} = ContAnalysisRes.Features;
	end
end
fprintf(newline);

AnalysisOut = [];
AnalysisOut.ResultStats = ResultStats;
AnalysisOut.MaxAccuracy = MaxAccuracy;
AnalysisOut.FeaturesAr = FeaturesAr;
end
