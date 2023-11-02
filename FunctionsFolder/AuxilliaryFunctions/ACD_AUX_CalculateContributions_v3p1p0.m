% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/10  Updating the contribution method
% $Revision: 2.0.1 $  $Date: 2021/05/10  Updating the contribution method, removing bugs
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $
% $Revision: 3.1.0 $  $Date: 2022/04/17  FeatureWeight is removed from individual contribution calculation function (local_CalculateContributionIndividually) $
%                                        Removed the baseline accuracy subtraction from local_CalculateContributionIndividually, as well


function [AnalysisResults] = ACD_AUX_CalculateContributions_v3p1p0(Version,InpPrvResults,InpDblPrvResults,BypassAccuracyCheck,IgnoreBaseContribution,Top_N_Percent)
CurrentVersion = 'AceDimerv3p0p0';

if strcmpi(CurrentVersion,Version) == 0
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

SortedAccuraciesVector = sortrows(InpPrvResults.AccuraciesVector',-1)';
if nargin <= 2
    BypassAccuracyCheck = 0;
end

if sum(InpPrvResults.AccuraciesVector ~= 0) < length(InpPrvResults.AccuraciesVector)*0.99 && (BypassAccuracyCheck == 0)
    error('Accuracies vector contains unexpected number of zeros!');
end

if BypassAccuracyCheck == true
    TopNPercent = 0;
else
    TopNPercent = nanmax(SortedAccuraciesVector)*Top_N_Percent;
end

assert(isnan(TopNPercent) == 0);
%the array of Features has the length of All features. The only
%difference is that the Enabled field of features indicate which ones are
%enabled (1) or disabled (0)
NumberOfFeatures = 0;%length(Features);
FeaturesList = [];
for iCtr=1:length(InpPrvResults.Features)
    if InpPrvResults.Features(iCtr).Enabled == 1
        NumberOfFeatures = NumberOfFeatures + 1;
        FeaturesList(iCtr) = InpPrvResults.Features(iCtr).Number;
    else
        FeaturesList(iCtr) = 0;
    end
end

ClassesVector = [];
for fCtr = 1:InpPrvResults.ClassesData.GetFoldCount()
    if strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v14p4') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v14p4(fCtr)];
    elseif strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v14p5') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v14p5(fCtr)];
    elseif strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v16p0') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v16p0(fCtr)];
    elseif strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v2p0p0') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v2p0p0(fCtr)];
    elseif strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v2p1p0') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v2p1p0(fCtr)];
    elseif strcmpi(class(InpPrvResults.ClassesData),'ClassificationData_v3p0p0') == 1
        ClassesVector = [ClassesVector InpPrvResults.ClassesData.CD_GetTrainingCls_BOFoldNum_v3p0p0(fCtr)];
    end
end

SortedIndFeaturesContrib = [];
SortedIndFeaturesContrib.FeaturesOrgOrder = FeaturesList;

if IgnoreBaseContribution == false
    SortedIndFeaturesContrib.BaselineAccuracy = ACD_ContributionBaseValue_v3p0p0(ClassesVector);
else
    SortedIndFeaturesContrib.BaselineAccuracy = 0;
end


if isempty(InpDblPrvResults)
    [ContributionData] = local_CalculateContributionIndividually(InpPrvResults,TopNPercent,SortedIndFeaturesContrib);
else
    [ContributionData] = local_CalculateContributionIndividually(InpPrvResults,TopNPercent,SortedIndFeaturesContrib);
%     [ContributionData] = local_CalculateContrtibutionBasedOnPrevious(InpPrvResults,InpDblPrvResults,TopNPercent);
end

% % % % % % % % Hererrr

Out.Features = ContributionData.Features;
if isfield(ContributionData,'CorrelationData_2D')
    Out.CorrelationData_2D = ContributionData.CorrelationData_2D;
end
for iCtr=1:length(InpPrvResults.Features)
    Out.Features(iCtr).ContributionSum = nansum(Out.Features(iCtr).Contributions);
    Out.Features(iCtr).ContributionAvg = nanmean(Out.Features(iCtr).Contributions);
    Out.Features(iCtr).ContributionStd = nanstd(Out.Features(iCtr).Contributions);
    Out.Features(iCtr).Rank = nan;
end

if isempty(InpDblPrvResults)
    TempContributions= ContributionData.IndividualFeaturesContributions;
else
    TempContributions = ACD_ExtractStructField(Out.Features,'ContributionSum');
end
FeatureContributionsWithOrgOrder = TempContributions;

RankCtr = 0;
for iCtr=1:length(InpPrvResults.Features)
    RankCtr = RankCtr+1;
    [MaxContrib,Ind] = nanmax(TempContributions);
    if isnan(Ind) || MaxContrib <= 0
        break;
    end
    TempContributions(Ind) = nan;
    Out.Features(Ind).Rank = RankCtr;
end

AnalysisResults = struct;
AnalysisResults.FeatureContWOrgOrder = FeatureContributionsWithOrgOrder;
AnalysisResults.Features = Out.Features;
AnalysisResults.IndividualFeaturesCount = ContributionData.IndividualFeaturesCount;
if isfield(Out,'CorrelationData_2D')
    AnalysisResults.CorrelationData_2D = Out.CorrelationData_2D;
end
% AnalysisResults.BaseContribution = SortedIndFeaturesContrib.BaselineAccuracy;
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

function [Out] = local_CalculateContrtibutionBasedOnPrevious(InpPrvResults,InpDblPrvResults,TopNPercent)
[CombinationLength, ~ ] = local_LongSize(InpPrvResults.AnalysisInfo.AllPossibleCombinations);
Out = struct;
Out.IndividualFeaturesContributions = zeros(1,length(InpPrvResults.Features));
Out.MaxividualFeaturesContributions = zeros(1,length(InpPrvResults.Features));
Out.IndividualFeaturesCount = zeros(1,length(InpPrvResults.Features));
Out.CorrelationData_2D = zeros(length(InpPrvResults.Features),length(InpPrvResults.Features));
Out.CorrelationData_3D = zeros(length(InpPrvResults.Features),length(InpPrvResults.Features),length(InpPrvResults.Features));
Out.CorrelationData_1D = nan(length(InpPrvResults.Features),local_LongSize(InpPrvResults.AnalysisInfo.AllPossibleCombinations));
Out.CorrelationData_1D_Target = nan(length(InpPrvResults.Features),local_LongSize(InpPrvResults.AnalysisInfo.AllPossibleCombinations),9);

% Out.FeatureCorrelationVect = 

FeatureMask = ACD_ExtractStructField(InpPrvResults.Features,'Enabled');
FeatureNumber = 1:length(InpPrvResults.Features);
FeatureNumber(FeatureMask == 0) = [];

Out.Features = InpPrvResults.Features;
for iCtr=1:length(Out.Features)
    Out.Features(iCtr).Frequency = 0;
    Out.Features(iCtr).Contributions = [];
end
for combinationCtr=1:CombinationLength
    if InpPrvResults.AccuraciesVector(combinationCtr) < TopNPercent
%         continue;
    end
    IndexVector = InpPrvResults.AnalysisInfo.AllPossibleCombinations(combinationCtr,:);
    IndexVector(IndexVector == 0) = [];
    for featureCtr=1:length(IndexVector)
        FeatNum = FeatureNumber(IndexVector(featureCtr));
        Out.Features(FeatNum).Frequency = Out.Features(FeatNum).Frequency + 1;
        
    end
end

FeatureFreq = ACD_ExtractStructField(Out.Features,'Frequency');

FeatureFreq = FeatureFreq / nansum(FeatureFreq);

AllPossSortedCombinations = ACD_Contribution_Lookup_Preparation_v3p0p0(InpDblPrvResults.AnalysisInfo.AllPossibleCombinations);

ACD_Contribution_Lookup_Prv_Accuracy_v3p0p0(AllPossSortedCombinations,[],true);

for combinationCtr=1:CombinationLength
    if InpPrvResults.AccuraciesVector(combinationCtr) < TopNPercent
%         continue;
    end
    IndexVector = InpPrvResults.AnalysisInfo.AllPossibleCombinations(combinationCtr,:);
    IndexVector(IndexVector == 0) = [];
    FeatureVector = FeatureNumber(IndexVector);
    
    FeaturesWeight = FeatureFreq(FeatureVector);
    FeaturesWeight = FeaturesWeight ./ nansum(FeaturesWeight);
    
    for featureCtr=1:length(IndexVector)
        PrvVect = IndexVector;
        PrvVect(featureCtr) = [];
        PrvInd = ACD_Contribution_Lookup_Prv_Accuracy_v3p0p0(AllPossSortedCombinations,PrvVect,false);
        DblPrvAccuracy = InpDblPrvResults.AccuraciesVector(PrvInd);
        
        CurrentFeature = FeatureVector(featureCtr);
        
        ContributionIndv = InpPrvResults.AccuraciesVector(combinationCtr) - DblPrvAccuracy;
        
        Out.Features(CurrentFeature).Contributions(end+1) = ContributionIndv;
        Out.CorrelationData_1D(CurrentFeature,combinationCtr) = ContributionIndv;
        Out.MaxividualFeaturesContributions(CurrentFeature) = Out.MaxividualFeaturesContributions(CurrentFeature) + ContributionIndv;
        
        Out.IndividualFeaturesCount(CurrentFeature) = Out.IndividualFeaturesCount(CurrentFeature) + 1;
        Out.IndividualFeaturesContributions(CurrentFeature) = Out.IndividualFeaturesContributions(CurrentFeature) + ContributionIndv;
        
        for tmpCtr=1:length(PrvVect)
            Out.CorrelationData_2D(CurrentFeature,PrvVect(tmpCtr)) = Out.CorrelationData_2D(CurrentFeature,PrvVect(tmpCtr)) + ContributionIndv;
        end
    end

  
    
end
end


function [Out] = local_CalculateContributionIndividually(InpPrvResults,TopNPercent,SortedIndFeaturesContrib)
Out = struct;
Out.IndividualFeaturesContributions = zeros(1,length(InpPrvResults.Features));
Out.MaxividualFeaturesContributions = zeros(1,length(InpPrvResults.Features));
Out.IndividualFeaturesCount = zeros(1,length(InpPrvResults.Features));

[CombinationLength, ~ ] = local_LongSize(InpPrvResults.AnalysisInfo.AllPossibleCombinations);

Out.Features = InpPrvResults.Features;
for iCtr=1:length(Out.Features)
    Out.Features(iCtr).Frequency = 0;
    Out.Features(iCtr).Contributions = [];
end


for combinationCtr=1:CombinationLength
% Top N Percent features are not considered anymore (all features are considered)
%     if InpPrvResults.AccuraciesVector(combinationCtr) < TopNPercent
%         continue;
%     end
    Vector = InpPrvResults.AnalysisInfo.AllPossibleCombinations(combinationCtr,:);
    Vector(Vector == 0) = [];
    
    for featureCtr=1:length(Vector)
        CurrentFeature = Vector(featureCtr);
        CurrentFeaturesMapped = CurrentFeature;%FeatureWeights(CurrentFeature).FeatureWeight;
        
        ContributionMain = (InpPrvResults.AccuraciesVector(combinationCtr));% - SortedIndFeaturesContrib.BaselineAccuracy);
        ContributionIndv = ContributionMain;
%         ContributionIndv = ContributionIndv / length(CurrentFeaturesMapped);
%         ConfScore = ACD_AUX_ConfusionMatrixScore_v3p0p0(InpPrvResults.ConfusionMatrices(combinationCtr));
%         ContributionIndv = ContributionIndv* ConfScore^2;
        
        if isnan(ContributionIndv)
            continue;
        else
            for ciCtr=1:length(Vector)
                FeatInd = Vector(ciCtr);
                Out.Features(CurrentFeature).Contributions(end+1) = ContributionIndv;
                Out.IndividualFeaturesCount(FeatInd) = Out.IndividualFeaturesCount(FeatInd) + (1/ length(CurrentFeaturesMapped));
                Out.IndividualFeaturesContributions(FeatInd) = Out.IndividualFeaturesContributions(FeatInd) + ContributionIndv;
            end
            
        end
    end
end
end