% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [Results,AInfo]= ACD_NeuronCombinedClassifier_Global3_Parfor_v16p0(AInfo,CD,DispInfoLevel,Options)
CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Options.Version) == false
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Options.Version);
end
%   fC          Fold Counter
%   sC          States counter
%   sS          States String


AInfo.MaxAccuracies = [];


AInfo.UsableFeatures = CD.CD_GetUsableFeaturesVector_v16p0();
AInfo.UsableFeatures(ACD_ExtractStructField(AInfo.UsableFeatures,'Enabled') == 0) = [];

AInfoAllPossibleCombinations = ACD_AUX_CalcAllCombs_VecotrBased_v16p0(AInfo.UsableFeatures,Options.CurAttributeCount);

AInfoAllPossibleCombinations = AInfoAllPossibleCombinations(randperm(size(AInfoAllPossibleCombinations,1)),:);

AInfoConfusionMatrixSize = length(unique([CD.TrainingCls CD.TestingCls]));

AInfo.TestVector = 1:ACD_SizeLong(AInfoAllPossibleCombinations);
AInfo.vCtrIndex = 1:length(AInfo.TestVector);

[~, AInfo.TicStart] = ACD_TocPercent();



if Options.Forward1Reverse0 == 1
    AInfoMaximumValues= ones(1,Options.CurAttributeCount)*-inf;
%     AInfoAvgs(Options.CurAttributeCount) = [];
%     AInfoAvgs(Options.CurAttributeCount) = Options.CurAttributeCount + 1;
else
    AInfoMaximumValues= ones(1,length(AInfo.UsableFeatures))*-inf;
    AInfoAvgs = zeros(length(AInfo.UsableFeatures),Options.CurAttributeCount);
end

ResultsAccuraciesVector = [];%zeros(1,size(AInfoAllPossibleCombinations,1),'double');
% Results.Models = {};
% Results.Models{size(AInfoAllPossibleCombinations,1)} = [];
ResultsConfusionMatrices = [];
% ResultsConfusionMatrices{size(AInfoAllPossibleCombinations,1)} = [];
ResultsPredictionMatrix{size(AInfoAllPossibleCombinations,1)} = [];

for ffC = 1:Options.FoldCount , ffS = sprintf('Fold%02u',ffC);
    FncTrainingDataOrg.(ffS)   = CD.CD_GetTrainingObs_BOFoldNum_v16p0(ffC);
    FncTrainingClassOrg.(ffS)  = CD.CD_GetTrainingCls_BOFoldNum_v16p0(ffC);
    FncTestingDataOrg.(ffS)	= CD.CD_GetTestingObs_BOFoldNum_v16p0(ffC);
    FncTestingClassOrg.(ffS)   = CD.CD_GetTestingCls_BOFoldNum_v16p0(ffC);
end

AInfo.TicStart.TicCnt = 1;
CurrentvCtrVector = AInfo.vCtrIndex;

AInfo.StartTime = tic;

FoldCount = Options.FoldCount;
ProcessMode = Options.ProcessMode;

TicStart = AInfo.TicStart;
ProgressStatus   = 0;
parfor vCtr=CurrentvCtrVector
%     vCtr = CurrentvCtrVector(PtrVCtr);
    PassedTime = toc(TicStart.tic);
    
    if strcmpi(ProcessMode,'Testing')==1 && PassedTime > (ProcessModeTimer+5)
        continue;
    end
    try
        CurrentAttributeVector = AInfoAllPossibleCombinations(vCtr,:);
    catch ME
        1
    end
    CurrentAttributeVector(CurrentAttributeVector == 0) = [];
	CurrentAttCatStat = [];
    	
	VarLen = 0;
	for iCtr=1:length(CurrentAttributeVector)
		FeatureNumber = CurrentAttributeVector(iCtr);
		if strcmpi(CD.Features(FeatureNumber).Name,'UnitPrice') == 0
			CurrentAttCatStat(end+1) = iCtr;
		end
	end

    FncAverageAcc = [];
        
    FncConfusionMatrix = struct();
    FncModels = struct();
    FncPredMat = struct();
    for fC=1:FoldCount , fS = sprintf('Fold%02u',fC);
        FncConfusionMatrix.(fS) = zeros(AInfoConfusionMatrixSize,AInfoConfusionMatrixSize);
        FncModels.(fS) = {};
        FncPredMat.(fS) = {};
    end
    
    FncTestPredictions = []; FncTrainPredictions = [];
    FncTrainingDataTmp = []; FncTrainingClassTmp = [];
    FncTestingDataTmp = [];  FncTestingClassTmp  = [];
    FncNewCM = [];
    
    mdl = struct();
    FncAccTemp = struct();
    for fC=1:FoldCount , fS = sprintf('Fold%02u',fC);
%         try
            ;FncTrainingDataTmp.(fS)  = FncTrainingDataOrg.(fS)(:,CurrentAttributeVector);
            FncTrainingClassTmp.(fS)  = FncTrainingClassOrg.(fS)';
            assert(ACD_NanFree(FncTrainingDataTmp.(fS)));
            
            ;FncTestingDataTmp.(fS)   = FncTestingDataOrg.(fS)(:,CurrentAttributeVector);
            FncTestingClassTmp.(fS)   = FncTestingClassOrg.(fS)';
            assert(ACD_NanFree(FncTestingDataTmp.(fS)));
            
            
            mdl.(fS) = fitctree(FncTrainingDataTmp.(fS), FncTrainingClassTmp.(fS),'CategoricalPredictors',CurrentAttCatStat);
%             mdl.(fS) = fitcnb(FncTrainingDataTmp.(fS), FncTrainingClassTmp.(fS),'CategoricalPredictors',CurrentAttCatStat);
% 			mdl.(fS) = MSHN_BuildDecisioTree(FncTrainingDataTmp.(fS), FncTrainingClassTmp.(fS),0.9,'numeric');...'OptimizeHyperparameters',{'MinLeafSize'},...
			
%             FncTestPredictions.(fS) = MSHN_PredictByTree(mdl.(fS),FncTestingDataTmp.(fS));
            FncTestPredictions.(fS) = predict(mdl.(fS),FncTestingDataTmp.(fS));
            FncAccTemp.(fS) = (FncTestPredictions.(fS) == FncTestingClassTmp.(fS));
            FncAverageAcc.(fS) = nansum(FncAccTemp.(fS) / length(FncTestPredictions.(fS)));
            
            FncNewCM.(fS) = confusionmat(FncTestingClassTmp.(fS),FncTestPredictions.(fS));
			
            CurSize = size(FncNewCM.(fS),1);
			FncConfusionMatrix.(fS)(1:CurSize,1:CurSize) = FncConfusionMatrix.(fS) + FncNewCM.(fS);

			FncPredMat.(fS) = [FncPredMat.(fS) ; FncTestPredictions.(fS)];
            
%         catch ME
%             for meCtr=1:length(ME.stack)
%                 disp(ME.stack(meCtr));
%             end
%             if DispInfoLevel.Errors == 1
%                 fprintf('\n\t\t<<< Error Happened >>>');
%             end
%             rethrow(ME);
%         end
        
        FncAverageAcc.(fS) = nansum(FncAccTemp.(fS)) /length(FncTestPredictions.(fS));
    end
    Record = [];
    Record.Combination = CurrentAttributeVector;
    RecordAttributeCnt = length(CurrentAttributeVector);
    Record.CurrentCtr = vCtr;
%     Record.MaxCtr = length(AInfo.vCtrIndex);
    Record.Predictions = FncTestPredictions;
    
    RecAcc = [];
    for fC=1:FoldCount , fS = sprintf('Fold%02u',fC);
        if ~isempty(FncAverageAcc.(fS))
            for qCtr=1:length(FncAverageAcc.(fS))
                RecAcc(end+1) = FncAverageAcc.(fS)(qCtr);
            end
        end

        Record.ConfusionMatrix.(fS) = FncConfusionMatrix.(fS);
    end
    RecordAccuracy = nanmean(RecAcc);

%     AInfoAvgs(RecordAttributeCnt,end+1) = nanmean(RecAcc);

    ResultsAccuraciesVector(vCtr) = RecordAccuracy;
    ResultsConfusionMatrices(vCtr) = Record.ConfusionMatrix;
%     Results.Models(RecordIndex).Model = mdl;
    ResultsPredictionMatrix(vCtr) = Record.Predictions;
    ProgressStatus = ProgressStatus + 1;
    
%     if AInfoMaximumValues(RecordAttributeCnt) < RecordAccuracy
%         AInfoMaximumValues(RecordAttributeCnt) = RecordAccuracy;
%     end
    
    
    AInfo = ACD_DisplayStatus_Global_Parfor_v16p0(AInfo,DispInfoLevel,Options,ProgressStatus);
end
Results = struct;
Results.AccuraciesVector = ResultsAccuraciesVector;
Results.ConfusionMatrices = ResultsConfusionMatrices;
Results.PredictionMatrix = ResultsPredictionMatrix;
Results.AnalysisInfo = AInfo;
Options.PassedTime = PassedTime;
AInfo.EndTime = toc(AInfo.StartTime);
AInfo.Avgs = AInfoAvgs;
AInfo.MaximumValues = AInfoMaximumValues;

Results.Features = CD.CD_GetUsableFeaturesVector_v16p0();

end

