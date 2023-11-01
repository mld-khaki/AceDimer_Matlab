% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function out = ACD_IsNan(Input)
if iscell(Input)
    if length(Input) > 1
        out = false;
        return
    end
end
out=zeros(size(Input));
if iscell(Input)
    for i=1:length(Input)
        out(i+1) = ACD_IsNan(Input{i});
    end
    out(1) = 0;
    for i=1:length(Input)
        out(1) = out(1) || out(i+1);
    end
    out = out(1);
elseif ischar(Input)
    if isempty(Input)
        out = 1;
    else
        out = 0;
    end
else
    out = isnan(Input);
end
