% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Contrib = ACD_GetContributionFromCofusion_v3p0p0(InpConfusion)
Contrib = GetContribLocal(InpConfusion);
end

function Out = GetContribLocal(Inp)
Out = 0;
Inp = Inp ./ nansum(Inp(:));
% OtherNorm = (size(InpConfusion,1)-1)^-2;
% DiagNorm = size(InpConfusion,1)^-1;
for iCtr=1:size(Inp,1)
	PosAcc = Inp(iCtr,iCtr);
	NegAccVect = Inp(iCtr,:);
	NegAccVect(iCtr) = [];
	Accuracy = PosAcc - nansum(NegAccVect);
	Out = Out + Accuracy;
end
end


