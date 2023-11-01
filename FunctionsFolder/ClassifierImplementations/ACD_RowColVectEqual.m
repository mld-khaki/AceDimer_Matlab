% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_RowColVectEqual_v16p0(Inp1,Inp2)
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