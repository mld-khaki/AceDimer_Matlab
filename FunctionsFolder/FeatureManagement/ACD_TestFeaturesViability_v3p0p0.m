function KeepTheseFeatures = ACD_TestFeaturesViability_v3p0p0(InpObs,InpCls,CurFeatureSet,StdMul,CurAcc,CurStd,Verbose)

KeepTheseFeatures = ones(size(CurFeatureSet));
for qCtr=length(CurFeatureSet):-1:1 , qFeat = CurFeatureSet(qCtr);
    tmpFeatureSet = CurFeatureSet;
    tmpBadChkObs = InpObs;
    
    % destroy the correlation of the focused feature to check its effect
    tmpBadChkObs(:,qFeat) = tmpBadChkObs(randperm(end),qFeat);
    [tmpAcc,tmpStd] = ACD_EvalAcc(tmpBadChkObs(:,tmpFeatureSet),InpCls);
    if (tmpAcc-tmpStd*StdMul) > (CurAcc+CurStd*StdMul) || ...
            ( (abs(1-(tmpAcc-tmpStd*StdMul)/(CurAcc+StdMul*CurStd)) < 0.01) && (abs(1-(tmpAcc+tmpStd*StdMul)/(CurAcc-StdMul*CurStd)) < 0.01) )
        tmpFeatureSet2 = CurFeatureSet;
        tmpFeatureSet2(tmpFeatureSet2 == qFeat) = [];

        if isempty(tmpFeatureSet2)
            continue;
        else
            [tmpAcc2,tmpStd2] = ACD_EvalAcc(InpObs(:,tmpFeatureSet2),InpCls);
        end

           
        if (tmpAcc2-tmpStd2*StdMul) > (CurAcc+CurStd*StdMul) || ...
                ( (abs(1-(tmpAcc2-tmpStd2*StdMul)/(CurAcc+StdMul*CurStd)) < 0.01) && (abs(1-(tmpAcc2+tmpStd2*StdMul)/(CurAcc-StdMul*CurStd)) < 0.01) )
            KeepTheseFeatures(CurFeatureSet == qFeat) = 0;
            CurFeatureSet(CurFeatureSet == qFeat) = [];
            if Verbose >= 1
                fprintf('\n<%s> = Feature %u deemed bad and is removed!!\n',mfilename,qFeat);
            end
        end
    end
end
end