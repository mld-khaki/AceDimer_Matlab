function [HistData,CheckCount,Index] = ACD_CheckCombinations(HistData,InpComb,Bypass)

if isempty(HistData)
    HistData = struct;
end

if ~exist("Bypass","var")
    Bypass = false;
end

CheckCount = 0;
Index = -1;
for qCtr=2:length(HistData)
    if isempty(setdiff(HistData(qCtr).Comb,InpComb)) && length(HistData(qCtr).Comb) == length(InpComb)
        if Bypass == false
            HistData(qCtr).CheckCount = HistData(qCtr).CheckCount + 1;
            CheckCount = HistData(qCtr).CheckCount;
            Index = qCtr;
        end
        return
    end
end
Index = length(HistData)+1;
HistData(Index).Comb = InpComb;
HistData(Index).CheckCount = 1;
HistData(Index).ReqTime = 0;

end