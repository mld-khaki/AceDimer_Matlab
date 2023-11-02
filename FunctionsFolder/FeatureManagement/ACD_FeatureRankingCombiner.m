function OutRank = ACD_FeatureRankingCombiner(InpR1,InpSc1,InpR2,InpSc2)
assert(length(InpR1) == length(InpR2));

OutRank = zeros(size(InpR1));

InpSc1 = Normalize(InpSc1);
InpSc2 = Normalize(InpSc2);
for qCtr=1:length(InpR1)
    Comp1 = find(InpR1 == qCtr).* InpSc1(qCtr);
    Comp2 = find(InpR2 == qCtr).* InpSc2(qCtr);
    OutRank(qCtr) = nanmean([Comp1 Comp2]);
end

tmpR = [OutRank;1:length(OutRank)];

tmp = sortrows(tmpR',-1)';

OutRank = tmp(2,:);
% AnalysisResults.FeatureScores  = FeatureScores;

end

function Out = Normalize(Inp)
Out = Inp - nanmin(Inp);
Out = Out ./ nanmax(Out);
end