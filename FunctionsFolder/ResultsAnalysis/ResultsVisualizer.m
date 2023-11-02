function [myTab,myPercentage,myTabPrc] = ResultsVisualizer__v4p0p0(InpObs,InpCls,InpObsInfo,ACDStats,CVPartition,MaxFeatures)

if ~exist('MaxFeatures','var')
    MaxFeatures = size(InpObs,2);
    assert(size(InpObs,1) == length(InpCls));
end
%%
%%
CheckedFeatures = fieldnames(ACDStats);
ClsVals = unique(InpCls);

FTMat_FP = zeros(1,1,1);
for cCtr=1:length(ClsVals)
    ClsName = sprintf("Cls_%u",ClsVals(cCtr));
    for ftCtr=1:length(CheckedFeatures) , ftStr = CheckedFeatures{ftCtr};
        Datum1 = -ACDStats.(ftStr).(ClsName).FParray ./ ACDStats.(ftStr).(ClsName).ClassCnt;
        Datum2 = -ACDStats.(ftStr).(ClsName).FNarray ./ ACDStats.(ftStr).(ClsName).ClassCnt;
        FTMat_FP(ftCtr,cCtr) = ((nanmean(Datum1) ./ nanstd(Datum1))) + ...
                                ((nanmean(Datum2) ./ nanstd(Datum2)));
    end
end

fprintf('\ndone!\n')





AM = FTMat_FP;
% AM = AM - nanmean(AM);
% AM = AM ./ nanstd(AM);
AM = AM - nanmin(AM);
AM = AM ./ nanmax(AM);
% AM = AM * 100;

% SumValues = sum(AM')';
SumValues = prod(AM' + 0.01)';

SortMat = [SumValues,(1:length(SumValues))'];
SortMat = sortrows(SortMat,-1)
SortMat(isnan(SortMat(:,1)),:) = [];

% GoodFeatures = SortMat((SortMat(:,1) > mean(SumValues)+0.1*std(SumValues)),2)
GoodFeatures = SortMat(:,2);

close(figure(1))
FigH = figure(1)
clf

Ext = 3;
PlotFeatures = AM(GoodFeatures(1:MaxFeatures),:);
PlotFeatures = 100*PlotFeatures ./ nansum(PlotFeatures);
% PlotFeatures = sortrows(PlotFeatures,-3);
imagesc(PlotFeatures(:,ceil(linspace(1e-5,end,end*Ext))))
colorbar

XTickVect = round((Ext+1)/2):Ext:length(unique(InpCls))*Ext;
xticks(XTickVect);
xlim([0 length(unique(InpCls))*Ext+1]);
xtickangle(0);
grid on
axis equal

xticklabels();
XLabs = unique(InpCls);
XLabs2 = "";
XLabs2 = string(XLabs);
XLabs2(ismissing(XLabs2)) = "";
XLabs2 = string(XLabs2);
XLabs2 = MLD_PrepareLabel_ForPlotting__v1p0p0(XLabs2);
xticklabels(XLabs2);
yticks(1:MaxFeatures)

YLabs = MLD_PrepareLabel_ForPlotting__v1p0p0(InpObsInfo(GoodFeatures(1:MaxFeatures)));

for qCtr=1:length(YLabs)
    YLabs(qCtr) = YLabs(qCtr) + sprintf(" (%2u)",qCtr);
end

yticklabels(YLabs)

FigH.CurrentAxes.Color = 'none';
% axis equal
% axes("Color","none")


[FTA,FTB] = fscmrmr(InpObs,InpCls);

VectMRMR = FTA(1:MaxFeatures);%[17 4  25 11 20 15];
% VectAcDi = [11 20 13 1  3  23];
% VectAcDi = [24 19 22 21 18 15]
VectAcDi = GoodFeatures(1:MaxFeatures);

ModelMRMR = fitctree(InpObs(:,VectMRMR),InpCls,'CVPartition',CVPartition);
ModelAcDi = fitctree(InpObs(:,VectAcDi),InpCls,'CVPartition',CVPartition);

PredMRMR = ModelMRMR.kfoldPredict();
PredAcDi = ModelAcDi.kfoldPredict();

Real = InpCls;

length(find(Real == PredMRMR))
length(find(Real == PredAcDi))
length(Real)



%%
figure(2)
FigH1 = subplot(1,2,1);
pos = get(FigH1,"Position");
% pos(2) = 0.65;
pos(1) = 0.2;
pos(3) = 0.24;
set( FigH1, 'Position', pos ) ;

TitleStr = "Top features contributing to sorting" + newline;
ACD_AUX_BarPlotter__v4p2p0(PlotFeatures(:,1),InpObsInfo,-1,0.5,TitleStr + "19-2-2 KO",true,MaxFeatures)

FigH1 = subplot(1,2,2);
pos = get(FigH1,"Position");
% pos(2) = 0.65;
pos(1) = 0.72;
pos(3) = 0.24;
set( FigH1, 'Position', pos ) ;
ACD_AUX_BarPlotter__v4p2p0(PlotFeatures(:,2),InpObsInfo,-1,0.5,TitleStr + "19-2-2 WT",true,MaxFeatures)


%%
myTab = table;
myPercentage = table;
myTabPrc = table;
Feats = TableStrModifier(InpObsInfo(GoodFeatures(1:MaxFeatures)));
CLSs = (string(XLabs));

for qCtr=1:size(PlotFeatures,2)
    [Out,Order] = sortrows(PlotFeatures,-qCtr);
    myTab.(CLSs(qCtr))(1:length(Order)) = Feats(Order);
    Prc = Out(:,qCtr);
    Prc = 100*(Prc ./ nansum(Prc));
    myPercentage.(CLSs(qCtr))(1:length(Order)) = Prc;
    
    myTabPrc.(CLSs(qCtr))(1:length(Order)) = Feats(Order);

    List = "";
    for oCtr=1:length(Prc)
        List(oCtr) = sprintf("=%5.2f%%",Prc(oCtr));
    end
    myTabPrc.(CLSs(qCtr)+"_%")(1:length(Order)) = List;
end
end


function Out = TableStrModifier(Inp)

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