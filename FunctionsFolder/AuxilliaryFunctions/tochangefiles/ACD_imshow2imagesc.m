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