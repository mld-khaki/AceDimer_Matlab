function [OutAcc,OutStd,OutConf,HistCheck] = ACD_EvalAcc_v3p4p0(XTemp,YTemp,Repetitions,Classifier,CurSet,RecalcNewValue)

persistent HistCheckData
persistent LastPresent

FoldCnt = 3;
if ~exist("HistCheckData","var")
    HistCheckData = [];
end
if ~exist("RecalcNewValue","var")
    RecalcNewValue = false;
end

if isempty(LastPresent)
    LastPresent = tic;
else
    if toc(LastPresent) > 1 && isfield(HistCheckData,"Accuracy")
        VarLens = zeros(length(HistCheckData),1);
        for qCtr=1:length(VarLens)
            VarLens(qCtr) = length(HistCheckData(qCtr).Comb);
        end
        [MaxVal,MaxInd] = max([HistCheckData.Accuracy]);
        Counts = [HistCheckData.CheckCount]-1;
        Counts(Counts < 0) = 0;
        SavedTime = sum([HistCheckData.ReqTime] .* Counts);
        Minutes = floor(SavedTime/60);
        Seconds = SavedTime - Minutes*60;
        fprintf("\n MaxValue = %7.4f%%, length = %u, Varlen: min=%u, avg=%5.2f, std=%5.2f, max=%u, best=%u Saved Mins = %5.2f, Sec =%5.2f", ...
            MaxVal, length(HistCheckData), min(VarLens), mean(VarLens), std(VarLens), max(VarLens),length(HistCheckData(MaxInd).Comb),...
                Minutes,Seconds);
        drawnow;
        LastPresent = tic;
    end
end

CurFeatureSet = find(CurSet);
[HistCheckData,CheckCount,Index] = ACD_CheckCombinations(HistCheckData,CurFeatureSet);
NeedEvaluation = 0;
if ~isfield(HistCheckData(Index),'Accuracy') || RecalcNewValue == true
    NeedEvaluation = 1;
elseif isempty(HistCheckData(Index).Accuracy)
    NeedEvaluation = 1;
end

if NeedEvaluation == 1
    OutTime = tic;
    [OutAcc,OutStd,OutConf] = local_EvalAcc(XTemp(:,CurFeatureSet),YTemp,Repetitions,Classifier,FoldCnt);
    OutTime = toc(OutTime);
    HistCheckData(Index).Accuracy = OutAcc;
    HistCheckData(Index).Std = OutStd;
    HistCheckData(Index).Conf = OutConf;
    HistCheckData(Index).ReqTime = OutTime;
else
    Mult = sind(HistCheckData(Index).Accuracy*pi/100)/3;
    OutAcc = HistCheckData(Index).Accuracy + randn*HistCheckData(Index).Std*Mult;
    OutStd = HistCheckData(Index).Std;
    OutConf = HistCheckData(Index).Conf;
end

HistCheck = HistCheckData;
end





function [OutAcc,OutStd,Conf] = local_EvalAcc(XTemp,YTemp,Repetitions,Classifier,FoldCnt)
if ~exist('Repetitions','var')
    RepCount = 10;
else
    RepCount = Repetitions;
end

if ~exist("Classifier","var")
    Classifier = "knn";
end


dev = zeros(1,RepCount);
UnqClsCount = length(unique(YTemp));
ConfMatArray = zeros(RepCount,UnqClsCount,UnqClsCount);
for rCtr=1:RepCount
    RandInd = randperm(length(YTemp));%1:length(YTemp);%
    XTemp = XTemp(RandInd,:);
    YTemp = YTemp(RandInd);

    if strcmpi(Classifier,"knn")
        model = fitcknn(XTemp,YTemp,'KFold',FoldCnt,'Prior','empirical');%,"Distance","seuclidean");
        dev(rCtr) = kfoldLoss(model);
        MainPred = model.kfoldPredict();
    elseif strcmpi(Classifier,"LDA")
        FoldInds = cvpartition(YTemp,'KFold',FoldCnt);
        MainPred = [];
        for fCtr = 1:FoldInds.NumTestSets
            trnIdx = FoldInds.training(fCtr);
            tstIdx = FoldInds.test(fCtr);
            LDA_Model = ACD_LDA_v3p0p0(XTemp(trnIdx,:),YTemp(trnIdx));
            Preds = ACD_LDA_Predict_v3p0p0(LDA_Model,XTemp(tstIdx,:));
            dev(fCtr,rCtr) = sum(Preds ~= YTemp(tstIdx));
            MainPred(tstIdx) = Preds;
        end

        %         LDA_Model = ACD_LDA_v3p0p0(XTemp(RandInd,:),YTemp(RandInd));
        %         Preds = ACD_LDA_Predict_v3p0p0(LDA_Model,XTemp(RandInd,:));
        %         dev(rCtr) = sum(Preds ~= YTemp(RandInd))/length(YTemp);
    else
        error("<%s> unknown classifier for evaluation ==> ""%s""",mfilename,Classifier);
    end

    ConfMatArray(rCtr,:,:) = confusionmat(YTemp(RandInd),MainPred);
end

if strcmpi(Classifier,"LDA")
    dev = sum(dev)/length(YTemp);
end

OutAcc = (1-mean(dev))*100;
OutStd = nanstd(dev*100);
ConfAvg = squeeze(nanmean(ConfMatArray));
ConfStd = squeeze(nanstd(ConfMatArray));

tmpAr = zeros(1,UnqClsCount);
tmpMat = ConfStd;
for qCtr=1:UnqClsCount
    tmpAr(qCtr) = ConfStd(qCtr,qCtr);
    tmpMat(qCtr,qCtr) = nan;
end
ConfS2tdDiag = nanstd(tmpAr);
ConfS2tdRest = nanstd(tmpMat(:));
Conf = struct();
Conf.Avg = ConfAvg;
Conf.Std = ConfStd;
Conf.Std_of_Std_Diagonal = ConfS2tdDiag;
Conf.Std_of_Std_Rest = ConfS2tdRest;
end

