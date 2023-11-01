% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function AInfo = ACD_DisplayStatus_Global_v16p0(AInfo,AnalysisResults,DispInfoLevel,Options,Avgs,varargin)
CurrentVersion = 'AceDimer16p0';

if Options.Forward1Reverse0 == 1
    CurrentFeatureCount = Options.CurAttributeCount;
    CurrentMode = 'Forward Reduction';
else
	try
		if isfield(AInfo.FeatureCnt,Options.ClassVarName)
			CurrentFeatureCount = AInfo.FeatureCnt.(Options.ClassVarName) - Options.CurAttributeCount;
		else
			CurrentFeatureCount = AInfo.FeatureCnt - Options.CurAttributeCount;
		end
	catch ME
		1
	end
    CurrentMode = 'Reverse Reduction';
end

if strcmpi(CurrentVersion,Options.Version) == 0
	error('Versions don''t match!!, The function''s version is %s, and the caller function''s version is %s',CurrentVersion,Version);
end

if strcmpi(Options.ProcessMode,'Testing') == 0
	TestMode = ' ';
else
	TestMode = 'T';
end
% TestMode = [TestMode ' ' Options.CurrentState];

if ~isempty(varargin)
	Params = ACD_ReadFuncVarargin(varargin);
end

ProgressCtr = sum(~isnan(AnalysisResults.ProgressStatus));
if mod(ProgressCtr,AInfo.TicStart.TicCnt) == 0 || ProgressCtr == 0 || AInfo.BypassEverything == 1
	[StringOut, AInfo.TicStart] = ACD_TocPercent(AInfo.TicStart,ProgressCtr,0,length(AInfo.TestVector));
	if (~isempty(StringOut) && DispInfoLevel.TimingInfo == 1)
		clc
		drawnow('update');
		if exist('Params','var')
			if isfield(Params,'ProgressIndicator')
				Params.ProgressIndicator.UpdateProcess({AInfo.StartTime,ProgressCtr+1,length(AInfo.TestVector),1});
				Params.ProgressIndicator.UIFigure.Name = sprintf('Theo, PM=%s,State:%s,%s, ',...
					Options.ProcessMode,Options.CurrentState,...
					Params.ProgressIndicator.User_StateInfo);
			end
		end
		fprintf('%s',ACD_ProjectedFinishCalculator_v16p0(toc(AInfo.StartTime),ProgressCtr+1,length(AInfo.TestVector),1));
		
		fprintf('\n');
		clc
		ACD_cprintf('blue','\n\tChance Accuracy is : %5.2f%%...',Options.ChanceAccuracy*100);
		ACD_cprintf('blue','\n\tSubj=%s, Date=%s',Options.SubjectStr,Options.StartTime);
		fprintf('\n\t===================================');
		fprintf('\n\t%s, AceDimer Version = %s',Options.AnalysisDispName,Options.Version);
		fprintf('\n\tClassifier Type: %s',Options.SelectedClassifier);
		for sCtr=2:Options.CurAttributeCount
			PlotHappened = 0;
			GotData = 0;
			if sCtr==Options.CurAttributeCount
				fprintf('\n\n\t***********************************');
			elseif sCtr ~= 2 && PlotHappened == 1
				fprintf(newline);
				PlotHappened = 0;
			end

			
			if sCtr == length(AInfo.MaximumValues)
				GotData = 1;
				MaxVal    = AInfo.MaximumValues(sCtr);
            elseif length(Options.PreviousResults) == 1 && CurrentFeatureCount > 0
				MaxVal    = AInfo.MaximumValues(CurrentFeatureCount);
			elseif length(Options.PreviousResults) > 1
				GotData = 1;
				MaxVal      = Options.PreviousResults{sCtr-1}(end);
			elseif isempty(Options.PreviousResults)
				%do nothing
				continue
            elseif length(Options.PreviousResults{sCtr-1}) >= (sCtr) %&& (sCtr - 1 <= length(Options.PreviousResults{1}))
				GotData = 1;
				MaxVal      = Options.PreviousResults{sCtr-1}(end);
			end
			try
				if GotData == 1 && ~isinf(MaxVal)
					ACD_cprintf('red',  '\n\tMax Acc = %5.2f%%%s, Extra=%5.2f%% for <%u> Attributes',...
						MaxVal*100,TestMode,MaxVal*100-Options.ChanceAccuracy*100,sCtr);
					ACD_cprintf('blue', '\n\tAvg Acc = %5.2f%%, for (%u) Attributes',ACD_nanmean(Avgs{CurrentFeatureCount})*100,CurrentFeatureCount);
					PlotHappened = 1;
				end				
				if GotData == 1 
					ACD_cprintf('blue', '\n\tAvg Acc = %5.2f%%, for (%u) Attributes',ACD_nanmean(Avgs{CurrentFeatureCount})*100,CurrentFeatureCount);
					PlotHappened = 1;
				end				
			end
		end
		fprintf('\n\t***********************************');
		
		fprintf('\n\tCurrent Record = %u of %u, Classification Mode = "%s"',ProgressCtr+1,length(AnalysisResults.ProgressStatus),ACD_If(strcmpi(Options.ProcessMode,'Training'),'Training','Test Speed'));
		if exist('CurrentFeatureCount','var')
			ACD_cprintf('magenta','\n\t(Mode = %s) Feature Cnt = %u => Down to <%u>',CurrentMode, length(AInfo.UsableFeatures),CurrentFeatureCount);
		end
		ACD_cprintf('black',' ,');
		CurrentRecCnt = nansum(~isnan(AnalysisResults.AccuraciesVector));
		PrecentageNum = CurrentRecCnt *100/ length(AnalysisResults.ProgressStatus);
		fprintf('\n\tCurrently working on record #%u of the total #%u, (%.2f%% Complete)',CurrentRecCnt,length(AnalysisResults.ProgressStatus),PrecentageNum);
		
		fprintf('\n\t===================================');
		fprintf('\n%s',StringOut);
		if ~isempty(AInfo.MaxAccuracies)
			fprintf('\nMaxAccuracies are: ...\n\t');
			for maCtr=1:length(AInfo.MaxAccuracies)
				fprintf('\t[%u,%u,%5.2f%%], ', ...
					length(AInfo.MaxAccuracies(maCtr).UsedFeatures), AInfo.MaxAccuracies(maCtr).SetCount, ...
					AInfo.MaxAccuracies(maCtr).HighestAccuracy*100);
			end
		end
		drawnow('update');
	end
end
end

