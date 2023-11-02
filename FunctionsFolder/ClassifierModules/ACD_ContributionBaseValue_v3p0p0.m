% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_ContributionBaseValue_v3p0p0(ClassesVector)
UnCounts= unique(ClassesVector);

Out = 1/length(UnCounts);
return

BestRandom = -inf;
for iCtr=1:length(UnCounts)
    TempRand = sum(UnCounts(iCtr) == ClassesVector)/length(ClassesVector);
    BestRandom = max([BestRandom,TempRand]);
end

Out = BestRandom;
end
