% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_Make_RowMatrix(Input1)

if size(Input1,1) < size(Input1,2)
	Out = Input1;
else
	Out = Input1';
end

end
