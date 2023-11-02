function Status = ACD_NanFree(Input)
OutSum = isnan(Input);
for nCtr=1:ndims(OutSum)
    OutSum = sum(OutSum,nCtr);
end

Status = OutSum == 0;
end