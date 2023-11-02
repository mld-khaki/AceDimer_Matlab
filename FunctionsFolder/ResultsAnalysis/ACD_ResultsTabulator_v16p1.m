% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $

function [AnalysisOut, SROut,Rankings] = ACD_ResultsTabulator_v16p1(Version,InputFolderOfResults,Top_N_Percent,SRIn,AnalysisInp)
CurrentVersion = 'AceDimer16p1';

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
clc
if InputFolderOfResults(end) ~= '\'
	InputFolderOfResults(end+1) = '\';
end

AnalysisOut = [];
if exist('SRIn','var')
	SROut = SRIn;
end



% if ~ischar(InputData)
% 	InputDataVar = InputData;
% else
% 	InputDataVar = load(InputData);
% end

ResultStats = [];
FeaturesAr = [];
if exist('AnalysisInp','var')
	MaxAccuracy = AnalysisInp.MaxAccuracy;
end



if exist('SRIn','var')
	SR = SRIn;
else
	SR = [];
	if exist([InputFolderOfResults '\Dbl_Res__CAt02'],'dir') > 0
		FilesList = dir([InputFolderOfResults '\Dbl*']);
		for fCtr=1:length(FilesList)
			fprintf('\n\tFCtr=%u, File: "%s"...',fCtr,FilesList(fCtr).name);
	% 		SR(fCtr).SR = load([InputFolderOfResults FilesList(fCtr).name]);
			if length(dir([InputFolderOfResults FilesList(fCtr).name '\*.mat'])) > 0
				SR(fCtr).SR.SaveResults = ACD_LoadBigArray('SaveResults',[InputFolderOfResults FilesList(fCtr).name '\'],false,'V2');
			else
				SR(fCtr).SR.SaveResults = ACD_LoadBigData([InputFolderOfResults FilesList(fCtr).name],'SaveResults',{'ConfusionMatrices'});
			end
		end
	else
		FilesList = dir([InputFolderOfResults '\*.mat']);
		for fCtr=1:length(FilesList)
			fprintf('\n\tFCtr=%u, File: "%s"...',fCtr,FilesList(fCtr).name);
			FileNamePath = ACD_CombineDirectoryWithFileFold(InputFolderOfResults,FilesList(fCtr).name);
			SR(fCtr).SR = load(FileNamePath);
		end
	end
end

if exist('SR','var')
	if ~exist('MaxAccuracy','var')
		MaxAccuracy = -inf;
	end
	
	for fCtr=1:length(SR)
		fprintf('\n\tFCtr=%u, File: "%s"...',fCtr,FilesList(fCtr).name);
		if isfield(SR(fCtr).SR,'SaveResults')
			if isfield(SR(fCtr).SR.SaveResults,'AccuraciesVector')
				MaxAccuracy = nanmax([MaxAccuracy SR(fCtr).SR.SaveResults.AccuraciesVector]);
			end
		end
	end

	if ~isempty(SR)
		for iCtr=1:length(SR)
			CurSR = SR(iCtr).SR.SaveResults;
			if isempty(CurSR), continue;end
			if ~isempty(CurSR)
				FeaturesCountsOrg = zeros(1,length(CurSR(1).Features));
				FeaturesCounts = FeaturesCountsOrg;
				break;
			end
		end
	end
end

if ~exist('FeaturesCountsOrg','var') || ~exist('CurSR','var')
	CurSR = struct;
    CurSR.SaveResults = struct;
    for iCtr=1:length(SR)
		CurSR = SR(iCtr).SR.SaveResults;
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

for fCtr=1:length(SR)
	if ~isfield(SR(fCtr).SR,'SaveResults'), continue;end
	if ~isfield(SR(fCtr).SR.SaveResults,'AccuraciesVector'), continue;end
	fprintf('\n\tFCtr=%u, File: "%s"...',fCtr,FilesList(fCtr).name);
	
	CurSR = SR(fCtr).SR.SaveResults;
	
	[MaxVal, MaxInd] = nanmax (CurSR.AccuraciesVector);
	
	ResultStats(fCtr).MaxAccuracy = MaxVal;
	ResultStats(fCtr).AvgAccuracy = nanmean(CurSR.AccuraciesVector);
	ResultStats(fCtr).FeatureCnt  = fCtr+1;
	
	MaxAccFeatureIndices = CurSR.AnalysisInfo.AllPossibleCombinations(MaxInd,:);
	
	TopestFeatures = {};
	for iCtr=1:length(MaxAccFeatureIndices)
		TopestFeatures{iCtr} = CurSR.ClassesData.Features(MaxAccFeatureIndices(iCtr)).Name;
	end
	
	ResultStats(fCtr).TopFeatures  = TopestFeatures;
	ResultStats(fCtr).TopFeatureNumbers = MaxAccFeatureIndices;
	
	TopClassifierIndices = find(CurSR.AccuraciesVector >= MaxThreshold);
	CurFeaturesCounts = FeaturesCountsOrg;
	for jCtr=TopClassifierIndices
		FeatureIndices = CurSR.AnalysisInfo.AllPossibleCombinations(jCtr,:);
		
		CurFeaturesCounts(FeatureIndices) = CurFeaturesCounts(FeatureIndices) + 1;
	end
	
	
	FeaturesCounts = FeaturesCounts + CurFeaturesCounts;
	ResultStats(fCtr).FeatureCountsAgg = FeaturesCounts;
	ResultStats(fCtr).FeatureCountsCurrent = CurFeaturesCounts;

	CurFeaturesCounts(CurFeaturesCounts == 0) = [];
% 	if ~isempty(CurFeaturesCounts)
% 		IncludedFeatures = FindTopFeatures(CurFeaturesCounts);
% 	end
	
	
	ResultStats(fCtr).TopClassifierCount = length(TopClassifierIndices);
	ResultStats(fCtr).HighestAccuracy = MaxVal;
	
	ResultStats(fCtr).FeatureCntSTD = nanstd(CurFeaturesCounts);
	ResultStats(fCtr).FeatureCntAVG = nanmean(CurFeaturesCounts);
	
	NormCurFeaturesCounts = CurFeaturesCounts / length(TopClassifierIndices);
	ResultStats(fCtr).FeatureCntSTD_Nrmlzd = nanstd(NormCurFeaturesCounts);
	ResultStats(fCtr).FeatureCntAVG_Nrmlzd = nanmean(NormCurFeaturesCounts);
	ResultStats(fCtr).AvailableFeatures = nansum(CurFeaturesCounts > 0);
	
	CurFeaturesCounts = CurFeaturesCounts ./ nansum(CurFeaturesCounts);
	
	
    ContAnalysisRes = ACD_AUX_CalculateContributions_v16('AceDimerV2p0p0',...
		CurSR,...
		1,false,Top_N_Percent);%,InputDataVar.D_FeatureWeights);
	
	ResultStats(fCtr).FeatureContWOrgOrder = ContAnalysisRes.FeatureContWOrgOrder;
	ResultStats(fCtr).HighAccMean = nanmean(CurSR.AccuraciesVector(TopClassifierIndices));
	ResultStats(fCtr).HighAccCnt = length(TopClassifierIndices);
	
	FeaturesAr(fCtr).FeaturesDesc = CurSR.Features;
	if ~exist('Rankings','var')
		Rankings = {ContAnalysisRes.OutFeatures};
	else
		Rankings{fCtr} = ContAnalysisRes.OutFeatures;
	end
end
fprintf(newline);

AnalysisOut = [];
SROut = SR;
AnalysisOut.ResultStats = ResultStats;
AnalysisOut.MaxAccuracy = MaxAccuracy;
AnalysisOut.FeaturesAr = FeaturesAr;
end
