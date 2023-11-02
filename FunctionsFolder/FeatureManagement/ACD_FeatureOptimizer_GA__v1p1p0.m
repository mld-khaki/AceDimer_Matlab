function [FeaturesSt,BestModels] = ACD_FeatureOptimizer_GA__v1p1p0(InpObs,InpClasses,FeaturesSt,Verbose)

BestModels = struct;
CurInd = length(FeaturesSt)+1;
FeaturesSt(CurInd).AvailableSet = ACD_FeatureCombinations_PrepareAvailableSet(FeaturesSt,RemainingFeatures);

if ~exist('Verbose','var')
    Verbose = 0;
end

AllFeatures = FeaturesSt(end).AvailableSet;

[IndicesMRMR] = Local_FS(InpObs(:,AllFeatures),InpClasses,'Verbose',1);
IndicesMRMR = AllFeatures(IndicesMRMR);



CurFeatureSet = [IndicesMRMR(1)];
AvailableFeatures = IndicesMRMR(2:end);
DoneFinding = 0;

CurAcc = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);
AvailableFeatures(AvailableFeatures == CurFeatureSet(1)) = [];
OrgAvailableFeatures = AvailableFeatures;

MissCounts = 0;
%%
while(DoneFinding == 0 && ~isempty(AvailableFeatures))
    MaxInd = AvailableFeatures(1);

    [NewAcc,NewStd,NewModel] = ACD_EvalAcc(InpObs(:,[CurFeatureSet MaxInd]),InpClasses);
    
    Multiplier1 = NewStd;%-0.02/log(1-0.999);%(1-CurAcc/100).^0.001/100;
    Multiplier2 = (99.99/(CurAcc)-1);
    Multiplier = min([Multiplier2 Multiplier1]);

    if Verbose >= 1
        fprintf('\nMultiplier = %8.6f',Multiplier);
    end
    fprintf("\n%f , %f",CurAcc*(1-Multiplier),NewAcc )
    if CurAcc*(1+Multiplier) < NewAcc 
        if Verbose >= 1
            fprintf('\nAccuracy with %2u features = %5.2f %% (Acc Inc = %8.6f, NewFeature = %u)',length(CurFeatureSet)+1,NewAcc,(CurAcc - NewAcc),MaxInd);
        end

        BestModels(end+1).Model = NewModel;
        BestModels(end).Accuracy = NewAcc;
        BestModels(end).AccStd = NewStd;
        BestModels(end).Features = [CurFeatureSet MaxInd];
        BestModels(end).Multiplier = Multiplier;
        BestModels(end).PrvAcc = CurAcc;
        clc
        BestModels(end)
%         pause

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

        if Verbose >= 1
            fprintf('\n## (CA=%5.2f%%), Accuracy with %2u features Ac1=%5.2f%%,Ac2=%5.2f%% (Delta = %6.3f, Skipped Feature = %u)',CurAcc,length(CurFeatureSet),CurAcc,CurAcc,(CurAcc - NewAcc),MaxInd);
            fprintf('\n## AllSkips#=%u and Avil = %u, Average miss = %5.2f Std midd = %5.2f, MaxSkip = %u , MinSkp = %u',length(SkippedFeatures),length(AvailableFeatures),mean(MissCounts),std(MissCounts),max(SkippedFeatures),min(SkippedFeatures));
        end
        MissCounts(end) = MissCounts(end) + 1;
    end

    if isempty(AvailableFeatures)
        DoneFinding = 1;
    end
end

FeaturesSt(CurInd).Combination = CurFeatureSet;
FeaturesSt(CurInd).Accuracy = ACD_EvalAcc(InpObs(:,CurFeatureSet),InpClasses);


end


function [Out1,Out2] = Local_FS(Param1,Param2,Param3,Param4)

[Out1,Out2] = ACD_fscmrmr(Param1,Param2,Param3,Param4);
% [Out1,Out2] = relieff(Param1,Param2,10);
% [Out1,Out2] = fscchi2(Param1,Param2);
end