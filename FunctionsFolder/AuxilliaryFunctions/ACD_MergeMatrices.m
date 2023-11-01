% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function Out = ACD_MergeMatrices(InMat1,InMat2,EqDimOut)
if ~exist('EqDimOut','var')
	EqDimOut = 1;
end

if (size(InMat1,1) == size(InMat2,1)) 
	Out = [InMat1 InMat2]';
elseif size(InMat1,2) == size(InMat2,1)
	Out = [InMat1' InMat2];
elseif size(InMat1,1) == size(InMat2,2)
	Out = [InMat1 InMat2'];
elseif (size(InMat1,2) == size(InMat2,2))
	Out = [InMat1' InMat2'];
else
	error('Two matrices do not match in any way!');
end

if EqDimOut == 1 
	Out = Out';
elseif EqDimOut == 2
else
	error('Unexpected dimension for merging matrices');
end

end
