% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $


% 	ClassesData,FeaturesVector,Top_N_Percent,AccuraciesVector,AllPossibleCombinations,BypassAccuracyCheck,IgnoreBaseContribution,Options)...

[FeatureContributionsWithOrgOrder, OutFeatures] = ACD_ContributionEvaluation_IndividualClassBased_v16p0(...
	SaveResults.ClassesData.ClsCondition,...ClassesData
	SaveResults.AnalysisInfo.ClsCondition.NewFeaturesList,...FeaturesVector
	0.05,...Top_N_Percent
	SaveResults.AnalysisOutput.ClsCondition.AccuraciesVector,...AccuraciesVector
	SaveResults.AnalysisOutput.ClsCondition.ConfusionMatrices,...ConfusionMatrices
	SaveResults.AnalysisInfo.ClsCondition.AllPossibleCombinations,...AllPossibleCombinations
	false,...BypassAccuracyCheck
	false,...IgnoreBaseContribution
	OptionsOrg);
