function Out = ACD_NHTest(Inp,Sensitivity)
if length(Inp) < 4
    Out = 0;
    return
end

if ~exist("Sensitivity","var")
    Sensitivity = 0.1;
end
% Out = kstest(Inp,"Alpha",Sensitivity);
%   Out = jbtest(Inp,[],Sensitivity);
%   Out = adtest(Inp,);
Out = lillietest(Inp,"Alpha",Sensitivity,"MCTol",0.1);
end