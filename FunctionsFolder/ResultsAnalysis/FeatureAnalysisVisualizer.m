function [FeatureContributions] = FeatureAnalysisVisualizer__v1p5p0(InpObs,InpCls,MetaInfo,Normalize)
%   required fields in MetaInfo structure
%   MetaInfo.FeaturesCnt = number of features.

if ~isfield(MetaInfo,'FeaturesCnt')
    MetaInfo.FeaturesCnt = size(InpObs,2);
    assert(size(InpObs,1) == length(InpCls));
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
figure(2);
if ~isfield(MetaInfo,'TitleStr')
    TitleStr = TableStrModifier("Top contributing features" + newline);
else
    TitleStr = MetaInfo.TitleStr;
end
ACD_AUX_BarPlotter__v4p2p0(PlotFeatures,MetaInfo.FeatureNames(FSC_idx_Org),-1,0.5,TitleStr,true,MetaInfo.MaxGoodFeatures)



%%


%%
% myTab = table;
% myPercentage = table;
% myTabPrc = table;
% Feats = TableStrModifier(MetaInfo.FeatureNames(GoodFeatures));
% CLSs = (string(XLabs));
% 
% for qCtr=1:length(CLSs)
%     [Out,Order] = sortrows(PlotFeatures,-qCtr);
%     Feats
%     Order
% 
%     myTab.(CLSs(qCtr))(1:length(Order)) = Feats(Order);
%     Prc = Out(:,qCtr);
%     Prc = 100*(Prc ./ nansum(Prc));
%     myPercentage.(CLSs(qCtr))(1:length(Order)) = Prc;
%     
%     myTabPrc.(CLSs(qCtr))(1:length(Order)) = Feats(Order);
% 
%     List = "";
%     for oCtr=1:length(Prc)
%         List(oCtr) = sprintf("=%5.2f%%",Prc(oCtr));
%     end
%     myTabPrc.(CLSs(qCtr)+"_%")(1:length(Order)) = List;
% end

figure(3);
Prof = plot(MLD_CumulativeProfileCalculator(FSC_Scores_Org(FSC_idx_Org)));

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