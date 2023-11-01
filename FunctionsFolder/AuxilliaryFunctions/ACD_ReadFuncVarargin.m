% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function OutSt = ACD_ReadFuncVarargin(varargin)
varargin = varargin{1};
if ~iscell(varargin)
    error('The input is not cell type');
elseif isstruct(varargin{1})
    OutSt = varargin{1};
    return
else
    OutSt = [];
    for iCtr=1:length(varargin)
        if ~iscell(varargin{iCtr}) 
            error('Not the data structur that is expected, each input variable should be a cell itself');
        elseif ~ischar(varargin{iCtr}{1})
            error('The first argument is always parameter name');
        elseif length(varargin{iCtr}) ~= 2
            error('Expecting a cell of two variables, name and value');
        else
            OutSt.(varargin{iCtr}{1}) = varargin{iCtr}{2};
        end
    end
end
end