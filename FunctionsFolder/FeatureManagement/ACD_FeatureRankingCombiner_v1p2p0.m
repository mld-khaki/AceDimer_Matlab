function Out = ACD_FeatureRankingCombiner_v1p2p0(InpR1,InpSc1,InpR2,InpSc2)
assert(length(InpR1) == length(InpR2));

OutRank = zeros(size(InpR1));
OutScore = zeros(size(InpR1));

InpSc1 = Normalize(InpSc1);
InpSc2 = Normalize(InpSc2);

for qCtr=1:length(InpR1)
    [MaxSc1,MaxFt1] = nanmax(InpSc1);
    [MaxSc2,MaxFt2] = nanmax(InpSc2);

    if MaxSc1 > MaxSc2
        OutRank(qCtr) = MaxFt1;
        InpSc1(MaxFt1) = -inf;
        InpSc2(MaxFt1) = -inf;
        OutScore(MaxFt1) = MaxSc1;
    else
        OutRank(qCtr) = MaxFt2;
        InpSc1(MaxFt2) = -inf;
        InpSc2(MaxFt2) = -inf;
        OutScore(MaxFt2) = MaxSc2;
    end
end


Out.Score = OutScore;
Out.Indices = OutRank;
end

function Out = Normalize(Inp)
Out = Inp - nanmin(Inp);
Out = Out ./ nanmax(Out);
end