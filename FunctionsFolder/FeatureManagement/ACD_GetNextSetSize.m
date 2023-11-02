function [OutA,OutB,OutSize] = ACD_GetNextSetSize(InpA,InpB)

CurNumber = nchoosek(InpA,InpB);

if InpA<InpB+1
    OutA = InpA+1;
    OutB = InpB;
    OutSize = nchoosek(OutA,OutB);
    return
end

NextNumA = nchoosek(InpA+1,InpB  );
NextNumB = nchoosek(InpA  ,InpB+1);

if NextNumA > NextNumB
    OutA = InpA+1;
    OutB = InpB;
    OutSize = NextNumA;
else
    OutA = InpA;
    OutB = InpB+1;
    OutSize = NextNumB;
end
end