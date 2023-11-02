% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

classdef ClassificationData_v3p0p0
	properties (Access = private)
		PropertyNames = {'FeaturesInitialized',...
			'ForcedBalanced','EqualFoldCount','DebugEnabled',...
			'FoldCount','NormalizeData','ScarceAccepted','InputObservations',...
			'FeaturesSpecs','InputClasses','BypassWarning','JitterWeight','JitterPercentage'};
		InputData = nan;
		
		% if you have separate testing and training variables, it is
		% assumed that you have ensured that the train and test do not overlap
		Version = 'AceDimerV3p0p0';
		DebugEnabled = 0;
		BypassWarning = 0;
		
		FoldCount = nan;
		AcheivedCount = nan;
		
		FeaturesInitialized = nan;
	end
	
	properties
		EqualFoldCount = -1;
		JitterWeight = 0;
		JitterPercentage = 0;
		ScarceAccepted = false;
		NormalizeData = false;
		MetaData = nan;
		ForcedBalanced = nan;
		TrainingObs = nan;
		TestingObs = nan;
		TrainingCls = nan;
		TestingCls = nan;
		Features = nan;
		
		InputObservations = nan;
		FeaturesSpecs = nan;
		InputClasses = nan;
		
		
		TrainFoldIndexes = nan;
		TestFoldIndexes = nan;
		
		TrainFoldsBNs = nan; % Balanced Training Folds Non Scarce Classes
		TrainFoldsBSc = nan; % Balanced Training Folds Scarce Classes
		TestFoldsBNs = nan; % Balanced Testing Folds Non Scarce Classes
		TestFoldsBSc = nan; % Balanced Testing Folds Scarce Classes
		
		TrainFoldsNs = nan; % Balanced Training Folds Non Scarce Classes
		TrainFoldsSc = nan; % Balanced Training Folds Scarce Classes
		TestFoldsNs = nan; % Balanced Testing Folds Non Scarce Classes
		TestFoldsSc = nan; % Balanced Testing Folds Scarce Classes
	end
	
	methods (Access = private)
		[obj,NsFolds,ScFolds]		= CD_GenerateFoldIndex_v3p0p0(obj,ObservationVector,ClassVector,FoldCount);
		[obj,BNsFolds,BScFolds]		= CD_BalanceFoldsAndScarceFolds_v3p0p0(obj,NsFolds,ScFolds,JitterWeight,JitterPercentage);
		%         Out = CD_Matrix_Fuse(obj,Input1,Input2,FuseType)
		[Folds, Classes, ClassIndex] = CD_GetTstTrnFold_v3p0p0(obj,NsFolds,ScFolds,TTrainFTest,FoldCount,SelectedFold);
		
		function Count = CD_GetAcheivedCount(obj)
			if ~isnan(obj.AcheivedCount)
				Count = obj.AcheivedCount;
			else
				Count = -1;
			end
		end
		function obj = CD_BalanceData(obj)
			if (obj.ForcedBalanced == 1)
				if (~isstruct(obj.TrainFoldsNs) || ~isstruct(obj.TrainFoldsSc)) && obj.FoldCount ~= 1
					error('Training data folds cannot be undefined!');
				end
				if (~isstruct(obj.TestFoldsNs)  || ~isstruct(obj.TestFoldsSc)) && obj.FoldCount ~= 1
					error('Training data folds cannot be undefined!');
				end
				if isnan(obj.FoldCount)
					error('Testing data folds cannot be undefined!');
				end
				
				[obj,obj.TrainFoldsBNs, obj.TrainFoldsBSc]	= obj.CD_BalanceFoldsAndScarceFolds_v3p0p0(obj.TrainFoldsNs,obj.TrainFoldsSc,obj.JitterWeight,obj.JitterPercentage);
				[obj,obj.TestFoldsBNs , obj.TestFoldsBSc]  = obj.CD_BalanceFoldsAndScarceFolds_v3p0p0(obj.TestFoldsNs, obj.TestFoldsSc,obj.JitterWeight,obj.JitterPercentage);
				
				if (obj.EqualFoldCount ~= -1)
					obj.AcheivedCount = [];
					for iCtr=1:obj.FoldCount
						obj.AcheivedCount(iCtr) = length(obj.TrainFoldsBNs(iCtr).ObservationValuess);
					end
				end
			else
				obj.TrainFoldsBNs = obj.TrainFoldsNs;
				obj.TrainFoldsBSc = obj.TrainFoldsSc;
				
				obj.TestFoldsBNs  = obj.TestFoldsNs;
				obj.TestFoldsBSc  = obj.TestFoldsSc;
			end
		end
		
		function obj = CD_InitializeVariablesWithInputData(obj)
			
			obj.TrainingObs = obj.InputObservations;
			
			if obj.FeaturesInitialized == 0
				obj.Features = obj.FeaturesSpecs;
				obj.FeaturesInitialized = 1;
			end
			
			FeatureIndex = zeros(1,length(obj.Features));
			FeatureIndex(obj.CD_GetUsableFeaturesIndex_v3p0p0() == 0) = 1;
			FeatureIndex = find(FeatureIndex);
			if ~isempty(FeatureIndex)
				obj.TrainingObs(:,FeatureIndex) = nan;
			end
			
			% 			'InputObservations',InputObservations,'FeaturesSpecs',FeaturesMain,'InputClassifications',InputClasses',...
			
			obj.TrainingCls = obj.InputClasses;
			
            ClassValues = unique(obj.TrainingCls);
            ClassCounts = zeros(size(ClassValues));
            for cvCtr=1:length(ClassValues)
                ClassCounts(cvCtr) = nansum(ClassValues(cvCtr) == obj.TrainingCls);
            end
			[ClsCntMin,ClsCntInd] = nanmin(ClassCounts);
			if ClsCntMin < obj.FoldCount
				error('There is a class with less than one instance per fold!, class index is %u',ClsCntInd);
				ClassValues{ClsCntInd};
			elseif ClsCntMin < 10*obj.FoldCount && obj.BypassWarning == false
				warning('There is a class with less than 10 instance per fold!, class index is %u, its count is = %u',ClsCntInd,ClsCntMin);
				ClassValues{ClsCntInd};
				% 					pause
			end
			if isempty(obj.TrainingCls)
				error('The input vector selected for training classes is empty');
			end
			
			
			obj.TestingObs = obj.InputObservations;
			if ~isempty(FeatureIndex)
				obj.TestingObs(:,FeatureIndex) = nan;
			end
			
			obj.TestingCls = obj.InputClasses;
			if size(obj.TrainingObs,1) ~= length(obj.TrainingCls)
				error('The number of instances in the attribute matrix does not match with the number of instances in the class vector! \n Attributes# = %u vs. ClassVect = %u',...
					size(obj.TrainingObs,1),length(obj.TrainingCls));
			end
			
			if isempty(obj.TestingCls)
				error('The input vector selected for training classes is empty');
			end
			
			[obj,obj.TrainFoldsNs,obj.TrainFoldsSc] = CD_GenerateFoldIndex_v3p0p0(obj,obj.TrainingObs,obj.TrainingCls,obj.FoldCount);
			[obj,obj.TestFoldsNs, obj.TestFoldsSc ] = CD_GenerateFoldIndex_v3p0p0(obj,obj.TestingObs, obj.TestingCls, obj.FoldCount);
		end
		function obj =  CD_NormalizeTrainingData(obj)
			for cCtr = 1:size(obj.TrainingObs,2)
				obj.TrainingObs(:,cCtr) = obj.TrainingObs(:,cCtr) - nanmean(obj.TrainingObs(:,cCtr));
				obj.TrainingObs(:,cCtr) = obj.TrainingObs(:,cCtr) ./ nanstd(obj.TrainingObs(:,cCtr));
			end
		end
		
		function obj = CD_NormalizeTestingData(obj)
			for cCtr = 1:size(obj.TestingObs,2)
				obj.TestingObs(:,cCtr) = obj.TestingObs(:,cCtr) - nanmean(obj.TestingObs(:,cCtr));
				obj.TestingObs(:,cCtr) = obj.TestingObs(:,cCtr) ./ nanstd(obj.TestingObs(:,cCtr));
			end
		end
		function FoldIndexes = CD_GetFoldIndexes_v3p0p0(obj,Count,FoldNum)
			FoldIndexes = {};
			LastNum = 1;
			for fCtr = 1:FoldNum
				if fCtr < FoldNum
					FoldIndexes{fCtr} = LastNum:LastNum+round(Count/FoldNum);
					LastNum = FoldIndexes{fCtr}(end)+1;
				else
					FoldIndexes{fCtr} = LastNum:Count;
				end
			end
		end
		function CD_UpdateInputTrainTestData(obj)
			obj = obj.CD_InitializeVariablesWithInputData();
			obj = obj.CD_BalanceData();
		end
		
	end
	
	methods (Access = public)
		function obj = ClassificationData_v3p0p0(Version,varargin)
			if strcmpi(obj.Version,Version) == 0
				error('Versions don''t match!!, The class''s version is %s, and the caller function''s version is %s',obj.Version,Version);
			end
			if nargin <= 0
				error('Minimum one arguments is required');
			end
			obj.PropertyNames;
			CompiledVariables = [];
			
			for aCtr=1:2:length(varargin)
				for iCtr=1:length(obj.PropertyNames)
					if strcmpi(obj.PropertyNames{iCtr},varargin{aCtr}) == 1
						obj.(obj.PropertyNames{iCtr}) = varargin{aCtr+1};
						CompiledVariables = CompiledVariables + 1;
					end
				end
			end
			
			if (nargin ~= (2+2*CompiledVariables))
				error('At least one of the arguments does not have a value');
			end
			if isnan(obj.FeaturesInitialized)
				obj.FeaturesInitialized = 0;
			end
			for iCtr=1:length(obj.PropertyNames)
%                 obj.(obj.PropertyNames{iCtr})
				if isstruct(obj.(obj.PropertyNames{iCtr}))
				elseif iscategorical(obj.(obj.PropertyNames{iCtr}))
				elseif isnan(obj.(obj.PropertyNames{iCtr}))
                    
					error('ClassficationData: the variable "%s" needs to be initialized!',obj.PropertyNames{iCtr});
				end
			end
			
			obj = obj.CD_InitializeVariablesWithInputData();
			obj = obj.CD_BalanceData();
			
			if obj.NormalizeData == true
				obj = obj.CD_NormalizeTestingData();
				obj = obj.CD_NormalizeTrainingData();
			end
		end
		
		function obj = CD_UpdateVariablesWithUsableFeatures_v3p0p0(obj,NewUsableFeatures)
			%disable all features
			for iCtr=1:length(obj.Features)
				obj.Features(iCtr).Enabled = 0;
			end
			
			%enable only the features that are pointed out by the
			%NewUsableFeatures variable
			for iCtr = 1:length(NewUsableFeatures)
				if NewUsableFeatures(iCtr).Enabled == 0
					continue;
				end
				[FindResult, FeatureIndex] = ACD_FindStringInStructArray(obj.Features,'Name',NewUsableFeatures(iCtr).Name);
				
				if FindResult == 1 && NewUsableFeatures(iCtr).Enabled == 1
% 					FeatureIndex
					obj.Features(FeatureIndex).Enabled = 1;
				elseif FindResult == 0
					error('The feature <%s> does not exist in the current list of features!',NewUsableFeatures(iCtr).Name);
				else
					1;
				end
			end
			obj.FeaturesInitialized = 1;
			obj.CD_InitializeVariablesWithInputData();
			obj.CD_BalanceData();
		end
		
		function obj = CD_UpdateVariablesWithNewVector_v3p0p0(obj,NewEnabledFeaturesVector)
			%disable all features
			%enable only the features that are pointed out by the
			%NewUsableFeatures variable
			for iCtr = 1:length(NewEnabledFeaturesVector)
				if NewEnabledFeaturesVector(iCtr) == 1
					obj.Features(FeatureIndex).Enabled = 1;
				else
					obj.Features(FeatureIndex).Enabled = 0;
				end
			end
			obj.FeaturesInitialized = 1;
			obj.CD_InitializeVariablesWithInputData();
			obj.CD_BalanceData();
		end
		
		function Features = GetAllFeatures(obj)
			Features = obj.Features;
			for iCtr=1:length(Features)
				Features(iCtr).Enabled = 1;
			end
		end
		
		function FoldCount = GetFoldCount(obj)
			FoldCount = obj.FoldCount;
		end
		
		% get training observations based on Fold number
		function OutObs = CD_GetTrainingObs_BOFoldNum_v3p0p0(obj,FoldNum)
			[OutObs,~,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,1,FoldNum);
		end
		
		function OutCls = CD_GetTrainingCls_BOFoldNum_v3p0p0(obj,FoldNum)
			[~,OutCls,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,1,FoldNum);
		end
		
		function OutInd = CD_GetTrainingInd_BOFoldNum_v3p0p0(obj,FoldNum)
			[~,~,OutInd] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,1,FoldNum);
		end
		
		% get testing observations based on Fold number
		function OutObs = CD_GetTestingObs_BOFoldNum_v3p0p0(obj,FoldNum)
			if obj.FoldCount > 1
				[OutObs,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,0,FoldNum);
			else
				[OutObs,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs);
			end
		end
		
		function OutCls = CD_GetTestingCls_BOFoldNum_v3p0p0(obj,FoldNum)
			if obj.FoldCount > 1
				[~,OutCls,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,0,FoldNum);
			else
				[~,OutCls,~] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs);
			end
		end
		
		function OutInd = CD_GetTestingInd_BOFoldNum_v3p0p0(obj,FoldNum)
			if obj.FoldCount > 1
				[~,~,OutInd] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs,obj.TrainFoldsBSc,0,FoldNum);
			else
				[~,~,OutInd] = CD_GetTstTrnFold_v3p0p0(obj,obj.TrainFoldsBNs);
			end
		end
		
		function Out = CD_GetUsableFeaturesVector_v3p0p0(obj)
			Out = obj.Features;
		end
		
		function Out = CD_GetUsableFeaturesIndex_v3p0p0(obj)
			Out = [];
			for iCtr=1:length(obj.Features)
				Index = obj.Features(iCtr).Number;
				if obj.Features(iCtr).Enabled == 1
					Out(Index) = Index;
				else
					Out(Index) = 0;
				end
			end
			Out(Out == 0) = [];
		end
		
		function obj = CD_DisableFeature_v3p0p0(obj,FeatureNumber)
			obj.Features(FeatureNumber).Enabled = 0;
		end
		
		function obj = CD_EnableFeature_v3p0p0(obj,FeatureNumber)
			obj.Features(FeatureNumber).Enabled = 1;
		end
		
		function State = CD_GetFeatureEnabledStatus_v3p0p0(obj,FeatureNumber)
			State = obj.Features(FeatureNumber).Enabled;
		end
		
	end
end








