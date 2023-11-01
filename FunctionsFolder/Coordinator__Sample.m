load('.\Sample_Data.mat');
clearvars -except Prcs prCtr Data
for SessionCtr = 1%:length(Data)	,	
    SessionStr = Data(SessionCtr).Raw.DateStr;
	TestModeDisableClassification = 0;
	TempFolder = 'C:\tempACD\';
	CurClass = 'ClsCondition';

    % DispInfoLevel can remain fixed
    DispInfoLevel = [];
    DispInfoLevel.Initialization = 1;
    DispInfoLevel.TimingInfo = 1;
    DispInfoLevel.Errors = 1;
    
	Options = [];
	Options.AllStates = {'WM'};
	Options.AllEpochs = {'EpCue','EpDel','EpNav'};
	Options.ConsideredClasses = {CurClass};
	Options.ArrayName = 'FiringRates';
	Options.Normalize = false;
	Options.OutArName = [Options.ArrayName '_Cls'];
	Options.SubjectStr = 'Buzz';
	Options.StartTime = datestr(now,'yyyy_mm_dd__HH_MM_SS');
	Options.ClassVarName = 'ClsCondition';
	Options.AttributeNamesVariable = 'ChannelNames';
	Options.Version = 'AceDimer16p0';
	Options.AttributesVarName = Options.ArrayName;
	Options.Forward1Reverse0 = true;
	Options.HoursLimit = 2;
	
	
	if ~exist(Options.AttributesVarName,'var')
		SubjectStr = 'NonKetamine';
		load('.\Data\CompactedData.mat');
	end
	
	for EpochCtr = 3%1:length(OptionsOrg.AllEpochs);	
		EpochStr = Options.AllEpochs{EpochCtr};
		ComputerName = char(java.net.InetAddress.getLocalHost.getHostName);
		ComputerName(ComputerName == '-') = '';
		ComputerName = strrep(ComputerName,'martinez','MT');
		
		DirName = ['TmpRes_' ComputerName '_' Options.SubjectStr '_' SessionStr '_' EpochStr '_' Options.StartTime '\'];
		DirName(DirName == '-') = '_';
		DirPath = 'c:\tempResults\';

		try
			Datum = Data(SessionCtr).Processed.(Options.AllStates{1}).(Options.AllEpochs{EpochCtr});
			
			ClassesVar = eval(['Datum.' Options.ClassVarName]);
			AttributesVar = eval(['Datum.' Options.AttributesVarName]);
			
			if ~exist('ContinuePrv','var')
				SkipToCount = 2;
				if SkipToCount ~= 2
					Inp = input(sprintf('Input count is higher than 2, it is %u,\n\tit means that you want to continue an incomplete analysis\n\tWould you like to proceed? (press enter to proceed)',SkipToCount),'s');
					if ~isempty(Inp)
						return;
					end
				end
				
				
				
				%     clear ClassesData
				CurData = [];
				
				% find the maximum number of features that are available in all
				% folds and all states
				
				ClsCondition = [];
				ClsOutcomeAll = [];
				
				PerStateFoldCount(1:4) = 0;
				
				if ~exist('ClassesData','var')
					ClassificationFeatures  = AttributesVar;
					ClassificationFeatures(Datum.ClsOutcome == 0,:) = [];
					
					ClsCondition = ClassesVar;
					ClsCondition(Datum.ClsOutcome == 0) = [];
					ClsCondition = categorical(ClsCondition);
					
					MaxFeatureCnt = size(ClassificationFeatures,2);
					FeaturesMain = [];
					for FeatureCtr=1:MaxFeatureCnt
						FeaturesMain(FeatureCtr).Name = sprintf('Feature%03u_%s',FeatureCtr,eval(['Datum.' Options.AttributeNamesVariable '{FeatureCtr}']));
						FeaturesMain(FeatureCtr).Number = FeatureCtr; %#ok<*SAGROW>
						FeaturesMain(FeatureCtr).Enabled = 1;
						FeaturesMain(FeatureCtr).Rank = FeatureCtr;
					end
					
					if size(ClsCondition,1) < size(ClsCondition,2)
						ClsCondition = ClsCondition';
					end
					
					dpCtr = 1;
					CurrentClass = Options.ConsideredClasses{dpCtr};
					CurData.(CurrentClass).TrainFeaturesMain = FeaturesMain;
					
					if ~exist(TempFolder,'dir')
						mkdir(TempFolder);
					end
					
					FilePath = [TempFolder 'Temp_' CurrentClass '.mat'];
					save(FilePath,'ClassificationFeatures','FeaturesMain','ClsCondition');
					
					FoldCount = 4;
					ForceBalancing = true;
					
					
					ClassesData.(CurrentClass) = ClassificationData_v16p0(Options.Version,'InputFilePath',FilePath,...
						'TrainingObsPrefix', 'ClassificationFeatures' , 'TrainingObsPostfix', '',...
						'TrainingClsPrefix', '' , 'TrainingClsPostfix', 'ClsCondition',...
						'TestingObsPrefix' , 'ClassificationFeatures' , 'TestingObsPostfix',  '',...
						'TestingClsPrefix' , '' , 'TestingClsPostfix' , 'ClsCondition',...
						'ForcedBalanced' , ForceBalancing, 'FoldCount',FoldCount, ...
						'FeaturesVar','FeaturesMain','EqualFoldCount',PerStateFoldCount(dpCtr),...
						'NormalizeData',true,'ScarceAccepted',false);
					
				end
			end
			
			AttributeCount = SkipToCount;
			CurrentAttributeCount = SkipToCount;
			TempResults = [];
			TrainerConfig.MaxAttributeCount = 2;
			TrainerConfig.MinAttributeCount = 2;
			TrainerConfig.Subj = Options.SubjectStr;
			TrainerConfig.Date = '';
			
			OthersInfo = [];
			for dpCtr=1:length(Options.ConsideredClasses), dpStr = Options.ConsideredClasses{dpCtr};
				OthersInfo.(dpStr) = {};
			end
			WorkersCount = 1;
			
			while(AttributeCount <= 20)
				%     spmd
				if 1
					LI = WorkersCount;
					
					clc
					if TestModeDisableClassification == 0
						TrainerConfig.CalculationMode = 0; %full function
					else
						TrainerConfig.CalculationMode = 2; %limited debug function
					end
					TrainerConfig.DataFoldsCnt = FoldCount;
					
					
					for dpCtr=length(Options.ConsideredClasses):-1:1, dpStr = Options.ConsideredClasses{dpCtr};
						TrainerConfig.Epoch = dpStr;
						
						Outputs.(dpStr) = {};
						
						Output.(dpStr)    = [];
						OutputPRV.(dpStr) = [];
						
						
						
						OutputPRV = Output;
						
						AnalysisInfo.(dpStr).FeatureCnt = nansum(ClassesData.(dpStr).GetUsableFeaturesIndex() ~= 0);
						TrainerConfig.MinAttributeCount = CurrentAttributeCount;
						TrainerConfig.MaxAttributeCount = CurrentAttributeCount;
						if TrainerConfig.MaxAttributeCount > 2 %Last analysis was successfull
							[UpdatedVector.(dpStr), UpdatedCount.(dpStr)] = ACD_CalculateNextSetCount_Global_v16p0(TempResults.(dpStr),ClassesData.(dpStr),AnalysisInfo.(dpStr),TrainerConfig,Options);
							
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
						[TempResults.(dpStr),AnalysisInfo.(dpStr)] = ACD_NeuronCombinedClassifier_Global_v16p0(AnalysisInfo.(dpStr),ClassesData.(dpStr),DispInfoLevel,OthersInfo.(dpStr),TrainerConfig,Options);
						
						if TrainerConfig.MaxAttributeCount > 2
							[UpdatedVector.(dpStr), UpdatedCount.(dpStr)] = ACD_CalculateNextSetCount_Global_v16p0(TempResults.(dpStr),ClassesData.(dpStr),AnalysisInfo.(dpStr),TrainerConfig,Options);
							
							ClassesData.(dpStr) = ClassesData.(dpStr).CD_UpdateVariablesWithNewUsableFeatures_v16p0(UpdatedVector.(dpStr));
							
							AnalysisInfo.(dpStr).FeatureCnt = UpdatedCount;
						end
						
						
						TrainerConfig.ProcessMode = 'Training';
						TrainerConfig.ProcessModeTimer = -1;
						
						TrainerConfig.CurrentState = dpStr;
						[TempResults.(dpStr),AnalysisInfo.(dpStr)] = ACD_NeuronCombinedClassifier_Global_v16p0(AnalysisInfo.(dpStr),ClassesData.(dpStr),DispInfoLevel,OthersInfo.(dpStr),TrainerConfig,Options);
						
						Output.(dpStr) = TempResults.(dpStr);
						
						Outputs.(dpStr){end+1} = TempResults.(dpStr);
						
						if ~isfield(AnalysisInfo.(dpStr),'MaxAccuracies')
							AnalysisInfo.(dpStr).MaxAccuracies = [];
						end
						
						OthersInfo.(dpStr){end+1} = [];
						AnalysisInfo.(dpStr).MaxAccuracies(end+1) = nanmax(TempResults.(dpStr).AccuraciesVector);
						OthersInfo.(dpStr){end} = TempResults.(dpStr).AnalysisInfo.MaximumValues;
						OthersInfo.(dpStr){end}  = OthersInfo.(dpStr){end};
						%%
						
						TargetDir = [DirPath DirName];
						if exist(TargetDir,'dir') ~= 7
							mkdir(TargetDir);
						end
						
						AttributeCount = CurrentAttributeCount;
						
						CurTime = datestr(now(),'yyyy_mm_dd__HH_MM_SS');
						CurTime(CurTime == '-') = '_';
						CurTime(CurTime == ' ') = '_';
						CurTime(CurTime == ':') = '_';
						
						SaveResults = [];
						ClsStrTemp = dpStr;
						ClsStrTemp = strrep(ClsStrTemp,'Cls','');
						FileName = [TargetDir 'Res__S' Options.SubjectStr '__Cls' ClsStrTemp sprintf('__CAt%02u',CurrentAttributeCount) '__TS_' CurTime '.mat'];
						
						SaveResults.Subject = Options.SubjectStr;
						SaveResults.Date    = CurTime;
						
						SaveResults.AnalysisInfo.(dpStr).MaxAccuracies  = AnalysisInfo.(dpStr).MaxAccuracies;
						SaveResults.AnalysisInfo.(dpStr).UsableFeatures = AnalysisInfo.(dpStr).UsableFeatures;
						SaveResults.AnalysisInfo.(dpStr).AllPossibleCombinations = AnalysisInfo.(dpStr).AllPossibleCombinations;
						
						SaveResults.AnalysisInfo.(dpStr).Timing_TicStart = AnalysisInfo.(dpStr).TicStart;
						SaveResults.AnalysisInfo.(dpStr).Timing_StartTime = AnalysisInfo.(dpStr).StartTime;
						SaveResults.AnalysisInfo.(dpStr).Timing_EndTime= AnalysisInfo.(dpStr).EndTime;
						
						SaveResults.AnalysisInfo.(dpStr).NewFeaturesCnt  = nansum(ClassesData.(dpStr).GetUsableFeaturesIndex() ~= 0);
						SaveResults.AnalysisInfo.(dpStr).NewFeaturesList = ClassesData.(dpStr).GetUsableFeaturesVector();
						
						
						SaveResults.AnalysisOutput.(dpStr).AccuraciesVector = Output.(dpStr).AccuraciesVector;
						SaveResults.AnalysisOutput.(dpStr).ConfusionMatrices = Output.(dpStr).ConfusionMatrices;
						SaveResults.AnalysisOutput.(dpStr).Features = Output.(dpStr).Features;
						
						%     Results.AnalysisOutput   = Output;
						%         Results.CalculationMode     = CalculationMode;
						SaveResults.ClassesData       = ClassesData;
						SaveResults.CurrentAttrCnt    = CurrentAttributeCount;
						
						save(FileName,'SaveResults');
						
						FileName = [TargetDir 'Pos_OthInf__S' Options.SubjectStr '__Class' dpStr sprintf('__CAt%02u',CurrentAttributeCount-1) '__TS_' CurTime '.mat'];
						save(FileName,'OthersInfo');
						
					end
					CurrentAttributeCount = CurrentAttributeCount + 1;
				end
			end
		catch ME
			CurTime = datestr(now(),'yyyy_mm_dd__HH_MM_SS');
			CurTime(CurTime == '-') = '_';
			CurTime(CurTime == ' ') = '_';
			CurTime(CurTime == ':') = '_';
			FileName = [DirPath DirName 'Errrorrr__' Options.SubjectStr '_' SessionStr '_' EpochStr '_' CurTime '.mat'];
			save(FileName,'ME');
% 			rethrow(ME);
		end
	end
end
