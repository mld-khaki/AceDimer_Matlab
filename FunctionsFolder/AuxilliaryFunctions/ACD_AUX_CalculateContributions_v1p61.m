% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [AnalysisResults] = ACD_AUX_CalculateContributions_v1p61(Version,InpResults,BypassAccuracyCheck,IgnoreBaseContribution,Top_N_Percent)
CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Version) == 0
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

SortedAccuraciesVector = sortrows(InpResults.AccuraciesVector',-1)';
if nargin <= 2
	BypassAccuracyCheck = 0;
end

if sum(InpResults.AccuraciesVector ~= 0) < length(InpResults.AccuraciesVector)*0.99 && (BypassAccuracyCheck == 0)
	error('Accuracies vector contains unexpected number of zeros!');
end
TopNPercent = nanmax(SortedAccuraciesVector)*Top_N_Percent;

assert(isnan(TopNPercent) == 0);
%the array of Features has the length of All features. The only
%difference is that the Enabled field of features indicate which ones are
%enabled (1) or disabled (0)
NumberOfFeatures = 0;%length(Features);
FeaturesList = [];
for iCtr=1:length(InpResults.Features)
    if InpResults.Features(iCtr).Enabled == 1
        NumberOfFeatures = NumberOfFeatures + 1;
        FeaturesList(iCtr) = InpResults.Features(iCtr).Number;
    else
        FeaturesList(iCtr) = 0;
    end
end
 
ClassesVector = [];
for fCtr = 1:InpResults.ClassesData.GetFoldCount()
	if strcmpi(class(InpResults.ClassesData),'ClassificationData_v14p4') == 1
		ClassesVector = [ClassesVector InpResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v14p4(fCtr)];
	elseif strcmpi(class(InpResults.ClassesData),'ClassificationData_v14p5') == 1
		ClassesVector = [ClassesVector InpResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v14p5(fCtr)];
	elseif strcmpi(class(InpResults.ClassesData),'ClassificationData_v16p0') == 1
		ClassesVector = [ClassesVector InpResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v16p0(fCtr)];
	end
end

SortedIndFeaturesContrib = [];
SortedIndFeaturesContrib.FeaturesOrgOrder = FeaturesList;

if IgnoreBaseContribution == false
    SortedIndFeaturesContrib.BaselineAccuracy = ACD_ContributionBaseValue_v16p0(ClassesVector);
else
    SortedIndFeaturesContrib.BaselineAccuracy = 0;
end


PairwiseFeaturesContributions = zeros(length(InpResults.Features),length(InpResults.Features));


IndividualFeaturesContributions = zeros(1,length(InpResults.Features));
MaxividualFeaturesContributions = zeros(1,length(InpResults.Features));
IndividualFeaturesCount = zeros(1,length(InpResults.Features));

[CombinationLength, ~ ] = local_LongSize(InpResults.AnalysisInfo.AllPossibleCombinations);

FeatureFreq = zeros(1,length(InpResults.Features));
for combinationCtr=1:CombinationLength
	if InpResults.AccuraciesVector(combinationCtr) < TopNPercent
		continue;
	end
	Vector = InpResults.AnalysisInfo.AllPossibleCombinations(combinationCtr,:);
	Vector(Vector == 0) = [];
	for featureCtr=1:length(Vector)
		FeatureFreq(Vector(featureCtr)) = FeatureFreq(Vector(featureCtr)) + 1;
        
	end
end

FeatureFreq = FeatureFreq / nansum(FeatureFreq);

for combinationCtr=1:CombinationLength
	if InpResults.AccuraciesVector(combinationCtr) < TopNPercent
		continue;
	end
	Vector = InpResults.AnalysisInfo.AllPossibleCombinations(combinationCtr,:);
	Vector(Vector == 0) = [];
    
    FeaturesWeight = FeatureFreq(Vector);
    FeaturesWeight = FeaturesWeight ./ nansum(FeaturesWeight);
    
    
	for featureCtr=1:length(Vector)
		CurrentFeature = Vector(featureCtr);
		CurrentFeaturesMapped = CurrentFeature;%FeatureWeights(CurrentFeature).FeatureWeight;

        ContributionMain =(InpResults.AccuraciesVector(combinationCtr) - SortedIndFeaturesContrib.BaselineAccuracy);
		ContributionIndv = ContributionMain * FeaturesWeight(featureCtr); 
		ContributionIndv = ContributionIndv / length(CurrentFeaturesMapped);
        ConfScore = ACD_AUX_ConfusionMatrixScore_v16p0(InpResults.ConfusionMatrices(combinationCtr));
        ContributionIndv = ContributionIndv* ConfScore^2;
        
        ContributionMaxOverall = nanmax(InpResults.AccuraciesVector)-SortedIndFeaturesContrib.BaselineAccuracy;
		ContributionMaxv = ContributionMaxOverall * FeaturesWeight(featureCtr); 
		ContributionMaxv = ContributionMaxv / length(CurrentFeaturesMapped);
		if ContributionIndv > 0
			for ciCtr=1:length(CurrentFeaturesMapped)
				FeatInd = CurrentFeaturesMapped(ciCtr);
				IndividualFeaturesContributions(FeatInd) = IndividualFeaturesContributions(FeatInd) + ContributionIndv;
                MaxividualFeaturesContributions(FeatInd) = MaxividualFeaturesContributions(FeatInd) + ContributionMaxv;
            
				IndividualFeaturesCount(FeatInd) = IndividualFeaturesCount(FeatInd) + (1/ length(CurrentFeaturesMapped));
			end
		elseif isnan(ContributionIndv)
			continue;
		end
	end
end


FeatureContributionsWithOrgOrder = IndividualFeaturesContributions;

OutFeatures = InpResults.Features;
for iCtr=1:length(InpResults.Features)
    OutFeatures(iCtr).Contribution = FeatureContributionsWithOrgOrder(iCtr);
    OutFeatures(iCtr).Rank = nan;
end

TempContributions = FeatureContributionsWithOrgOrder;
RankCtr = 0;
for iCtr=1:length(InpResults.Features)
    RankCtr = RankCtr+1;
    [MaxContrib,Ind] = nanmax(TempContributions);
    if isnan(Ind) || MaxContrib <= 0 
        break;
    end
    TempContributions(Ind) = nan;
    OutFeatures(Ind).Rank = RankCtr;
end

FeatureContributionsWithOrgOrder = FeatureContributionsWithOrgOrder / nansum(MaxividualFeaturesContributions);

AnalysisResults = struct;
AnalysisResults.FeatureContWOrgOrder = FeatureContributionsWithOrgOrder;
AnalysisResults.OutFeatures = OutFeatures;
AnalysisResults.BaseContribution = SortedIndFeaturesContrib.BaselineAccuracy;
end

function [OutSize, OutIndex] = local_LongSize(Input)
if size(Input,1) < size(Input,2)
    OutSize = size(Input,2);
    OutIndex = 2;
else
    OutSize = size(Input,1);
    OutIndex = 1;
end
end
