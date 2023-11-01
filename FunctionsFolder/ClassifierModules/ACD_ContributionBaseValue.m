% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_ContributionBaseValue_v16p0(ClassesVector)
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
