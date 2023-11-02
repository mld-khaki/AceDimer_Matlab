% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_Contribution_Lookup_Preparation(InpAllCombinations)
Out = InpAllCombinations;

for iCtr=1:size(Out)
    Out(iCtr,:) = sort(Out(iCtr,:));
end

Out = sortrows(Out,1:size(Out,2));
end

% 
% function Out = ACD_Contribution_Lookup_Prv_Accuracy(InpAllCombinations,InpVect)
% AllCombs = perms(InpVect);
% OrgVect = 1:size(InpAllCombinations,1);
% 
% for qCtr=1:size(AllCombs,1)
%     tmpVect = AllCombs(qCtr,:);
%     Vect = OrgVect;
%     for iCtr=1:length(tmpVect)
%         Vect2 = find(InpAllCombinations(Vect,iCtr) == tmpVect(iCtr));
%         Vect = Vect(Vect2);  
%     end
%     if ~isempty(Vect)
%         Out = Vect;
%         return
%     end
% end
% end