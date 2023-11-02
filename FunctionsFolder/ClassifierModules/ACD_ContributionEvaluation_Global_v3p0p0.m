% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [FeatureContributionsWithOrgOrder, OutFeatures] = ACD_ContributionEvaluation_Global_v3p0p0(ClassesData,FeaturesVector,Top_N_Percent,AccuraciesVector,AllPossibleCombinations,BypassAccuracyCheck,IgnoreBaseContribution,Options)
CurrentVersion = 'AceDimerv3p0p0';

if strcmpi(CurrentVersion,Options.Version) == 0
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

SortedAccuraciesVector = sortrows(AccuraciesVector',-1)';
if nargin <= 2
	BypassAccuracyCheck = 0;
end

if sum(AccuraciesVector ~= 0) < length(AccuraciesVector)*0.99 && (BypassAccuracyCheck == 0)
	error('Accuracies vector contains unexpected number of zeros!');
end
TopNPercent = nanmax(SortedAccuraciesVector)* Top_N_Percent;

assert(isnan(TopNPercent) == 0);
%the array of FeaturesVector has the length of All features. The only
%difference is that the Enabled field of features indicate which ones are
%enabled (1) or disabled (0)
NumberOfFeatures = 0;%length(FeaturesVector);
FeaturesOrgOrder = [];
for iCtr=1:length(FeaturesVector)
    if FeaturesVector(iCtr).Enabled == 1
        NumberOfFeatures = NumberOfFeatures + 1;
        FeaturesOrgOrder(end+1) = FeaturesVector(iCtr).Number;
    end
end
 
% if size(TrainClsVector,1) < size(TrainClsVector,2), TrainClsVector = TrainClsVector';end
% if size(TestClsVector,1) < size(TestClsVector,2), TestClsVector = TestClsVector';end
ClassesVector = [];
for fCtr = 1:ClassesData.GetFoldCount()
    ClassesVector = [ClassesVector ClassesData.CD_GetTrainingCls_BOFoldNum_v3p0p0(fCtr)];
end

if IgnoreBaseContribution == false
    BaselineAccuracy = ACD_ContributionBaseValue_v3p0p0(ClassesVector);
else
    BaselineAccuracy = 0;
end

IndividualFeaturesContributions = zeros(1,length(FeaturesVector));
IndividualFeaturesCount = zeros(1,length(FeaturesVector));

[CombinationLength, ~ ] = local_SizeLong(AllPossibleCombinations);
MaxLen = nanmin([CombinationLength length(AccuraciesVector)]);
if Options.Forward1Reverse0 == 1
    for combinationCtr=1:MaxLen
    % 	if AccuraciesVector(combinationCtr) < TopNPercent
    % 		continue;
    % 	end
        Vector = AllPossibleCombinations(combinationCtr,:);
        Vector(Vector == 0) = [];
        for featureCtr=1:length(Vector)
            CurrentFeature = FeaturesOrgOrder(Vector(featureCtr));

            ContributionMain =(AccuraciesVector(combinationCtr) - BaselineAccuracy);
            ContributionIndv = ContributionMain / ((length(Vector)));
            if ContributionIndv > 0
                IndividualFeaturesContributions(CurrentFeature) = IndividualFeaturesContributions(CurrentFeature) + ContributionIndv;

                IndividualFeaturesCount(CurrentFeature) = IndividualFeaturesCount(CurrentFeature) + 1;
            elseif isnan(ContributionIndv)
                continue;
            end
        end
    end
else
    for combinationCtr=1:MaxLen
    % 	if AccuraciesVector(combinationCtr) < TopNPercent
    % 		continue;
    % 	end
        Vector = AllPossibleCombinations(combinationCtr,:);
        Vector(Vector == 0) = [];
        for featureCtr=1:length(Vector)
            CurrentFeature = FeaturesOrgOrder(Vector(featureCtr));

            ContributionMain =(AccuraciesVector(combinationCtr) - SortedIndFeaturesContrib.BaselineAccuracy);
            ContributionIndv = ContributionMain / ((length(Vector)));
            if ContributionIndv > 0
                ComplimentFeatureVect = Vector;
                ComplimentFeatureVect(featureCtr) = [];
                IndividualFeaturesContributions(ComplimentFeatureVect) = IndividualFeaturesContributions(ComplimentFeatureVect) + ContributionIndv;

                IndividualFeaturesCount(ComplimentFeatureVect) = IndividualFeaturesCount(ComplimentFeatureVect) + 1;
            elseif isnan(ContributionIndv)
                continue;
            end
        end
    end
end

% [SortedIndFeaturesContrib.Value,SortedIndFeaturesContrib.Index] = sortrows(IndividualFeaturesContributions',-1);
% NewOrder = SortedIndFeaturesContrib.Index;
% SortedIndFeaturesContrib.FeaturesNewOrder = SortedIndFeaturesContrib.FeaturesOrgOrder(NewOrder);

FeatureContributionsWithOrgOrder = IndividualFeaturesContributions;

OutFeatures = FeaturesVector;
for iCtr=1:length(FeaturesVector)
    OutFeatures(iCtr).Contribution = FeatureContributionsWithOrgOrder(iCtr);
    OutFeatures(iCtr).Rank = nan;
end

TempContributions = FeatureContributionsWithOrgOrder;
RankCtr = 0;
for iCtr=1:length(FeaturesVector)
    RankCtr = RankCtr+1;
    [MaxContrib,Ind] = nanmax(TempContributions);
    if isnan(Ind) || MaxContrib <= 0 
        break;
    end
    TempContributions(Ind) = nan;
    OutFeatures(Ind).Rank = RankCtr;
end

end

function [OutSize, OutIndex] = local_SizeLong(Input)
if size(Input,1) < size(Input,2)
    OutSize = size(Input,2);
    OutIndex = 2;
else
    OutSize = size(Input,1);
    OutIndex = 1;
end
end
