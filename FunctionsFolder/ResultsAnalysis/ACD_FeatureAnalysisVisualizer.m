function [FeatureContributions] = ACD_FeatureAnalysisVisualizer(InpObs,InpCls,MetaInfo)
%   required fields in MetaInfo structure
%   MetaInfo.FeaturesCnt = number of features.
%   MetaInfo.FeatureSelection = "fscmrmr";
%   MetaInfo.FeatureNames = FeatureNames;
%   MetaInfo.MaxGoodFeatures = 10;
%   MetaInfo.SkipPlottingFeatures = 0;
%   MetaInfo.Percentage = true;


if ~isfield(MetaInfo,'FeaturesCnt')
    MetaInfo.FeaturesCnt = size(InpObs,2);
    assert(size(InpObs,1) == length(InpCls));
end

if ~isfield(MetaInfo,'CumulativeProfilePlot')
    MetaInfo.CumulativeProfilePlot = false;
end


if MetaInfo.FeatureSelection == "fscmrmr"
    [FSC_idx,FSC_Scores] = fscmrmr(InpObs,InpCls);
end
FSC_idx_Org = FSC_idx;
FSC_Scores_Org = FSC_Scores;


for qCtr=1:length(MetaInfo.FeatureNames)
    MetaInfo.FeatureNames(qCtr) = TableStrModifier(MetaInfo.FeatureNames(qCtr));
end

% GoodFeatures = SortMat(:,2);
FSC_idx(1:MetaInfo.SkipPlottingFeatures) = [];
FSC_Scores(1:MetaInfo.SkipPlottingFeatures) = [];
    



if isfield(MetaInfo,'MaxGoodFeatures')
    GoodFeatures = FSC_idx(1:MetaInfo.MaxGoodFeatures);
else
    GoodFeatures = FSC_idx(FSC_Scores> mean(FSC_Scores)+0.1*std(FSC_Scores));
end
for qCtr=1:MetaInfo.SkipPlottingFeatures
    FSC_idx_Org(qCtr)
    GoodFeatures(GoodFeatures == FSC_idx_Org(qCtr)) = [];
end

FeatureContributions = struct;
FeatureContributions.ID = GoodFeatures;
FeatureContributions.Names = MetaInfo.FeatureNames(GoodFeatures);
FeatureContributions.Scores = FSC_Scores;
FeatureContributions.AllIDs = FSC_idx;

PlotFeatures = FSC_Scores_Org(GoodFeatures);
% SeqNums = FSC_idx_Org(GoodFeatures);
PlotFeatures = 100*PlotFeatures ./ nansum(PlotFeatures);
% PlotFeatures = sortrows(PlotFeatures,-3);




%%
% figure(2);
if ~isfield(MetaInfo,'TitleStr')
    TitleStr = TableStrModifier("Top contributing features" + newline);
else
    TitleStr = MetaInfo.TitleStr;
end
ACD_AUX_BarPlotter(PlotFeatures,MetaInfo.FeatureNames(FSC_idx_Org),-1,0.5,TitleStr,true,MetaInfo.MaxGoodFeatures)


if MetaInfo.CumulativeProfilePlot == true
    figure(3);
    Prof = plot(MLD_CumulativeProfileCalculator(FSC_Scores_Org(FSC_idx_Org)));
end

end


function Out = TableStrModifier(Inp) %#ok<DEFNU> 

Strreps = ["Num_","#",...
    "Frequency","Frq",...
    "_at_","@",...
    "Normalized_xCorr","Nrm.xCorr",...
    "_per_","/","Half_Height","HH",...
    "within","wthn",...
    "Channel","Ch",...
    "Net_Burst_Avg","NetBAvg",...
    "_","."];
Out = Inp;
for qCtr=1:length(Out)
    for pCtr=1:2:length(Strreps)-1
        Out(qCtr) = strrep(Out(qCtr),Strreps(pCtr),Strreps(pCtr+1));
    end
end

end