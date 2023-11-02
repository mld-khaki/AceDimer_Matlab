function [FeaturesSt,HistCheckData] = ACD_FeatureCombinations_Analyzer__Step1_v3p3p1(InpObs,InpClasses,RemainingFeatures,Verbose,FeaturesSt,ModeStr,ClsType)

if ~exist("ModeStr","var")
    ModeStr = "";
end

if ~exist("ClsType","var")
    ClsType = "knn";
end

RepCount = 20;
Params = struct;

CurInd = length(FeaturesSt)+1;
IndividualAccuracies = nan(1,size(InpObs,2));

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

HistCheckData = [];

Params.Repetitions = RepCount;
Params.Classifier = ClsType;
Params.CurFeatureSet = CurFeatureSet;
[CurAcc,CurStd,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);


CurAccMinimal = -inf;
AvailableFeatures(AvailableFeatures == CurFeatureSet(1)) = [];
OrgAvailableFeatures = AvailableFeatures;

MissCounts = 0;
SelSetCount = -1;
SelSet = [];
StdMul = 0.1;
PrvMaxRes = -inf;


BestFeatures = struct;
BestFeatures.Comb = [];
BestFeatures.Accs = [];


%%
while(DoneFinding <= 6)
    
    if isnan(CurAcc)
        1
    end
    MaxInd = AvailableFeatures(1);


    Params.Repetitions = RepCount;
    Params.Classifier = ClsType;
    Params.CurFeatureSet = [CurFeatureSet MaxInd];
    Params
    [NewAcc,NewStd,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);

    Multiplier1 = NewStd/10;%-0.02/log(1-0.999);%(1-CurAcc/100).^0.001/100;
    Multiplier2 = sind(CurAcc*pi/100);
    Multiplier = min([Multiplier2 Multiplier1]);
%     Multiplier = max([Multiplier 0.02]);

    if Verbose >= 1
        fprintf('\nMultiplier = %8.6f',Multiplier);
    end

    % check the lowest accuracy features
    [HistCheckData,CurCount,Index] = ACD_CheckCombinations(HistCheckData,CurFeatureSet);

    if ~isfield(HistCheckData(Index),"Checked")
        HistCheckData(Index).Checked = false;
    elseif isempty(HistCheckData(Index).Checked)
        HistCheckData(Index).Checked = false;
    end
    if CurCount >= 2  && HistCheckData(Index).Checked == false && length(CurFeatureSet) > 1
        [KeepTheseFeatures,HistCheckData] = ACD_TestFeaturesViability_v3p3p0(InpObs,InpClasses,CurFeatureSet,StdMul,1,ClsType,RepCount,HistCheckData);
        HistCheckData(Index).Checked = true;
        if sum(KeepTheseFeatures == 0) >= 1
            fprintf('\nFeatures <%u,> where deemed bad and removed!',CurFeatureSet(KeepTheseFeatures == 0));
            CurFeatureSet(KeepTheseFeatures == 0) = [];

            Params.Repetitions = RepCount;
            Params.Classifier = ClsType;
            Params.CurFeatureSet = CurFeatureSet;
            [CurAcc,CurStd,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);
            
        end
    end
    CurAcc
    CurStd
    NewAcc
    NewStd

    if ((CurAcc+CurStd*StdMul) < (NewAcc - NewStd*StdMul)) 
        if Verbose >= 1
            fprintf('\n(CA=%5.2f%%),Accuracy with %2u features = %9.6f %% (Acc Inc = %8.6f, NewFeature = %u)',CurAcc,length(CurFeatureSet)+1,NewAcc,(CurAcc - NewAcc),MaxInd);
            TotTime =  [HistCheckData.CheckCount] - 1;
            TotTime(TotTime < 0) = 0;
            
%             clc
%             TotTime
%             [HistCheckData.ReqTime]
            TotTime = nansum([HistCheckData.ReqTime] .* TotTime);
            fprintf('\n(SavedTime = %8.2f\n',TotTime);
            if istable(InpObs)
                TotTime = sum([HistCheckData.ReqTime] .* [HistCheckData.CheckCount]);
                fprintf('\n(SavedTime = %8.2f, New Feature''s Name = "%s"\n',TotTime,InpObs.Properties.VariableNames{MaxInd});
            end
        end
        CurFeatureSet(end+1) = MaxInd; %#ok<*AGROW> 
        OrgAvailableFeatures(OrgAvailableFeatures == MaxInd) = [];
%         [IndicesMRMR,ScoresMRMR] = Local_FS(InpObs(:,OrgAvailableFeatures),InpClasses,'Verbose',1);
%         OrgAvailableFeatures = OrgAvailableFeatures(IndicesMRMR);
    
        AvailableFeatures = OrgAvailableFeatures;
        CurAcc = NewAcc;
        CurStd = NewStd;
        MissCounts(end+1) = 0;

        if Verbose >= 1
            if length(MissCounts) > 10
%                 MissCounts(end-10:end)
            else
%                 MissCounts %#ok<*NOPRT> 
            end
        end



        
    else
        SkippedFeatures = setdiff(AllFeatures,CurFeatureSet);
        SkippedFeatures = setdiff(SkippedFeatures,AvailableFeatures);
        AvailableFeatures(AvailableFeatures == MaxInd) = [];

        Params.Repetitions = RepCount;
        Params.Classifier = ClsType;
        Params.CurFeatureSet = CurFeatureSet;
        [CurAcc,CurStd,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);
        % check the lowest accuracy features

%         OrgAvailableFeatures(OrgAvailableFeatures == MaxInd) = [];

        if Verbose >= 1
            fprintf("\n%s, [",ModeStr);
            fprintf("%u,",CurFeatureSet);
            fprintf("]");
            fprintf('\n## (CA=%5.2f%%), Accuracy with %2u features Ac1=%9.6f%%,Ac2=%9.6f%% (Delta = %6.3f, Skipped Feature = %u)',CurAcc,length(CurFeatureSet),CurAcc,CurAcc,(CurAcc - NewAcc),MaxInd);
            fprintf('\n## AllSkips#=%u and Avil = %u, Average miss = %5.2f Std midd = %5.2f, MaxSkip = %u , MinSkp = %u',length(SkippedFeatures),length(AvailableFeatures),mean(MissCounts),std(MissCounts),max(SkippedFeatures),min(SkippedFeatures));

            TotTime =  [HistCheckData.CheckCount] - 1;
            TotTime(TotTime < 0) = 0;
            TotTime = sum([HistCheckData.ReqTime] .* TotTime);
            fprintf('\n(SavedTime = %8.2f\n',TotTime);
        end
        MissCounts(end) = MissCounts(end) + 1;
    end
%     pause
    if isempty(AvailableFeatures)
        DoneFinding = DoneFinding + 1;
        RepeatFinding = 0;
        if PrvMaxRes < CurAcc
            RepeatFinding = 1;
        end
        
        if DoneFinding >= 1 || RepeatFinding == 1
            Params.Repetitions = RepCount;
            Params.Classifier = ClsType;
            Params.CurFeatureSet = CurFeatureSet;
            [CurAcc,~,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);
            [MaxAcc,MaxInd] = nanmax(MLD_ExtractStructField(HistCheckData,'Accuracy'));
            if MaxAcc >= CurAcc || DoneFinding >= 1 
%                 [HistCheckData,~,Index] = ACD_CheckCombinations(HistCheckData,CurFeatureSet);
%                 HistCheckData(Index).Accuracy = -inf;
                CurAcc = MaxAcc;
                CurFeatureSet = HistCheckData(MaxInd).Comb;
                OrgAvailableFeatures = setdiff(FeaturesSt(CurInd).AvailableSet,CurFeatureSet);
                AvailableFeatures = OrgAvailableFeatures;
                for hcdCtr=1:length(HistCheckData)
                    HistCheckData(hcdCtr).Checked = false;
                end
            end
            PrvMaxRes = CurAcc;
        end
    end
end

FeaturesSt(CurInd).Combination = CurFeatureSet;

Params.Repetitions = RepCount;
Params.Classifier = ClsType;
Params.CurFeatureSet = CurFeatureSet;
[CurAcc,~,~,HistCheckData] = ACD_EvalAcc_v3p3p0(HistCheckData,InpObs,InpClasses,Params);

FeaturesSt(CurInd).Accuracy = CurAcc;

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