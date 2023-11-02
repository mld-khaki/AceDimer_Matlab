function FeaturesSt = ACD_FeatureCombinations_Analyzer__Step1(InpObs,InpClasses,RemainingFeatures,Verbose,FeaturesSt)

CurInd = length(FeaturesSt)+1;
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

CurAcc = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);
AvailableFeatures(AvailableFeatures == CurFeatureSet(1)) = [];
OrgAvailableFeatures = AvailableFeatures;

MissCounts = 0;
%%
while(DoneFinding == 0)
    MaxInd = AvailableFeatures(1);
    PrdAcc = ScoresMRMR(1);

    [NewAcc,NewStd] = ACD_EvalAcc(InpObs(:,[CurFeatureSet MaxInd]),InpClasses);
    
    Multiplier1 = NewStd;%-0.02/log(1-0.999);%(1-CurAcc/100).^0.001/100;
    Multiplier2 = (99.99/(CurAcc)-1);
    Multiplier = min([Multiplier2 Multiplier1]);

    if Verbose >= 1
        fprintf('\nMultiplier = %8.6f',Multiplier);
    end

    if CurAcc*(1+Multiplier) < NewAcc 
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

    else
        SkippedFeatures = setdiff(AllFeatures,CurFeatureSet);
        SkippedFeatures = setdiff(SkippedFeatures,AvailableFeatures);
        AvailableFeatures(AvailableFeatures == MaxInd) = [];
        CurAcc = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses,20);
%         OrgAvailableFeatures(OrgAvailableFeatures == MaxInd) = [];

        if Verbose >= 1
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
FeaturesSt(CurInd).Accuracy = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);

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