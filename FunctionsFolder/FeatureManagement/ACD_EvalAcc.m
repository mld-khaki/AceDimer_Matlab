function [OutAcc,OutStd,Conf] = ACD_EvalAcc(XTemp,YTemp,Repetitions,Classifier)
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

    if strcmpi(Classifier,"knn")
        model = fitcknn(XTemp(RandInd,:),YTemp(RandInd),'KFold',3,'Prior','empirical');%,"Distance","seuclidean");
        dev(rCtr) = kfoldLoss(model);
        Preds = model.kfoldPredict();
    elseif strcmpi(Classifier,"LDA")
        LDA_Model = ACD_LDA_v3p0p0(XTemp(RandInd,:),YTemp(RandInd));
        Preds = ACD_LDA_Predict_v3p0p0(LDA_Model,XTemp(RandInd,:));
        dev(rCtr) = sum(Preds ~= YTemp(RandInd))/length(YTemp);
    else
        error("<%s> unknown classifier for evaluation ==> ""%s""",mfilename,Classifier);
    end

    ConfMatArray(rCtr,:,:) = confusionmat(YTemp(RandInd),Preds);
end
OutAcc = (1-mean(dev))*100;
OutStd = nanstd(dev);
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
