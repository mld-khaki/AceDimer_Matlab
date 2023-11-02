function AvailableSet = ACD_FeatureCombinations_PrepareAvailableSet(FeaturesSt,OrgSet)
AvailableSet = OrgSet;
for qCtr=1:length(FeaturesSt)
    if isfield(FeaturesSt(qCtr),'Combination')
        AvailableSet = setdiff(AvailableSet,FeaturesSt(qCtr).Combination);
    end

    if isfield(FeaturesSt(qCtr),'Similars')
        for pCtr=1:length(FeaturesSt(qCtr).Similars)
            AvailableSet = setdiff(AvailableSet, FeaturesSt(qCtr).Similars(pCtr).Alternatives);
        end
    end
end
end
