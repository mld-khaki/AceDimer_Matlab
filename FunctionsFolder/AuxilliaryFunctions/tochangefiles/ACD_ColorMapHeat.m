function Out = ACD_ColorMapHeat(Count)
if ~exist('Count','var')
    Count = 256;
end

Out = zeros(Count,3);
Gradient = linspace(0,1,Count);
for iCtr=1:Count
    Out(iCtr,:) = [Gradient(iCtr),0,Gradient(end-iCtr+1)];
end
end