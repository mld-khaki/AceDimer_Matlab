% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_AUX_ConfusionMatrixScore_v16p0(InpConFolds)
FieldNames = fieldnames(InpConFolds);

tmpConf = zeros(size(InpConFolds.(FieldNames{1})));
for iCtr=1:length(FieldNames)
    tmpConf = tmpConf + InpConFolds.(FieldNames{iCtr});
end
tmpConf = tmpConf ./ length(FieldNames);

Out = 0;
for iCtr=1:size(tmpConf,1)
    Others = tmpConf(iCtr,:);
    Others(iCtr) = [];
    Out = Out + nansum(Others)/nansum(tmpConf(iCtr,:));
end

if Out <= 1.1
    assert(Out <= 1.1);
else
%     1
end

Out = 1-Out;
end