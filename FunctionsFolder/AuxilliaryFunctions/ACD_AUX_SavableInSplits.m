function [Savability,ChunkParts] = ACD_AUX_SavableInSplits(InpVar)
% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
if ndims(InpVar) > 2
	error('This function does not work for Matrixes with higher dimentions than 2!');
end

if size(InpVar,1) > size(InpVar,2)
	InpVar = InpVar';
end

Savability = false;
ChunkParts = {};
wtmp = whos('InpVar');
Segments = ceil( (wtmp.bytes/(1024^3)));
SegLen = ceil(length(InpVar)/Segments);

% test if division is possible
iCtr = 1;
ArrBeg = (iCtr-1)*SegLen+1;
ArrEnd = nanmin([(iCtr)*SegLen length(InpVar)]);
tmp = InpVar(ArrBeg:ArrEnd);
wtmp =whos('tmp');
if wtmp.bytes > (1024^3)
	return
else
	Savability = true;
	for iCtr=1:Segments
		ArrBeg = (iCtr-1)*SegLen+1;
		ArrEnd = nanmin([(iCtr)*SegLen length(InpVar)]);
		ChunkParts{iCtr} = [ArrBeg,ArrEnd];
	end
end

end
