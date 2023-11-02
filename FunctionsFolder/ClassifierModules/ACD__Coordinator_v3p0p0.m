% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [SaveResults, Options , ErrorInfoA, ErrorInfoB] = ACD__Coordinator_v3p0p0(InpTrainData,InpTrainClass,Options)
%
%     Options = [];
%     Options.ConsideredClassStr = 'Taxonomy';
%     Options.ConsideredClass = Classes;
%     Options.Normalize = true;
%
%     Options.SubjectStr = 'TestSubject-A';
%     Options.StartTime = datestr(now,'yyyymmdd_HHMMSS');
%     Options.Version = 'AceDimerv3p0p0';
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
OptionsOrg.Version = 'AceDimerv3p0p0';
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
% OptionsOrg.TempPath = 'c:\tempACDfolder\';
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
ErrorInfoB = [];

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

Options.CurAttributeCount = 1;

CurrentResults = [];
%%
DirName = ['TmpRes_' ComputerName '_' Options.SubjectStr '_' Options.StartTime '\'];
DirName(DirName == '-') = '_';
DirPath = Options.TempPath;

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
        
        ClassesData = ClassificationData_v3p0p0(Options.Version,...
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
prvResults = [];
prv2Results = [];
try
    while(Options.CurAttributeCount <= Options.MaxAttributeCount)
        clc
        if TestModeDisableClassification == 0
            Options.CalculationMode = 0; %full function
        else
            Options.CalculationMode = 2; %limited debug function
        end
        Options.DataFoldsCnt = Options.FoldCount;
                
        Options.ChanceAccuracy = 1/length(unique(ClsCondition));
        Options.CurrentState = 'NothingYet';
        
        %Testing Mode
        Options.ProcessMode = 'Testing';
        if Options.CurAttributeCount <= 2
            Options.ProcessModeTimer = 20;%Sec
        elseif Options.CurAttributeCount == 3
            Options.ProcessModeTimer = 120;%Sec
        else
            Options.ProcessModeTimer = 180;%Sec
        end
        
        clear UpdatedVector
%         if Options.CurAttributeCount > 1 %Last analysis was successfull
%             AnalysisInfo.FeatureCnt = nansum(ClassesData.CD_GetUsableFeaturesIndex_v3p0p0() ~= 0);
%             AnalysisInfo.UsableFeatures = ClassesData.CD_GetUsableFeaturesVector_v3p0p0();
%             
%             %(ModeState,'Testing')
%             TestPrvResults = [];
%             prvResults = SaveResults;
%             
%             [UpdatedVector, AnalysisInfo] = ACD_CalculateNextSetCount_Global_v3p0p0(prvResults,TestPrvResults,AnalysisInfo,prvResults.ClassesData,Options);
%             ClassesData = ClassesData.CD_UpdateVariablesWithUsableFeatures_v2p1p0(UpdatedVector);
%         end
        TestOptions = Options;
        TestOptions.CurAttributeCount = TestOptions.CurAttributeCount+1;
        [TestResults,TestAnalysisInfo] = ACD_NeuronCombinedClassifier_Global2_v2p1p0(AnalysisInfo,ClassesData,DispInfoLevel,Options);
        TestResults.Options = Options;
        
        % This is Training Mode
        Options.ProcessModeTimer = -1;
        Options.ProcessMode = 'Training';
        
        if Options.CurAttributeCount > 1 %Last analysis was successfull
            AnalysisInfo.FeatureCnt = nansum(ClassesData.CD_GetUsableFeaturesIndex_v2p1p0() ~= 0);
            AnalysisInfo.UsableFeatures = ClassesData.CD_GetUsableFeaturesVector_v2p1p0();
            
            %(ModeState,'Training')
            [UpdatedVector, ~] = ACD_CalculateNextSetCount_Global_v2p1p0(prvResults,prv2Results,TestAnalysisInfo,TestResults,ClassesData,Options);
            ClassesData = ClassesData.CD_UpdateVariablesWithUsableFeatures_v2p1p0(UpdatedVector);
        end
        
        [CurrentResults,AnalysisInfo] = ACD_NeuronCombinedClassifier_Global2_v2p1p0(AnalysisInfo,ClassesData,DispInfoLevel,Options);
        if exist('UpdatedVector','var')
            CurrentResults.Features = UpdatedVector;
        end
        CurrentResults.Options = Options;
        
        if ~isfield(AnalysisInfo,'MaxAccuracies')
            AnalysisInfo.MaxAccuracies = [];
        end
        
        prv2Results = prvResults;
        prvResults = CurrentResults;
        
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
        
        SaveResults.AnalysisInfo.NewFeaturesCnt  = nansum(ClassesData.CD_GetUsableFeaturesIndex_v2p1p0() ~= 0);
        SaveResults.AnalysisInfo.NewFeaturesList = ClassesData.CD_GetUsableFeaturesVector_v2p1p0();
        
        
        
        %     Results.AnalysisOutput   = Output;
        %         Results.CalculationMode     = CalculationMode;
        SaveResults.ClassesData       = ClassesData;
        SaveResults.CurrentAttrCnt    = Options.CurAttributeCount;
        SaveResults.PredictionMatrix = [];
        SaveResults.Options = Options;
        
        save([TargetDir '\' FileName],'SaveResults');
        ACD_SaveBigData(SaveResults,'SaveResults',[TargetDir '\' ['Dbl_' FileName(1:end-4)]]);
        
        Options.CurAttributeCount = Options.CurAttributeCount + 1;
        Options.SavePath = DirName;
        
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