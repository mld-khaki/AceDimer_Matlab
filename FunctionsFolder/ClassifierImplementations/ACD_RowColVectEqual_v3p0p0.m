% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_RowColVectEqual_v3p0p0(Inp1,Inp2)
Inp1A = size(Inp1,1);
Inp1B = size(Inp1,2);

Inp2A = size(Inp2,1);
Inp2B = size(Inp2,2);

Out = false;
if (Inp1A == Inp2A) && (Inp1B == Inp2B)
    Out = Inp1 == Inp2;
elseif (Inp1A == Inp2B) && (Inp1B == Inp2A)
    Out = Inp1 == Inp2';
else
    Out = false;
end
        

end