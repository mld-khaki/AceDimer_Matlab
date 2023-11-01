% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function Status = ACD_NanFree(Input)

OutSum = isnan(Input);
for nCtr=1:ndims(OutSum)
    OutSum = sum(OutSum,nCtr);
end

Status = OutSum == 0;

end