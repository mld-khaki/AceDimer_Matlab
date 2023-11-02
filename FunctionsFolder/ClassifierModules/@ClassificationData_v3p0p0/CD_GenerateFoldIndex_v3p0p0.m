% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [obj,NsFolds,ScFolds] = CD_GenerateFoldIndex_v3p0p0(obj,ObservationVector,ClassVector,FoldCount)
obj.MetaData = [];
obj.MetaData.ClassVector = ClassVector;
obj.MetaData.FoldCnt = FoldCount;
obj.MetaData.IndexOfRecords = 1:length(obj.MetaData.ClassVector);
obj.MetaData.Observations   = ObservationVector;

%list of the classes available in the obj.MetaData
obj.MetaData.UnqClassesVals = ACD_Make_RowMatrix(unique(obj.MetaData.ClassVector));
obj.MetaData.UnqClassesInds = 1:length(obj.MetaData.UnqClassesVals);

obj.MetaData.ScarceClsInds = [];
obj.MetaData.NonScarceClsInds = [];

for iCtr=1:length(obj.MetaData.UnqClassesVals)
    obj.MetaData.ClassCnts(iCtr) = sum(obj.MetaData.UnqClassesVals(iCtr) == obj.MetaData.ClassVector);
    if (obj.MetaData.ClassCnts(iCtr) >= obj.MetaData.FoldCnt && obj.MetaData.FoldCnt > 1) || ...
        (obj.MetaData.FoldCnt == 1&& FoldCount == 1)
        obj.MetaData.NonScarceClsInds(end+1) = iCtr;
    else
        obj.MetaData.ScarceClsInds(end+1) = iCtr;
    end
end

obj.MetaData.ScarceObsInds = find(obj.MetaData.ClassCnts < obj.MetaData.FoldCnt);
obj.MetaData.NonScarceObsInds = find(obj.MetaData.ClassCnts >= obj.MetaData.FoldCnt);


AvailableData = GenerateIndexOfData(obj.MetaData);

[NsFolds,UsedData] = FoldDistributor(obj.MetaData, AvailableData, 0 );
if FoldCount > 1
    [ScFolds,UsedData] = FoldDistributor(obj.MetaData, UsedData ,   obj.ScarceAccepted); %#ok<ASGLU>
else
    ScFolds = nan;
end






% **************************** main function end *****************************

    function [AvailableData] = GenerateIndexOfData(Data)
        AvailableData = [];
        AvailableData.Class = [];
        AvailableData(length(Data.ClassVector)).Class = [];
        
        for dCtr=1:length(Data.ClassVector)
            AvailableData(dCtr).ClassValue = Data.ClassVector(dCtr);
            AvailableData(dCtr).ClassIndex = find(Data.UnqClassesVals == Data.ClassVector(dCtr));
            AvailableData(dCtr).Used = 0;
            if sum(ACD_RowColVectEqual_v3p0p0(Data.ScarceClsInds,AvailableData(dCtr).ClassIndex)) >= 1
                AvailableData(dCtr).Scarce = 1;
            else
                AvailableData(dCtr).Scarce = 0;
            end
            AvailableData(dCtr).FeatureVals = {Data.Observations(dCtr,:)};
            AvailableData(dCtr).AssignedFold = -1;
        end
    end




    function [Folds, UpdatedData] = FoldDistributor(Data,AvailableData,ScarceAccepted)
        % distribute the observations of each class as evenly as possible in the
        % folds
        Folds = [];
        CorrespondingClasses = zeros(1,length(Data.UnqClassesVals));
        if ScarceAccepted == 1
            FoldCnt = 2;
            for mCtr = 1:length(Data.ScarceClsInds)
                CorrespondingClasses(mCtr) = Data.ScarceClsInds(mCtr);
            end
        else
            FoldCnt = Data.FoldCnt;
            for mCtr = 1:length(Data.NonScarceClsInds)
                CorrespondingClasses(mCtr) = Data.NonScarceClsInds(mCtr);
            end
        end
        
        for fCtr=1:FoldCnt
            Folds(fCtr).Balanced = 0;
            Folds(fCtr).ClassCnts = zeros(1,length(Data.UnqClassesVals));
            Folds(fCtr).Balanced = 0;
            Folds(fCtr).ObservationIndeces = [];
            Folds(fCtr).ObservationClsInds = [];
            Folds(fCtr).ObservationValuess = {};
        end
        
        AssignedCount = 0;
        if obj.DebugEnabled == 1
            fprintf('\nNew Fold Distribution...');
        end
        for dCtr=1:length(AvailableData)
            if (AvailableData(dCtr).Scarce ~= ScarceAccepted) || (AvailableData(dCtr).AssignedFold ~= -1)
                continue;
            else
                if (mod(dCtr,floor(length(AvailableData)/10)) == 0) && (obj.DebugEnabled == 1)
                    fprintf('\nDistributing data ... %5.2f%% done...',dCtr*100/length(AvailableData));
                end
                AssignedCount = AssignedCount+1;
                CurrentClassMainIndex = AvailableData(dCtr).ClassIndex;
				if isempty(CurrentClassMainIndex)
				else
					CurrentClassIndex = find(ACD_RowColVectEqual_v3p0p0(CurrentClassMainIndex,CorrespondingClasses));

					ClassCounts = zeros(1,FoldCnt);
					for fCtr=randperm(FoldCnt)
						if ~isempty(Folds(fCtr).ClassCnts(CurrentClassMainIndex))
							ClassCounts(fCtr) = Folds(fCtr).ClassCnts(CurrentClassMainIndex);
						end
					end
					[~,FillFoldIndex] = nanmin(ClassCounts);
					Folds(FillFoldIndex).ObservationIndeces(end+1) = dCtr; %#ok<*AGROW>

					Folds(FillFoldIndex).ObservationClsInds(end+1) = CurrentClassMainIndex;
					Folds(FillFoldIndex).ObservationValuess{end+1} = Data.Observations(dCtr,:);
					Folds(FillFoldIndex).ClassCnts(CurrentClassMainIndex) = Folds(FillFoldIndex).ClassCnts(CurrentClassMainIndex)+1;
					AvailableData(dCtr).AssignedFold = FillFoldIndex;
				end
            end
        end
        Folds = Folds(randperm(end));
        UpdatedData = AvailableData;
        
        
        if ~isempty(Data.ScarceClsInds) && (ScarceAccepted == 1)
            for qCtr = 1:length(Folds)
                if length(unique(Folds(qCtr).ObservationClsInds)) ~= length(Data.ScarceClsInds)
                    error('Unexpected class count = %u while fold count is %u',length(unique(Folds(qCtr).ObservationClsInds)),FoldCnt);
                end
            end
        end
        
    end
end
