function KeepTheseFeatures = ACD_TestFeaturesViability_v3p1p0(InpObs,InpCls,CurFeatureSet,StdMul,CurAcc,CurStd,Verbose,Classifier,RepCount)

% RepCount = 20;
Closeness = 0.001;
KeepTheseFeatures = ones(size(CurFeatureSet));
for qCtr=length(CurFeatureSet):-1:1 , qFeat = CurFeatureSet(qCtr);
    tmpFeatureSet = CurFeatureSet;
    tmpBadChkObs = InpObs;
    
    % destroy the correlation of the focused feature to check its effect
    tmpBadChkObs(:,qFeat) = tmpBadChkObs(randperm(end),qFeat);
    [tmpAcc,tmpStd] = ACD_EvalAcc(tmpBadChkObs(:,tmpFeatureSet),InpCls,RepCount,Classifier);
    if (tmpAcc-tmpStd*StdMul) > (CurAcc+CurStd*StdMul) || ...
            ( (abs(1-(tmpAcc-tmpStd*StdMul)/(CurAcc+StdMul*CurStd)) < Closeness) && (abs(1-(tmpAcc+tmpStd*StdMul)/(CurAcc-StdMul*CurStd)) < Closeness) )
        tmpFeatureSet2 = CurFeatureSet;
        tmpFeatureSet2(tmpFeatureSet2 == qFeat) = [];

        if isempty(tmpFeatureSet2)
            continue;
        else
            [tmpAcc2,tmpStd2] = ACD_EvalAcc(InpObs(:,tmpFeatureSet2),InpCls,RepCount,Classifier);
        end

           
        if (tmpAcc2-tmpStd2*StdMul) > (CurAcc+CurStd*StdMul) || ...
                ( (abs(1-(tmpAcc2-tmpStd2*StdMul)/(CurAcc+StdMul*CurStd)) < Closeness) && (abs(1-(tmpAcc2+tmpStd2*StdMul)/(CurAcc-StdMul*CurStd)) < Closeness) )
            KeepTheseFeatures(CurFeatureSet == qFeat) = 0;
            CurFeatureSet(CurFeatureSet == qFeat) = [];
            if Verbose >= 1
                fprintf('\n<%s> = Feature %u deemed bad and is removed!!\n',mfilename,qFeat);
            end
        end
    end
end
end




% function KeepTheseFeatures = ACD_TestFeaturesViability_v3p1p0(InpObs,InpCls,CurFeatureSet,StdMul,CurAcc,CurStd,Verbose,Classifier,RepCount)
% 
% % RepCount = 20;
% Closeness = 0.001;
% KeepTheseFeatures = ones(size(CurFeatureSet));
% for qCtr=length(CurFeatureSet):-1:1 , qFeat = CurFeatureSet(qCtr);
%     tmpFeatureSet = CurFeatureSet;
%     tmpBadChkObs = InpObs;
%     
%     % destroy the correlation of the focused feature to check its effect
%     tmpBadChkObs(:,qFeat) = tmpBadChkObs(randperm(end),qFeat);
%     [tmpAcc,tmpStd] = ACD_EvalAcc(tmpBadChkObs(:,tmpFeatureSet),InpCls,RepCount,Classifier);
%     if (tmpAcc-tmpStd*StdMul) > (CurAcc+CurStd*StdMul) || ...
%             ( (abs(1-(tmpAcc-tmpStd*StdMul)/(CurAcc+StdMul*CurStd)) < Closeness) && (abs(1-(tmpAcc+tmpStd*StdMul)/(CurAcc-StdMul*CurStd)) < Closeness) )
%         tmpFeatureSet2 = CurFeatureSet;
%         tmpFeatureSet2(tmpFeatureSet2 == qFeat) = [];
% 
%         if isempty(tmpFeatureSet2)
%             continue;
%         else
%             [tmpAcc2,tmpStd2] = ACD_EvalAcc(InpObs(:,tmpFeatureSet2),InpCls,RepCount,Classifier);
%         end
% 
%            
%         if (tmpAcc2-tmpStd2*StdMul) > (CurAcc+CurStd*StdMul) || ...
%                 ( (abs(1-(tmpAcc2-tmpStd2*StdMul)/(CurAcc+StdMul*CurStd)) < Closeness) && (abs(1-(tmpAcc2+tmpStd2*StdMul)/(CurAcc-StdMul*CurStd)) < Closeness) )
%             KeepTheseFeatures(CurFeatureSet == qFeat) = 0;
%             CurFeatureSet(CurFeatureSet == qFeat) = [];
%             if Verbose >= 1
%                 fprintf('\n<%s> = Feature %u deemed bad and is removed!!\n',mfilename,qFeat);
%             end
%         end
%     end
% end
% end
% 
% 
% 
% 
