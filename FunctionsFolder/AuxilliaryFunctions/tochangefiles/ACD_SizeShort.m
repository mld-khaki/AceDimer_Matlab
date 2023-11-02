function [OutSize, OutIndex] = ACD_SizeShort(Input)
if size(Input,1) < size(Input,2)
    OutSize = size(Input,1);
    OutIndex = 1;
else
    OutSize = size(Input,2);
    OutIndex = 2;
end
end