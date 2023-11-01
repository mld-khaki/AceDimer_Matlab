% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function [SaveResults, Options , ErrorInfoA, ErrorInfoB] = ACD__Coordinator_v16p0(InpTrainData,InpTrainClass,Options)
%
%     Options = [];
%     Options.ConsideredClassStr = 'Taxonomy';
%     Options.ConsideredClass = Classes;
%     Options.Normalize = true;
%
%     Options.SubjectStr = 'TestSubject-A';
%     Options.StartTime = datestr(now,'yyyymmdd_HHMMSS');
%     Options.Version = 'AceDimer16p0';
%     OptionsOrg.AnalysisDispName = ['SampleSubjectA, ' Options.ConsideredClassStr];
%
%     The selected classification method. Supported Options are:
%     - NaiveBayes          - DecisionTree
%     - KNearestNeighbours  - LinearDiscriminantAnalysis
%     - SpaceVectorMachine
%     Options.SelectedClassifier = 'LinearDiscriminantAnalysis';
%
%     Options.Forward1Reverse0 = true;
%     Options.HoursLimitMax = 4;
%     Options.HoursLimitMin = 3.8;
%     Options.FoldCount = 4;
%     Options.BypassWarning = true;
%     Options.ForceBalancing = true;
%
%     You can use this parameter to limit the algorithm to a certain number
%     of variables, default value is define to 5, if it is not define, the
%     AceDimer toolbox will continue increasing number of features until it
%     encounters an error (which it will encounter error eventually, as the
%     number of features cannot go over the remaining number of features
%     (not the original count = size(InpTrainData,2)
%     Options.MaxAttributeCount = 5;
% 
%     if this parameter is set to true, it is assumed that the features do
%     have numbers in their names, or it is possible to uniquly identify
%     them. If the value is false, the toolbox will automatically add
%     feature number to the start of each name to ensure they are distinct
%     from each other and unique
%     Options.NumberedFeatures = false;

  

%Intialize required parameters
OptionsOrg = struct;
OptionsOrg.StartTime = datestr(now,'yyyymmdd_HHMMSS');
OptionsOrg.SubjectStr = 'SampleSubjectA';
OptionsOrg.Version = 'AceDimer16p0';
OptionsOrg.FoldCount = 4;
OptionsOrg.ConsideredClassStr = 'Taxonomy';
OptionsOrg.Normalize = true;
OptionsOrg.AnalysisDispName = ['SampleSubjectA, ' Options.ConsideredClassStr];
OptionsOrg.SelectedClassifier = 'LinearDiscriminantAnalysis';
OptionsOrg.Forward1Reverse0 = true;
OptionsOrg.HoursLimitMax = 4;
OptionsOrg.HoursLimitMin = 3.8;
OptionsOrg.FoldCount = 3;
OptionsOrg.PreviousResults = {};
OptionsOrg.BypassWarning = true;
OptionsOrg.ForceBalancing = true;
OptionsOrg.TempPath = 'c:\tempACDfolder\';
OptionsOrg.MaxAttributeCount = 5;
OptionsOrg.NumberedFeatures = false;
OptionsOrg.NansAcceptedAsZeros = true;

% Add the initial values to parameters that are not defined by the user
OptOrgFields = fieldnames(OptionsOrg);
for fldCtr=1:length(OptOrgFields)
    if ~isfield(Options,OptOrgFields{fldCtr})
        Options.(OptOrgFields{fldCtr}) = OptionsOrg.(OptOrgFields{fldCtr});
    end
end

ErrorInfoA = [];

if ~isfield(Options,'FeatureNames')
    Options.FeatureNames = {};
    Len = ceil(log10(size(InpTrainData,2)));
    for iCtr=1:size(InpTrainData,2)
        Options.FeatureNames{iCtr} = sprintf(['Feature_%0' num2str(Len) 'u'],iCtr);
    end
else
    if length(Options.FeatureNames) ~= size(InpTrainData,2)
        error('AceDimer Error <%s> The number of attributes and the number of feature names in the Options variable are not the same',Options.Version);
    end
end

Modes = {'Testing','Training'};
TestModeDisableClassification = 1;

if ~exist('InpTrainData','var')
    error('InputData is not defined or not compatible');
end

AnalysisInfo = struct;

ComputerName = char(java.net.InetAddress.getLocalHost.getHostName);
ComputerName(ComputerName == '-') = '';

%Something that won't bother anyone and will reduce our directory
%names' length :)
ComputerName = strrep(ComputerName,'martinez','MT');

Options.CurAttributeCount = 2;

CurrentResults = [];
%%
DirName = ['TmpRes_' ComputerName '_' Options.SubjectStr '_' Options.StartTime '\'];
DirName(DirName == '-') = '_';
DirPath = OptionsOrg.TempPath;

if ~exist(DirPath,'dir')
    mkdir(DirPath);
end

try
    if Options.NansAcceptedAsZeros == true
        InpTrainData(isnan(InpTrainData)) = 0;
    else
        tmpNans = isnan(InpTrainData(:));
        tmpNansSum = nansum(tmpNans(:));
        if tmpNansSum > 0
            error('AceDimer <%s> error: the "NansAcceptedAsZeros" parameter is set to false but there are #%u Nan features in the InpTrainData',OptionsOrg.Version,tmpNansSum);
        end
    end
    
    DispInfoLevel = [];
    DispInfoLevel.Initialization = 1;
    DispInfoLevel.TimingInfo = 1;
    DispInfoLevel.Errors = 1;
    
    if ~exist('ClassesData','var')
        ClassificationFeatures  = InpTrainData;
        ClsCondition = InpTrainClass;
        

        if Options.NumberedFeatures == false
            Options.NumberedFeatureNames = struct;
            Options.NumberedFeatureNames.Name = '';
            Options.NumberedFeatureNames(length(Options.FeatureNames)).Name = '';
            for FeatureCtr=1:length(Options.FeatureNames)
                Options.NumberedFeatureNames(FeatureCtr).Name = sprintf('Feature%03u_%02s',FeatureCtr,Options.FeatureNames{FeatureCtr});
                Options.NumberedFeatureNames(FeatureCtr).Number = FeatureCtr; %#ok<*SAGROW>
                Options.NumberedFeatureNames(FeatureCtr).Enabled = 1;
                Options.NumberedFeatureNames(FeatureCtr).Rank = FeatureCtr;
            end
        else
            Options.NumberedFeatureNames = Options.FeatureNames;
        end
        
        if size(ClsCondition,1) > size(ClsCondition,2)
            ClsCondition = ClsCondition';
        end
        
        ClassesData = ClassificationData_v16p0(Options.Version,...
            'InputObservations',ClassificationFeatures,'FeaturesSpecs',Options.NumberedFeatureNames,'InputClasses',ClsCondition,...
            'ForcedBalanced' , Options.ForceBalancing, 'FoldCount',Options.FoldCount,'BypassWarning',1,...
            'EqualFoldCount',Options.FoldCount,...
            'NormalizeData',Options.Normalize,'ScarceAccepted',false,'DebugEnabled',false,'JitterWeight',0,...
            'JitterPercentage',0);
        
    end
    
catch ErrorInfoA
    CurTime = datestr(now(),'yyyy_mm_dd__HH_MM_SS');
    CurTime(CurTime == '-') = '_';
    CurTime(CurTime == ' ') = '_';
    CurTime(CurTime == ':') = '_';
    FileName = [DirPath DirName 'ErrorrInit__' Options.SubjectStr '_' CurTime '.mat'];
%     save(FileName,'ErrorInfo');
    % 			rethrow(ME);
end

try
    while(Options.CurAttributeCount <= Options.MaxAttributeCount)
        clc
        if TestModeDisableClassification == 0
            Options.CalculationMode = 0; %full function
        else
            Options.CalculationMode = 2; %limited debug function
        end
        Options.DataFoldsCnt = Options.FoldCount;
        
        tglClassesData = ClassesData;
        tglAnalysisInfo = AnalysisInfo;
        
        Options.ChanceAccuracy = 1/length(unique(ClsCondition));
        Options.CurrentState = 'NothingYet';
        
        for ModeState = Modes
            Options.ProcessMode = ModeState;
            %Only required for testing
            if strcmpi(ModeState,'Testing') == 1
                
                if Options.CurAttributeCount == 2
                    Options.ProcessModeTimer = 20;%Sec
                elseif Options.CurAttributeCount == 3
                    Options.ProcessModeTimer = 120;%Sec
                else
                    Options.ProcessModeTimer = 180;%Sec
                end
            elseif strcmpi(ModeState,'Training') == 1
                Options.ProcessModeTimer = -1;
            else
                error('Unknown State');
            end
            
            
            
            if Options.CurAttributeCount > 2 %Last analysis was successfull
                tglAnalysisInfo.FeatureCnt = nansum(tglClassesData.CD_GetUsableFeaturesIndex_v16p0() ~= 0);
                tglAnalysisInfo.UsableFeatures = tglClassesData.CD_GetUsableFeaturesVector_v16p0();
                
                if strcmpi(ModeState,'Testing')
                    prvResults = SaveResults;
                elseif strcmpi(ModeState,'Training')
                    prvResults = CurrentResults;
                end
                
                [UpdatedVector, ~] = ACD_CalculateNextSetCount_Global_v16p0(prvResults,tglAnalysisInfo,prvResults.ClassesData,Options);
                tglClassesData = tglClassesData.CD_UpdateVariablesWithUsableFeatures_v16p0(UpdatedVector);
            end
            
            [CurrentResults,tglAnalysisInfo] = ACD_NeuronCombinedClassifier_Global2_v16p0(tglAnalysisInfo,tglClassesData,DispInfoLevel,Options);
        end
        
        if ~isfield(AnalysisInfo,'MaxAccuracies')
            AnalysisInfo.MaxAccuracies = [];
        end
        
        AnalysisInfo = tglAnalysisInfo;
        ClassesData = tglClassesData;
        
        AnalysisInfo.MaxAccuracies(end+1) = nanmax(CurrentResults.AccuraciesVector);
        Options.PreviousResults{end+1} = AnalysisInfo.MaxAccuracies;
        %%
        
        TargetDir = [DirPath DirName];
        if exist(TargetDir,'dir') ~= 7
            mkdir(TargetDir);
        end
        
        CurTime = datestr(now(),'yyyymmdd_HHMMSS');
        CurTime(CurTime == '-') = '_';
        CurTime(CurTime == ' ') = '_';
        CurTime(CurTime == ':') = '_';
        
        SaveResults = CurrentResults;
        FileName = ['Res_' sprintf('_CAt%02u',Options.CurAttributeCount) '.mat'];
        
        SaveResults.Subject = Options.SubjectStr;
        SaveResults.Date    = CurTime;
        
        SaveResults.AnalysisInfo = AnalysisInfo;
        SaveResults.AnalysisInfo.MaxAccuracies  = AnalysisInfo.MaxAccuracies;
        SaveResults.AnalysisInfo.UsableFeatures = AnalysisInfo.UsableFeatures;
        SaveResults.AnalysisInfo.AllPossibleCombinations = AnalysisInfo.AllPossibleCombinations;
        
        SaveResults.AnalysisInfo.Timing_TicStart = AnalysisInfo.TicStart;
        SaveResults.AnalysisInfo.Timing_StartTime= AnalysisInfo.StartTime;
        SaveResults.AnalysisInfo.Timing_EndTime = AnalysisInfo.EndTime;
        
        SaveResults.AnalysisInfo.NewFeaturesCnt  = nansum(ClassesData.CD_GetUsableFeaturesIndex_v16p0() ~= 0);
        SaveResults.AnalysisInfo.NewFeaturesList = ClassesData.CD_GetUsableFeaturesVector_v16p0();
        
        
        
        %     Results.AnalysisOutput   = Output;
        %         Results.CalculationMode     = CalculationMode;
        SaveResults.ClassesData       = ClassesData;
        SaveResults.CurrentAttrCnt    = Options.CurAttributeCount;
        SaveResults.PredictionMatrix = [];
        SaveResults.Options = Options;
        
        save([TargetDir '\' FileName],'SaveResults');
        ACD_SaveBigData(SaveResults,'SaveResults',[TargetDir '\' ['Dbl_' FileName(1:end-4)]]);
        
        Options.CurAttributeCount = Options.CurAttributeCount + 1;
        
        if Options.MaxAttributeCount < Options.CurAttributeCount
            break;
        end
    end
    
catch ErrorInfoB
    CurTime = datestr(now(),'yyyy_mm_dd__HH_MM_SS');
    CurTime(CurTime == '-') = '_';
    CurTime(CurTime == ' ') = '_';
    CurTime(CurTime == ':') = '_';
    FileName = [DirPath DirName 'Errrorrr__' Options.SubjectStr '_' CurTime '.mat'];
%     save(FileName,'ErrorInfo');
%     rethrow(ErrorInfoB);
end
if ~exist('SaveResults','var')
    SaveResults = struct;
end
end