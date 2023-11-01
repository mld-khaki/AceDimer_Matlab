% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [Folds, Classes, ClassIndex] = CD_GetTstTrnFold_v16p0(obj,NsFolds,ScFolds,TTrainFTest,SelectedFold)
% NsFolds       Not Symmetrical folds
% ScFolds       Symmetrical Folds
% True for Training, False for Testing
% 
Folds = [];

if iscategorical(obj.MetaData.UnqClassesVals)
	Classes = categorical;
else
	Classes = [];
end
ClassIndex = [];
if nargin > 2
    if TTrainFTest == 1 % Training
        NsFoldNums = 1:obj.FoldCount;
        NsFoldNums(SelectedFold) = [];
        ScFoldNums = 1;     % we only have two folds, so first fold is for training
    else %Testing Condition
        NsFoldNums = SelectedFold;
        ScFoldNums = 2;     % we only have two folds, so first fold is for testing
    end

    for fCtr=NsFoldNums
        for oCtr=1:length(NsFolds(fCtr).ObservationValuess)
            Folds(end+1,:) = NsFolds(fCtr).ObservationValuess{oCtr};
            CurInd = NsFolds(fCtr).ObservationClsInds(oCtr);
            Classes(end+1) = obj.MetaData.UnqClassesVals(CurInd);
        end
        ClassIndex = [ClassIndex,NsFolds(fCtr).ObservationIndeces];
    end

    for fCtr=ScFoldNums
        for oCtr=1:length(ScFolds(fCtr).ObservationValuess)
            Folds(end+1,:) = ScFolds(fCtr).ObservationValuess{oCtr};
            CurInd = ScFolds(fCtr).ObservationClsInds(oCtr);
            Classes(end+1) = obj.MetaData.UnqClassesVals(CurInd);
        end
        ClassIndex = [ClassIndex,ScFolds(fCtr).ObservationIndeces];
    end
else % one fold mode
    for oCtr=1:length(NsFolds.ObservationValuess)
        Folds(end+1,:) = NsFolds.ObservationValuess{oCtr};
        CurInd = NsFolds.ObservationClsInds(oCtr);
        Classes(end+1) = obj.MetaData.UnqClassesVals(CurInd);
    end
    ClassIndex = [ClassIndex,NsFolds.ObservationIndeces];
end
end
