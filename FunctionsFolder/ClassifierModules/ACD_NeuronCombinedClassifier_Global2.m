% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [Results,AInfo]= ACD_NeuronCombinedClassifier_Global2_v16p0(AInfo,CD,DispInfoLevel,Options)
% ClassifierTypes:		'LinearDiscriminantAnalysis'
% 						'DecisionTree'
% 						'NaiveBayes'
% 						'KNearestNeighbours'

CurrentVersion = 'AceDimer16p0';

if strcmpi(CurrentVersion,Options.Version) == false
    error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Options.Version);
end
%   fC          Fold Counter
%   sC          States counter
%   sS          States String

Fnc = [];


AInfo.MaxAccuracies = [];


AInfo.UsableFeatures = CD.CD_GetUsableFeaturesVector_v16p0();
AInfo.UsableFeatures(ACD_ExtractStructField(AInfo.UsableFeatures,'Enabled') == 0) = [];

AInfo.AllPossibleCombinations = ACD_AUX_CalcAllCombs_VecotrBased_v16p0(AInfo.UsableFeatures,Options.CurAttributeCount);

AInfo.AllPossibleCombinations = AInfo.AllPossibleCombinations(randperm(size(AInfo.AllPossibleCombinations,1)),:);

AInfo.ConfusionMatrixSize = length(unique([CD.TrainingCls CD.TestingCls]));

AInfo.TestVector = 1:ACD_SizeLong(AInfo.AllPossibleCombinations);
AInfo.vCtrIndex = 1:length(AInfo.TestVector);

[~, AInfo.TicStart] = ACD_TocPercent();



% calculating number of classes and their values for LDA classifier
ClassesVector = [];
for fCtr = 1:CD.GetFoldCount()
    ClassesVector = [ClassesVector CD.CD_GetTrainingCls_BOFoldNum_v16p0(fCtr)];
end
ClassValuesInOrder = unique(ClassesVector);


if Options.Forward1Reverse0 == 1
    AInfo.MaximumValues= ones(1,Options.CurAttributeCount)*-inf;
    Avgs = zeros(length(AInfo.UsableFeatures),ACD_SizeLong(AInfo.AllPossibleCombinations));
else
    AInfo.MaximumValues= ones(1,length(AInfo.UsableFeatures))*-inf;
    Avgs = zeros(length(AInfo.UsableFeatures),ACD_SizeLong(AInfo.AllPossibleCombinations));
end

% Results.AccuraciesVector = nan(1,size(AInfo.AllPossibleCombinations,1));
% Results.Models = {};
% Results.Models{size(AInfo.AllPossibleCombinations,1)} = [];
% Results.ConfusionMatrices = {};
% Results.ConfusionMatrices{size(AInfo.AllPossibleCombinations,1)} = [];
% Results.PredictionMatrix{size(AInfo.AllPossibleCombinations,1)} = [];

for ffC = 1:Options.FoldCount , ffS = sprintf('Fold%02u',ffC);
    Fnc.TrainingDataOrg.(ffS)   = CD.CD_GetTrainingObs_BOFoldNum_v16p0(ffC);
    Fnc.TrainingClassOrg.(ffS)  = CD.CD_GetTrainingCls_BOFoldNum_v16p0(ffC);
    Fnc.TestingDataOrg.(ffS)	= CD.CD_GetTestingObs_BOFoldNum_v16p0(ffC);
    Fnc.TestingClassOrg.(ffS)   = CD.CD_GetTestingCls_BOFoldNum_v16p0(ffC);
end

AInfo.TicStart.TicCnt = 1;
Results.ProgressStatus   = nan(1,size(AInfo.AllPossibleCombinations,1));
CurrentvCtrVector = AInfo.vCtrIndex;

AInfo.StartTime = tic;

PtrVector = 1:length(CurrentvCtrVector);
PtrVector = PtrVector(randperm(end));
for PtrVCtr=PtrVector     ,           vCtr = CurrentvCtrVector(PtrVCtr);
    Options.PassedTime = toc(AInfo.TicStart.tic);
    
    if strcmpi(Options.ProcessMode,'Testing')==1 && Options.PassedTime > (Options.ProcessModeTimer+5)
        break;
    end
    try
        CurrentAttributeVector = AInfo.AllPossibleCombinations(vCtr,:);
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

    Fnc.AverageAcc = [];
        
    for fC=1:Options.FoldCount , fS = sprintf('Fold%02u',fC);
        Fnc.ConfusionMatrix.(fS) = zeros(AInfo.ConfusionMatrixSize,AInfo.ConfusionMatrixSize);
        Fnc.Models.(fS) = {};
        Fnc.PredMat.(fS) = {};
    end
    
    Fnc.TestPredictions = []; Fnc.TrainPredictions = [];
    Fnc.TrainingDataTmp = []; Fnc.TrainingClassTmp = [];
    Fnc.TestingDataTmp = [];  Fnc.TestingClassTmp  = [];
    Fnc.NewCM = [];
    
    for fC=1:Options.FoldCount , fS = sprintf('Fold%02u',fC);
%         try
            ;Fnc.TrainingDataTmp.(fS)  = Fnc.TrainingDataOrg.(fS)(:,CurrentAttributeVector);
            Fnc.TrainingClassTmp.(fS)  = Fnc.TrainingClassOrg.(fS)';
            assert(ACD_NanFree(Fnc.TrainingDataTmp.(fS)));
            
            ;Fnc.TestingDataTmp.(fS)   = Fnc.TestingDataOrg.(fS)(:,CurrentAttributeVector);
            Fnc.TestingClassTmp.(fS)   = Fnc.TestingClassOrg.(fS)';
            assert(ACD_NanFree(Fnc.TestingDataTmp.(fS)));
            
            
%             
% 			mdl.(fS) = fitcdiscr(Fnc.TrainingDataTmp.(fS), Fnc.TrainingClassTmp.(fS),'discrimType','pseudoLinear');
			if strcmpi(Options.SelectedClassifier,'LinearDiscriminantAnalysis')
				mdl.(fS) = ACD_LDA_v16p1(Fnc.TrainingDataTmp.(fS), Fnc.TrainingClassTmp.(fS));
	            Fnc.TestPredictions.(fS) = ACD_LDA_Predict_v16p1(mdl.(fS),Fnc.TestingDataTmp.(fS))';
	            Fnc.AccTemp.(fS) = ACD_RowColVectEqual_v16p0(Fnc.TestPredictions.(fS),Fnc.TestingClassTmp.(fS));
	            Fnc.NewCM.(fS) = confusionmat(Fnc.TestingClassTmp.(fS),Fnc.TestPredictions.(fS));
			elseif strcmpi(Options.SelectedClassifier,'DecisionTree')
				mdl.(fS) = fitctree(Fnc.TrainingDataTmp.(fS), Fnc.TrainingClassTmp.(fS),'CategoricalPredictors',CurrentAttCatStat);
	            Fnc.TestPredictions.(fS) = predict(mdl.(fS),Fnc.TestingDataTmp.(fS));
	            Fnc.AccTemp.(fS) = (Fnc.TestPredictions.(fS) == Fnc.TestingClassTmp.(fS));
	            Fnc.NewCM.(fS) = confusionmat(Fnc.TestingClassTmp.(fS),Fnc.TestPredictions.(fS));
			elseif strcmpi(Options.SelectedClassifier,'NaiveBayes')
				mdl.(fS) = fitcnb(Fnc.TrainingDataTmp.(fS), Fnc.TrainingClassTmp.(fS),'CategoricalPredictors',CurrentAttCatStat);
	            Fnc.TestPredictions.(fS) = predict(mdl.(fS),Fnc.TestingDataTmp.(fS));
	            Fnc.AccTemp.(fS) = (Fnc.TestPredictions.(fS) == Fnc.TestingClassTmp.(fS));
	            Fnc.NewCM.(fS) = confusionmat(Fnc.TestingClassTmp.(fS),Fnc.TestPredictions.(fS));
			elseif strcmpi(Options.SelectedClassifier,'KNearestNeighbours')
				mdl.(fS) = fitcknn(Fnc.TrainingDataTmp.(fS), Fnc.TrainingClassTmp.(fS),'CategoricalPredictors',CurrentAttCatStat);
	            Fnc.TestPredictions.(fS) = predict(mdl.(fS),Fnc.TestingDataTmp.(fS));
	            Fnc.AccTemp.(fS) = (Fnc.TestPredictions.(fS) == Fnc.TestingClassTmp.(fS));
	            Fnc.NewCM.(fS) = confusionmat(Fnc.TestingClassTmp.(fS),Fnc.TestPredictions.(fS));
			elseif strcmpi(Options.SelectedClassifier,'SpaceVectorMachine')
				[tmpW,tmpB] = ACD_SVM_Classifier(Fnc.TrainingDataTmp.(fS)', Fnc.TrainingClassTmp.(fS)',ClassValuesInOrder);
	            Fnc.TestPredictions.(fS) = ACD_SVM_Predictor(tmpW,tmpB,Fnc.TestingDataTmp.(fS)',ClassValuesInOrder)';
	            Fnc.AccTemp.(fS) = (Fnc.TestPredictions.(fS) == double(Fnc.TestingClassTmp.(fS)));
	            Fnc.NewCM.(fS) = confusionmat(double(Fnc.TestingClassTmp.(fS)),Fnc.TestPredictions.(fS));
			end
			
			
            Fnc.AverageAcc.(fS) = nansum(Fnc.AccTemp.(fS) / length(Fnc.TestPredictions.(fS)));
            
			
            CurSize = size(Fnc.NewCM.(fS),1);
			Fnc.ConfusionMatrix.(fS)(1:CurSize,1:CurSize) = Fnc.ConfusionMatrix.(fS) + Fnc.NewCM.(fS);

			Fnc.PredMat.(fS) = [Fnc.PredMat.(fS) ; Fnc.TestPredictions.(fS)];
            
%         catch ME
%             for meCtr=1:length(ME.stack)
%                 disp(ME.stack(meCtr));
%             end
%             if DispInfoLevel.Errors == 1
%                 fprintf('\n\t\t<<< Error Happened >>>');
%             end
%             rethrow(ME);
%         end
        
        Fnc.AverageAcc.(fS) = nansum(Fnc.AccTemp.(fS)) /length(Fnc.TestPredictions.(fS));
    end
    Record = [];
    Record.Index = vCtr;
    
    Record.Combination = CurrentAttributeVector;
    Record.AttributeCnt = length(CurrentAttributeVector);
    Record.CurrentCtr = PtrVCtr;
    Record.MaxCtr = length(AInfo.vCtrIndex);
    Record.Predictions = Fnc.TestPredictions;
    
    RecAcc = [];
    for fC=1:Options.FoldCount , fS = sprintf('Fold%02u',fC);
        if ~isempty(Fnc.AverageAcc.(fS))
            for qCtr=1:length(Fnc.AverageAcc.(fS))
                RecAcc(end+1) = Fnc.AverageAcc.(fS)(qCtr);
            end
        end

        Record.ConfusionMatrix.(fS) = Fnc.ConfusionMatrix.(fS);
    end
    Record.Accuracy = nanmean(RecAcc);

    Avgs(Record.AttributeCnt,PtrVCtr) = Record.Accuracy;

    Results.AccuraciesVector(Record.Index) = Record.Accuracy;
    Results.ConfusionMatrices(Record.Index) = Record.ConfusionMatrix;
%     Results.Models(Record.Index).Model = mdl;
    Results.PredictionMatrix(Record.Index) = Record.Predictions;
    
    if AInfo.MaximumValues(Record.AttributeCnt) < Record.Accuracy
        AInfo.MaximumValues(Record.AttributeCnt) = Record.Accuracy;
    end
    
    
    Results.ProgressStatus(Record.Index) = 1;
    Results.AnalysisInfo = AInfo;
    AInfo = ACD_DisplayStatus_Global_v16p0(AInfo,Results,DispInfoLevel,Options,Avgs);
end
AInfo.EndTime = toc(AInfo.StartTime);
AInfo.Avgs = Avgs;

Results.Features = CD.CD_GetUsableFeaturesVector_v16p0();
Results.ClassesData = CD;

end


