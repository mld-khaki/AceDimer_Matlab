% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [O_Attributes,O_FeatureNames] = ACD_AUX_PruneMatrix_v3p0p0(D_PrePrn_FeatureNames,PrnWords,D_PrePrn_Attributes)
O_Attributes = D_PrePrn_Attributes;
O_FeatureNames = D_PrePrn_FeatureNames;
for pCtr=1:length(PrnWords)
    FoundInd = -1;
    for fnCtr=length(O_FeatureNames):-1:1
        if strcmpi(PrnWords{pCtr},O_FeatureNames{fnCtr}) == 1
            FoundInd = fnCtr;
        end
    end
    if FoundInd > -1
        O_Attributes(:,FoundInd) = [];
        O_FeatureNames(FoundInd) = [];
    end
end
end
