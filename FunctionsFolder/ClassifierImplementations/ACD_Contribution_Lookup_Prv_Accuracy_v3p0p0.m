% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 2.0.1 $  $Date: 2021/05/25  11:05 Updated to new v.2 $
% $Revision: 2.0.3 $  $Date: 2021/05/26  20:40 Updated the mapping scheme to materializing the "AllCombs" variable on the folder
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_Contribution_Lookup_Prv_Accuracy_v3p0p0(InpAllCombinations,InpVect,Reset)
% AllCombsFileName = sprintf('AllFeat_%03u___SetFeat_%03u.mat',Options.AllFeaturesCount,Options.SetFeaturesCount);
% if isfield(Options,'ToolsDirectory')
%     FolderPath = Options.ToolsDirectory;
% else
%     FolderPath = pwd;
% end

persistent AllCombs
persistent AllFields

if Reset == 1 || isempty(AllCombs)
%     FilePathName = [FolderPath '\' AllCombsFileName];
%     if exist(FilePathName)
%         AllCombs = load(FilePathName);
%     else
    AllFields = {};
    AllFields{nanmax(InpAllCombinations(:))} = '';
    for iCtr=1:nanmax(InpAllCombinations(:))
        AllFields{iCtr} = sprintf('M%06u',iCtr);
    end
    AllCombs = struct;
    Vect = {};
    for iCtr=1:size(InpAllCombinations,1)
        for qCtr=1:size(InpAllCombinations,2)
            Vect{qCtr} = AllFields{InpAllCombinations(iCtr,qCtr)};
        end
        AllCombs = setfield(AllCombs,Vect{:},iCtr);
    end
%     end
    Out = nan;
else
    Fields = {};
    for qCtr=1:length(InpVect)
        Fields{qCtr} = AllFields{InpVect(qCtr)};
    end
    Out = getfield(AllCombs,Fields{:});
end

end

function Vect = ConvertToList(Inp)
Vect = {};
for qCtr=1:length(Inp)
    Vect{qCtr} = sprintf('M%04u',Inp(qCtr));
end
end
% SelVect = ones(1,size(InpAllCombinations,1),'logical');
% InpVect = sort(InpVect);
% for qCtr=1:length(InpVect)
%     Vect2 = (InpAllCombinations(:,qCtr) ~= InpVect(qCtr));
%
%     SelVect(Vect2) = 0;
% end
%
% Out = [];
%
% if nansum(SelVect) >= 1
%     Out = find(SelVect);
% end


% for qCtr=1:size(InpAllCombinations,1)
%     Found = 1;
%     for iCtr=1:length(InpVect)
%         if Found == 0, continue;end
%         if InpAllCombinations(qCtr,iCtr) > InpVect(iCtr)
%             Found = 0;
%             break;
%         end
%         if sum(InpAllCombinations(qCtr,:) == InpVect(iCtr)) ~= 1
%             Found = 0;
%             break;
%         end
%     end
%     if Found == 1
%         Out = qCtr;
%         return
%     end
% end
% end


%Second version
% function Out = ACD_Contribution_Lookup_Prv_Accuracy(InpAllCombinations,InpVect)
% Out = [];
% % AllCombs = perms(InpVect);
% % OrgVect = 1:size(InpAllCombinations,1);
%
% for qCtr=1:size(InpAllCombinations,1)
%     Found = 1;
%     for iCtr=1:length(InpVect)
%         if Found == 0, continue;end
%         if sum(InpAllCombinations(qCtr,:) == InpVect(iCtr)) ~= 1
%             Found = 0;
%             continue;
%         end
%     end
%     if Found == 1
%         Out = qCtr;
%         return
%     end
% end
% end
%


% OrgVersion
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