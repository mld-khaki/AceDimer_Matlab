% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function IMG = ACD_imshow2imagesc(InpIMG,InpColorMap)
MaxVal = nanmax(InpIMG(:));
MinVal = nanmin(InpIMG(:));

Vector = linspace(MinVal,MaxVal,size(InpColorMap,1));

IMG = zeros(size(InpIMG,1),size(InpIMG,2),3);
for iCtr=1:size(InpIMG,1)
    for jCtr=1:size(InpIMG,2)
        [~,Mindex] = nanmin(abs(Vector-InpIMG(iCtr,jCtr)));
        IMG(iCtr,jCtr,:) = InpColorMap(Mindex,:);
    end
end


end