function [OutAcc,OutStd,OutConf,HistCheck] = ACD_EvalAcc_v3p3p0(HistCheck,XTemp,YTemp,Params)
    [HistCheck,CheckCount,Index] = ACD_CheckCombinations(HistCheck,Params.CurFeatureSet);
    NeedEvaluation = 0;
    if ~isfield(HistCheck(Index),'Accuracy') 
        NeedEvaluation = 1;
    elseif isempty(HistCheck(Index).Accuracy)
        NeedEvaluation = 1;
    end

    if NeedEvaluation == 1
        OutTime = tic;
        [OutAcc,OutStd,OutConf] = local_EvalAcc(XTemp(:,Params.CurFeatureSet),YTemp,Params.Repetitions,Params.Classifier);
        OutTime = toc(OutTime);
        HistCheck(Index).Accuracy = OutAcc;
        HistCheck(Index).Std = OutStd;
        HistCheck(Index).Conf = OutConf;
        HistCheck(Index).ReqTime = OutTime;
    else
        Mult = sind(HistCheck(Index).Accuracy*pi/100)/3;
        OutAcc = HistCheck(Index).Accuracy + randn*HistCheck(Index).Std*Mult;
        OutStd = HistCheck(Index).Std;
        OutConf = HistCheck(Index).Conf;
    end
end





function [OutAcc,OutStd,Conf] = local_EvalAcc(XTemp,YTemp,Repetitions,Classifier)
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
        model = fitcknn(XTemp,YTemp,'KFold',4,'Prior','empirical');%,"Distance","seuclidean");
        dev(rCtr) = kfoldLoss(model);
        MainPred = model.kfoldPredict();
    elseif strcmpi(Classifier,"LDA")
        FoldInds = cvpartition(YTemp,'KFold',4);
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

