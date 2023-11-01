% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_SaveBigData(InpSaveResults,InpVarName,SavePath)
Fields = fieldnames(InpSaveResults);
[Savability,~] = ACD_AUX_SavableInSplits(InpSaveResults);
if Savability == true
	ACD_SaveBigArray(InpSaveResults,InpVarName,SavePath,false)
else
	for iCtr=1:length(Fields)
		Data = InpSaveResults.(Fields{iCtr});
		
		StructFieldCount = 0;
		
		if isstruct(Data)
			StructFieldCount = length(fieldnames(Data));
		end
		FoldPath = [SavePath '\' InpVarName '.MldMatSav\'];
		wtmp = whos('Data');
		if wtmp.bytes < (1024^3)
			if ~exist(FoldPath,'dir')
% 				FoldPath
				mkdir(FoldPath);
			end
			save([FoldPath  '\' Fields{iCtr} '.NrmMatSav.mat'],'Data');
		else
			Status = 0;
			if StructFieldCount <= 1
				Status = ACD_SaveBigArray(Data,Fields{iCtr},[FoldPath '\' Fields{iCtr}],false);
			end
			
			if Status == 0 && StructFieldCount > 1
				NewSavePath = [FoldPath '\Re_entrantStruct_' Fields{iCtr}];
				ACD_SaveBigData(InpSaveResults.(Fields{iCtr}),Fields{iCtr},NewSavePath);
			end
		end
	end
end
end


