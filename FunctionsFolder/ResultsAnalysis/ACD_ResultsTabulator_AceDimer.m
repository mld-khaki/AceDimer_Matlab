% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $

function [AnalysisOut, SROut,Rankings] = ACD_ResultsTabulator_AceDimer(Version,AnalysisResults,Top_N_Percent,AnalysisInp)
CurrentVersion = 'AceDimer4p0p0';

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
%%

AnalysisOut = [];
if exist('SRIn','var')
	SROut = SRIn;
end



% if ~ischar(InputData)
% 	InputDataVar = InputData;
% else
% 	InputDataVar = load(InputData);
% end

ResultStats = struct;
FeaturesAr = [];
if exist('AnalysisInp','var')
	MaxAccuracy = AnalysisInp.MaxAccuracies;
end



if isfield(AnalysisResults,'Rounds')
	for iCtr=1:length(AnalysisResults.Rounds)
		CurSR = AnalysisResults.Rounds(iCtr);
		if isempty(CurSR), continue;end
		if ~isempty(CurSR)
			FeaturesCountsOrg = zeros(1,length(CurSR(1).Features));
			FeaturesCounts = FeaturesCountsOrg;
			break;
		end
	end
end

if ~exist('FeaturesCountsOrg','var')
	for iCtr=1:length(AnalysisResults.Rounds)
		CurSR = AnalysisResults.Rounds(iCtr);
		if isempty(CurSR), continue;end
		if ~isempty(CurSR)
			FeaturesCountsOrg = zeros(1,length(CurSR(1).Features));
			FeaturesCounts = FeaturesCountsOrg;
			break;
		end
	end
end

MaxThreshold = nanmean(CurSR.AccuraciesVector);

if ~exist('MaxAccuracy','var')
	error('Max Accuracy is not calculated via folders or input');
end

%%
clc
for fCtr=length(AnalysisResults.Rounds)
	fprintf('\n\tFCtr=%u...',fCtr);
	
	CurSR = AnalysisResults.Rounds(fCtr);
	
	[MaxVal, MaxInd] = nanmax (CurSR.AccuraciesVector);
	
	ResultStats.MaxAccuracy = MaxVal;
	ResultStats.AvgAccuracy = nanmean(CurSR.AccuraciesVector);
	ResultStats.FeatureCnt  = fCtr+1;
	
	MaxAccFeatureIndices = CurSR.AnalysisInfo.AllPossibleCombinations(MaxInd,:);
	
	TopestFeatures = {};
	for iCtr=1:length(MaxAccFeatureIndices)
		TopestFeatures{iCtr} = CurSR.ClassesData.Features(MaxAccFeatureIndices(iCtr)).Name;
	end
	
	ResultStats.TopFeatures  = TopestFeatures;
	ResultStats.TopFeatureNumbers = MaxAccFeatureIndices;
	
	TopClassifierIndices = find(CurSR.AccuraciesVector >= MaxThreshold);
	CurFeaturesCounts = FeaturesCountsOrg;
	for jCtr=TopClassifierIndices
		FeatureIndices = CurSR.AnalysisInfo.AllPossibleCombinations(jCtr,:);
		
		CurFeaturesCounts(FeatureIndices) = CurFeaturesCounts(FeatureIndices) + 1;
	end
	
	
	FeaturesCounts = FeaturesCounts + CurFeaturesCounts;
	ResultStats.FeatureCountsAgg = FeaturesCounts;
	ResultStats.FeatureCountsCurrent = CurFeaturesCounts;

	CurFeaturesCounts(CurFeaturesCounts == 0) = [];
% 	if ~isempty(CurFeaturesCounts)
% 		IncludedFeatures = FindTopFeatures(CurFeaturesCounts);
% 	end
	
	
	ResultStats.TopClassifierCount = length(TopClassifierIndices);
	ResultStats.HighestAccuracy = MaxVal;
	
	ResultStats.FeatureCntSTD = nanstd(CurFeaturesCounts);
	ResultStats.FeatureCntAVG = nanmean(CurFeaturesCounts);
	
	NormCurFeaturesCounts = CurFeaturesCounts / length(TopClassifierIndices);
	ResultStats.FeatureCntSTD_Nrmlzd = nanstd(NormCurFeaturesCounts);
	ResultStats.FeatureCntAVG_Nrmlzd = nanmean(NormCurFeaturesCounts);
	ResultStats.AvailableFeatures = nansum(CurFeaturesCounts > 0);
	
	CurFeaturesCounts = CurFeaturesCounts ./ nansum(CurFeaturesCounts);
	
    ContAnalysisRes = ACD_AUX_CalculateContributions_v4p0p0('AceDimerv4p0p0',...
		AnalysisResults.Rounds(fCtr-1),AnalysisResults.Rounds(fCtr-2),...
		1,false,Top_N_Percent);%,InputDataVar.D_FeatureWeights);
	
	ResultStats.FeatureContWOrgOrder = ContAnalysisRes.FeatureContWOrgOrder;
	ResultStats.HighAccMean = nanmean(CurSR.AccuraciesVector(TopClassifierIndices));
	ResultStats.HighAccCnt = length(TopClassifierIndices);
    ResultStats.IndividualFeaturesCount = ContAnalysisRes.IndividualFeaturesCount;
	
	FeaturesAr(fCtr).FeaturesDesc = CurSR.Features;
% 	if ~exist('Rankings','var')
% 		Rankings = {ContAnalysisRes.Features};
% 	else
% 		Rankings{fCtr} = ContAnalysisRes.OutFeatures;
% 	end
end
%%
fprintf(newline);

AnalysisOut = [];
SROut = CurSR;
AnalysisOut.ResultStats = ResultStats;
AnalysisOut.MaxAccuracy = MaxAccuracy;
AnalysisOut.FeaturesAr = FeaturesAr;
end
