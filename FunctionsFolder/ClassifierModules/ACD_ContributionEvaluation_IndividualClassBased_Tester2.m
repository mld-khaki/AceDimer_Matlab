% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

AnalysisInfo.(dpStr).FeatureCnt = nansum(ClassesData.(dpStr).GetUsableFeaturesIndex() ~= 0);
TrainerConfig.MinAttributeCount = CurrentAttributeCount;
TrainerConfig.MaxAttributeCount = CurrentAttributeCount;
if TrainerConfig.MaxAttributeCount > 2 %Last analysis was successfull
	[UpdatedVector.(dpStr), UpdatedCount.(dpStr)] = ACD_CalculateNextSetCount_Global_v16p0(TempResults.(dpStr),ClassesData.(dpStr),AnalysisInfo.(dpStr),TrainerConfig,OptionsOrg);
	
	ClassesData.(dpStr) = ClassesData.(dpStr).CD_UpdateVariablesWithNewUsableFeatures_v16p0(UpdatedVector.(dpStr));
	
	AnalysisInfo.(dpStr).FeatureCnt = UpdatedCount;
end

TrainerConfig.ProcessMode = 'Testing';
if TrainerConfig.MaxAttributeCount == 2
	TrainerConfig.ProcessModeTimer = 20;%Sec
elseif TrainerConfig.MaxAttributeCount == 3
	TrainerConfig.ProcessModeTimer = 120;%Sec
else
	TrainerConfig.ProcessModeTimer = 180;%Sec
end

TrainerConfig.CurrentState = dpStr;
TrainerConfig.ChanceAccuracy = 1/length(unique(ClassesVar));
[TempResults.(dpStr),AnalysisInfo.(dpStr)] = ACD_NeuronCombinedClassifier_Global_v16p0(AnalysisInfo.(dpStr),ClassesData.(dpStr),DispInfoLevel,OthersInfo.(dpStr),TrainerConfig,OptionsOrg);

[UpdatedVector.(dpStr), UpdatedCount.(dpStr)] = ACD_CalculateNextSetCount_Global_v16p0(TempResults.(dpStr),ClassesData.(dpStr),AnalysisInfo.(dpStr),TrainerConfig,OptionsOrg);

ClassesData.(dpStr) = ClassesData.(dpStr).CD_UpdateVariablesWithNewUsableFeatures_v16p0(UpdatedVector.(dpStr));

AnalysisInfo.(dpStr).FeatureCnt = UpdatedCount;

TrainerConfig.ProcessMode = 'Training';
TrainerConfig.ProcessModeTimer = -1;

TrainerConfig.CurrentState = dpStr;
[TempResults.(dpStr),AnalysisInfo.(dpStr)] = ACD_NeuronCombinedClassifier_Global_v16p0(AnalysisInfo.(dpStr),ClassesData.(dpStr),DispInfoLevel,OthersInfo.(dpStr),TrainerConfig,OptionsOrg);

Output.(dpStr) = TempResults.(dpStr);

Outputs.(dpStr){end+1} = TempResults.(dpStr);

if ~isfield(AnalysisInfo.(dpStr),'MaxAccuracies')
	AnalysisInfo.(dpStr).MaxAccuracies = [];
end
