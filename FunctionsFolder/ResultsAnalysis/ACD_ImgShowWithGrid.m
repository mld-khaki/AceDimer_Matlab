% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_ImgShowWithGrid(InpImg)
Wdy = 11;
Wdx = 11;
InpImg2 = ones(size(InpImg,1)*Wdy+1,size(InpImg,2)*Wdx+1,3)*0.2;

for jCtr=1:size(InpImg,1)
    if mod(jCtr,3) == 0
        yOffs = 1;
    else
        yOffs = 0;
    end
    for kCtr=1:size(InpImg,2)
        Jrng = (jCtr-1)*Wdy+1:jCtr*Wdy;
        Krng = (kCtr-1)*Wdx+1:kCtr*Wdx;
        
        if mod(kCtr,3) == 0
            xOffs = 1;
        else
            xOffs = 0;
        end
        
%         for t1Ctr=1:Wdy-yOffs
% %             for t2Ctr=1:Wdx-xOffs
% %                 InpImg2(Jrng(t1Ctr)+1,Krng(t2Ctr)+1,:) = InpImg(jCtr,kCtr,:);
% %             end
%             Len = length(1:Wdx-xOffs);
%             InpImg2(Jrng(t1Ctr)+1,Krng(1:Wdx-xOffs)+1,:) = repmat(InpImg(jCtr,kCtr,:),1,Len);
%         end
%         for t1Ctr=1:Wdy-yOffs
%             for t2Ctr=1:Wdx-xOffs
%                 InpImg2(Jrng(t1Ctr)+1,Krng(t2Ctr)+1,:) = InpImg(jCtr,kCtr,:);
%             end
        LenX = length(1:Wdx-xOffs);
        LenY = length(1:Wdy-yOffs);
        InpImg2(Jrng(1:Wdy-yOffs)+1,Krng(1:Wdx-xOffs)+1,:) = repmat(InpImg(jCtr,kCtr,:),LenY,LenX);
%         end
    end
end

if nargout >= 1
    Out = InpImg2;
else
    imshow(InpImg2);
end
end
