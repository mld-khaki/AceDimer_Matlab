% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [objOut,BNsFolds,BScFolds] = CD_BalanceFoldsAndScarceFolds_v16p0(obj,NsFolds,ScFolds,JitterWeight,JitterPercentage)
if obj.EqualFoldCount ~= -1
    CheckTheLengthVector = obj.EqualFoldCount;
else
    CheckTheLengthVector = -1;
end

if ~isstruct(ScFolds) && obj.FoldCount > 1
    error('Scarce classes are only not available in the one fold confirguation');
elseif obj.FoldCount == 1
    MaxClassCount = FindMaxClassCount([],NsFolds);
    BNsFolds = BalanceFolds(obj,obj.MetaData,NsFolds,0,MaxClassCount,JitterWeight,JitterPercentage);
    BScFolds = [];
    if (CheckTheLengthVector ~= -1)
        while (CheckTheLengthVector > length(BNsFolds.ObservationValuess))
            MaxClassCount = MaxClassCount + 1;
            BNsFolds = BalanceFolds(obj,obj.MetaData,NsFolds,0,MaxClassCount,JitterWeight,JitterPercentage);
        end
    else
        obj.EqualFoldCount = length(BNsFolds.ObservationValuess);
    end
else
    MaxClassCount = FindMaxClassCount(ScFolds,NsFolds);
    BNsFolds = BalanceFolds(obj,obj.MetaData,NsFolds,0,MaxClassCount,JitterWeight,JitterPercentage);
    BScFolds = BalanceFolds(obj,obj.MetaData,ScFolds,1,MaxClassCount,JitterWeight,JitterPercentage);
    if (CheckTheLengthVector > 0)
        MaxFoldCnt = -inf;
        while (CheckTheLengthVector > MaxFoldCnt)
            MaxFoldCnt = -inf;
            for f3Ctr=1:length(BNsFolds)
                MaxFoldCnt = nanmax([MaxFoldCnt length(BNsFolds(f3Ctr).ObservationValuess)]);
            end
            MaxClassCount = MaxClassCount + 1;
            BNsFolds = BalanceFolds(obj,obj.MetaData,NsFolds,0,MaxClassCount,JitterWeight,JitterPercentage);
            BScFolds = BalanceFolds(obj,obj.MetaData,ScFolds,1,MaxClassCount,JitterWeight,JitterPercentage);
        end
    else
    end
end

objOut = obj;

    function Folds = BalanceFolds(Obj,Data,Folds,AcceptScarce,MaxClassCount,JitterWeight,JitterPercentage)
        if AcceptScarce == 1
            ClassIndexVector = Data.ScarceClsInds;
        else
            ClassIndexVector = Data.NonScarceClsInds;
        end
        if Obj.DebugEnabled == 1
            fprintf('\nBalancing Class Index %u =>', ClassIndexVector);
        end
        for fCtr=1:length(Folds)
            if Obj.DebugEnabled == 1
                fprintf('.');
            end
            for cCtr=ClassIndexVector
                % check to see if all classes have equal number of classes
                if nansum(Folds(fCtr).ClassCnts == MaxClassCount) == length(ClassIndexVector) % either NonScarceClass or ScarceClass vector
                    Folds(fCtr).Balanced = 1;
                else
                    for mCtr=1:MaxClassCount - Folds(fCtr).ClassCnts(cCtr)
                        UpdateAvailableOptions = 0;
                        if ~exist('AvailableOptions','var')
                            PrvcCtr = cCtr;
                            UpdateAvailableOptions = 1;
                        elseif isempty(AvailableOptions) || PrvcCtr ~= cCtr
                            UpdateAvailableOptions = 1;
                            PrvcCtr=cCtr;
                        end
                        
                        if UpdateAvailableOptions == 1
                             AvailableOptions = find(Folds(fCtr).ObservationClsInds == cCtr);
                             AvailableOptions = AvailableOptions(randperm(length(AvailableOptions)));
                             
                             if isempty(AvailableOptions) 
                                 continue;
                             end
                        end
                        AvailableOptions(AvailableOptions > length(Folds(fCtr).ObservationClsInds)) = [];
                        Selected = AvailableOptions(1);
                        AvailableOptions(1) = [];
                        
                        CurrentClassIndex = Folds(fCtr).ObservationClsInds(Selected);
						
						% tmpFold is the data observations that belong to the same class that is being added
						% it is used to generate correct jitter value
						tmpFold = Folds(fCtr);
						CurrentClassIndices = Folds(fCtr).ObservationClsInds == CurrentClassIndex;
						tmpFold.ObservationClsInds(~CurrentClassIndices) = [];
						tmpFold.ObservationIndeces(~CurrentClassIndices) = [];
						tmpFold.ObservationValuess(~CurrentClassIndices) = [];

						Folds(fCtr).ObservationIndeces(end+1) = Folds(fCtr).ObservationIndeces(Selected); %#ok<*AGROW>
                        Folds(fCtr).ObservationClsInds(end+1) = CurrentClassIndex;
                        
                        TempObsVector = Folds(fCtr).ObservationValuess{Selected};
						if JitterWeight > 0 && JitterPercentage > 0
							TempObsVector = ACD_AddJitterToGaussianData_v16p0(tmpFold,TempObsVector,JitterPercentage,JitterWeight);
						end
%                         for 
                        
                        Folds(fCtr).ObservationValuess{end+1} = TempObsVector;
                        Folds(fCtr).ClassCnts(CurrentClassIndex) = Folds(fCtr).ClassCnts(CurrentClassIndex)+1;
                    end
				end
            end
        end
        if Obj.DebugEnabled == 1
            fprintf('<=');
        end
    end

    function MaxClassCount = FindMaxClassCount(Folds,ScFolds)
        MaxClassCount = -inf;
        for fCtr=1:length(Folds)
            MaxClassCount = max([MaxClassCount Folds(fCtr).ClassCnts]);
        end
        for fCtr=1:length(ScFolds)
            MaxClassCount = max([MaxClassCount ScFolds(fCtr).ClassCnts]);
        end
        
    end
end
