function [Savability,ChunkParts] = ACD_AUX_SavableInSplits(InpVar)
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
