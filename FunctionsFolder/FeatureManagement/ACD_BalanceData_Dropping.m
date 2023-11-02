function [XTemp,YTemp] = ACD_BalanceData_Dropping(XTemp,YTemp)
% if iscategorical(YTemp)
%     YTemp = double(categorical(YTemp));
% end
Classes = unique(YTemp);
ClassesCount = zeros(1,length(Classes));

for qCtr=1:length(ClassesCount)
    ClassesCount(qCtr) = sum(YTemp == Classes(qCtr));
end

DesiredCount = min(ClassesCount);

RemoveVect = [];
for qCtr=1:length(Classes)
    SumVal = sum(YTemp == Classes(qCtr));
    if SumVal == DesiredCount
        continue;
    elseif SumVal < DesiredCount
        error("Why it is lower !>??")
    else
        RemoveVect = DesiredCount+1:SumVal;
        YInd2 = find(YTemp == Classes(qCtr));
        XTemp(YInd2(RemoveVect),:) = [];
        YTemp(YInd2(RemoveVect)  ) = [];
    end
end
end