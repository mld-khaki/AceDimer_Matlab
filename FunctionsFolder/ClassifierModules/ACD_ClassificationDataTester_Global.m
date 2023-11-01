% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_ClassificationDataTester_Global_v16p0(ClassData)
Out = false;
if iscell(ClassData)
    for cCtr=1:length(ClassData)
        Out = Out || ClassificationDataTester(ClassData{cCtr});
        if Out == 1
            return
        end
    end
    return
elseif isstruct(ClassData) && ~isfield(ClassData,'NormalizeData')
    FieldsCtr = fieldnames(ClassData);
    for sCtr=1:length(FieldsCtr)
        Out = Out || ClassificationDataTester(ClassData.(FieldsCtr{sCtr}));
        if Out == 1
            return
        end
    end
    return
end

for fCtr=1:ClassData.GetFoldCount()
    Data = ClassData.GetTrainingObs_BOFoldNum(fCtr);
    Features = ClassData.GetUsableFeaturesIndex();
    Data(:,Features == 0) = [];
    
    SumVal = nansum(nansum(isnan(Data)));
    if SumVal > 0
        Out = true;
        return
    end
end

end
