function FeaturesSt = ACD_FeatureCombinations_Analyzer__Step1_v3p0p0(InpObs,InpClasses,RemainingFeatures,Verbose,FeaturesSt)

CurInd = length(FeaturesSt)+1;
IndividualAccuracies = nan(1,size(InpObs,2));
BadImpactChecked = IndividualAccuracies;
FeaturesSt(CurInd).AvailableSet = ACD_FeatureCombinations_PrepareAvailableSet(FeaturesSt,RemainingFeatures);

if ~exist('Verbose','var')
    Verbose = 0;
end

AllFeatures = FeaturesSt(end).AvailableSet;

[IndicesMRMR,ScoresMRMR] = Local_FS(InpObs(:,AllFeatures),InpClasses,'Verbose',1);
IndicesMRMR = AllFeatures(IndicesMRMR);



CurFeatureSet = [IndicesMRMR(1)];
AvailableFeatures = IndicesMRMR(2:end);
DoneFinding = 0;

[CurAcc,CurStd,CurConf] = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);
CurAccMinimal = -inf;
AvailableFeatures(AvailableFeatures == CurFeatureSet(1)) = [];
OrgAvailableFeatures = AvailableFeatures;

MissCounts = 0;
SelSetCount = -1;
SelSet = [];
StdMul = 3;

%%
while(DoneFinding == 0)
    MaxInd = AvailableFeatures(1);
    PrdAcc = ScoresMRMR(1);

    if isempty(MaxInd)

    elseif isnan(IndividualAccuracies(MaxInd))
        IndividualAccuracies(MaxInd) = ACD_EvalAcc(InpObs(:,[MaxInd]),InpClasses);
    end



    [NewAcc,NewStd,NewConf] = ACD_EvalAcc(InpObs(:,[CurFeatureSet MaxInd]),InpClasses);
    if length(CurFeatureSet)>=1 
        % if the minimal feature set (with bad accuracy) is not taken from
        % the current set of features, the regenerate the minimal set and
        % update its parameters
        if SelSetCount ~= length(CurFeatureSet)
            SelSetCount = length(CurFeatureSet);
            [IndicesMRMRMinimal,ScoresMRMRMinimal] = Local_FS(InpObs(:,CurFeatureSet),InpClasses,'Verbose',1);
            IndicesMRMRMinimal = CurFeatureSet(IndicesMRMRMinimal);

            SelSet = IndicesMRMRMinimal(1);
            CurAccMinimal = ACD_EvalAcc(InpObs(:,SelSet),InpClasses);
        end
        [NewAccMinimal,NewStdMinimal] = ACD_EvalAcc(InpObs(:,[SelSet MaxInd]),InpClasses);
    else
        NewAccMinimal = inf;
    end
    
    Multiplier1 = NewStd;%-0.02/log(1-0.999);%(1-CurAcc/100).^0.001/100;
    Multiplier2 = (99.99/(CurAcc)-1);
    Multiplier = min([Multiplier2 Multiplier1]);

    if Verbose >= 1
        fprintf('\nMultiplier = %8.6f',Multiplier);
    end

    if  ((CurAcc+CurStd*StdMul) < (NewAcc - NewStd*StdMul)) ...
        && CurAccMinimal*(1+Multiplier) < NewAccMinimal
        if Verbose >= 1
            fprintf('\nAccuracy with %2u features = %9.6f %% (Acc Inc = %8.6f, NewFeature = %u)',length(CurFeatureSet)+1,NewAcc,(CurAcc - NewAcc),MaxInd);
            if istable(InpObs)
                fprintf('\nNew Feature''s Name = "%s"\n',InpObs.Properties.VariableNames{MaxInd});
            end
        end

        CurFeatureSet(end+1) = MaxInd; %#ok<*AGROW> 
        OrgAvailableFeatures(OrgAvailableFeatures == MaxInd) = [];
%         [IndicesMRMR,ScoresMRMR] = Local_FS(InpObs(:,OrgAvailableFeatures),InpClasses,'Verbose',1);
%         OrgAvailableFeatures = OrgAvailableFeatures(IndicesMRMR);
    
        AvailableFeatures = OrgAvailableFeatures;
        CurAcc = NewAcc;
        MissCounts(end+1) = 0;

        if Verbose >= 1
            if length(MissCounts) > 10
                MissCounts(end-10:end)
            else
                MissCounts %#ok<*NOPRT> 
            end
        end


        % check the lowest accuracy features
        [IndicesBadImpact,ScoresBadImpact] = Local_FS(InpObs(:,CurFeatureSet),InpClasses,'Verbose',1);
        IndicesBadImpact = CurFeatureSet(IndicesBadImpact);
        while(~isempty(IndicesBadImpact) && length(CurFeatureSet) >= 2)
            % if bad impact of this feature is checked
            if ~isnan(BadImpactChecked(IndicesBadImpact(1)))
                IndicesBadImpact(1) = [];
                continue
            end

            
            tmpFeatureSet = CurFeatureSet;
            tmpFeatureSet(tmpFeatureSet == IndicesBadImpact(1)) = [];
            [tmpAcc,tmpStd,tmpConf] = ACD_EvalAcc(InpObs(:,tmpFeatureSet),InpClasses);
            if (tmpAcc-tmpStd*StdMul) > (CurAcc+CurStd*StdMul) || ...
                    ( (abs(1-(tmpAcc-tmpStd*StdMul)/(CurAcc+StdMul*CurStd)) < 0.01) && (abs(1-(tmpAcc+tmpStd*StdMul)/(CurAcc-StdMul*CurStd)) < 0.01) )
                BadImpactChecked(IndicesBadImpact(1)) = 1;
                CurFeatureSet(CurFeatureSet == IndicesBadImpact(1)) = [];
                fprintf('\nFeature %u deemed bad and is removed!!\n',IndicesBadImpact(1));
            else
                BadImpactChecked(IndicesBadImpact(1)) = 0;
            end
            break;
        end
        
    else
        SkippedFeatures = setdiff(AllFeatures,CurFeatureSet);
        SkippedFeatures = setdiff(SkippedFeatures,AvailableFeatures);
        AvailableFeatures(AvailableFeatures == MaxInd) = [];
        [CurAcc,CurStd,CurConf] = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses,20);
%         OrgAvailableFeatures(OrgAvailableFeatures == MaxInd) = [];

        if Verbose >= 1
            fprintf("\n[");
            fprintf("%u,",CurFeatureSet);
            fprintf("]");
            fprintf('\n## Accuracy with %2u features Ac1=%9.6f%%,Ac2=%9.6f%% (Delta = %6.3f, Skipped Feature = %u)',length(CurFeatureSet),CurAcc,CurAcc,(CurAcc - NewAcc),MaxInd);
            fprintf('\n## AllSkips#=%u and Avil = %u, Average miss = %5.2f Std midd = %5.2f, MaxSkip = %u , MinSkp = %u',length(SkippedFeatures),length(AvailableFeatures),mean(MissCounts),std(MissCounts),max(SkippedFeatures),min(SkippedFeatures));
        end
        MissCounts(end) = MissCounts(end) + 1;
    end
%     pause
    if isempty(AvailableFeatures)
        DoneFinding = 1;
    end
end

FeaturesSt(CurInd).Combination = CurFeatureSet;
[FeaturesSt(CurInd).AccuracyAvg,FeaturesSt(CurInd).AccuracyStd,FeaturesSt(CurInd).AccuracyConf] = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);

% FeaturesSt(Ctr).Similars = struct;
% sCtr = 1;
% FeaturesSt(Ctr).Similars(sCtr).MainFeature = 56;
% FeaturesSt(Ctr).Similars(sCtr).Alternatives = [1 45 21 19 54 46 60 22 18 43 9 23 16 47 50 20 48 8 44 49 24 11 4 17 26 51 3 25 14];


return
%%


figure(2) %#ok<*UNRCH> 
clf
subplot(1,2,1);
A1 = double(Info.Ix(Vect,Vect));
A1(isinf(A1)) = nan;
imagesc(A1)
colorbar 
axis square

[A,B1] = corrcoef(InpObs(:,Vect));
for qCtr=1:size(A,1)
    for pCtr=qCtr:size(A,2)
        if qCtr == pCtr
            A(qCtr,pCtr) = nan;
        end
    end
end

subplot(1,2,2);
imagesc(A)
colorbar 
axis square
end



function [Out1,Out2] = Local_FS(Param1,Param2,Param3,Param4)

[Out1,Out2] = ACD_fscmrmr(Param1,Param2,Param3,Param4);
% [Out1,Out2] = relieff(Param1,Param2,10);
% [Out1,Out2] = fscchi2(Param1,Param2);
end