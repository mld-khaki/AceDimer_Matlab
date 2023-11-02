% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $ Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $

function Out = ACD_LoadBigData(LoadPath,InpVarName,SkipVarCell)
fprintf('\n%s , %s',LoadPath,InpVarName);
drawnow;
if ~contains(InpVarName,'MldMatSav') && ~contains(InpVarName,'Re_entrantStruct')
	InpVarName = [InpVarName '.MldMatSav'];
end
if ~exist('SkipVarCell','var')
	SkipVarCell = {};
end

FullPath = [LoadPath '\' InpVarName '\'];
if ~exist(FullPath,'dir')
	error('The folder <%s> does not exist!',FullPath);
end

Folds = dir(FullPath);
for iCtr=1:length(Folds)
	if sum(strcmpi(Folds(iCtr).name,{'.','..'})) == 1
		continue;
	end
	
	
	if contains(Folds(iCtr).name,'NrmMatSav')
		VarName = strrep(Folds(iCtr).name,'.NrmMatSav.mat','');
		tmp = load([FullPath '\' Folds(iCtr).name]);
		Out.(VarName) = tmp.Data;
		continue;
	end
	
	ReEntName = 'Re_entrantStruct_';
	ReEntLen = length(ReEntName);
	HasReEnt = contains(Folds(iCtr).name,ReEntName);
	FindInd = strfind(Folds(iCtr).name,ReEntName);
	
	VarFolderExists = exist([FullPath '\' Folds(iCtr).name],'dir');
	
	if ~HasReEnt && (VarFolderExists > 0) 
		NewPathName = Folds(iCtr).name;
		VarName = strrep(NewPathName,'.MldMatSav','');
		FolderPath = ACD_CombineDirectoryWithFileFold(FullPath,'');
		Out.(VarName) = ACD_LoadBigArray(VarName,FolderPath,false);
		continue;
	end
	
	if HasReEnt == true
		VarName = Folds(iCtr).name(FindInd+ReEntLen:end);
% 		Out.(VarName) = ACD_LoadBigData(FullPath,Folds(iCtr).name,SkipVarCell);
		FolderPath = ACD_CombineDirectoryWithFileFold(FullPath,Folds(iCtr).name);
		if nansum(strcmpi(VarName,SkipVarCell)) >= 1
			Out.(VarName) = [];
		else
			Out.(VarName) = ACD_LoadBigData(FolderPath,VarName,SkipVarCell);
		end
		continue
	end

	InsideVarFolder = contains(InpVarName,ReEntName) && contains(Folds(iCtr).name,'Chunk');
	if InsideVarFolder == true
		VarName = strrep(InpVarName,ReEntName,'');
		if nansum(strcmpi(VarName,SkipVarCell)) >= 1
			Out = [];
		else
			Out = ACD_LoadBigArray(VarName,[LoadPath '\' InpVarName],false);
		end
		% we don't need the field as in Out.(Varname) because the re_entrant code has already created it.
		break;
	end
	
	
	error('Unknown file/folder type: <%s>',Folds(iCtr).name);
	
end
end


