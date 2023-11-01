% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function OutArr = ACD_LoadBigArray(ArrayName,LoadPath,AccountForFolder,Version)
%Version	'V1', 'V2'

if ~exist('AccountForFolder','var')  
	AccountForFolder = true;
elseif ~isnumeric(AccountForFolder) && ~islogical(AccountForFolder)
	error('Account for folder is logical value');
end

if ~exist('Version','var')
	Version = 'V1';
end

OutArr = [];
% fprintf('\nArray%u, %s , %s',AccountForFolder,LoadPath,ArrayName);

if AccountForFolder == true
	FolderPath = [LoadPath '\' ArrayName '.MldMatSav'];
else
	FolderPath = [LoadPath];
end
if ~exist(FolderPath,'dir')
	error('Folder <%s> does not exist',FolderPath);
end

FileNumber = 1;
if strcmpi(Version,'V1')
	Dim1File = '';
	DimHighFile = '';
elseif strcmpi(Version,'V2')
	Dim1File = '_D0';
	DimHighFile = '_D1';
else
	error('Unsupported Version <%s>',Version);
end

while(1)
	FileName = sprintf('%s_Chunk%03u',ArrayName,FileNumber);
	
	FileFolderPath = [FolderPath '\' FileName Dim1File '.mat'];
	if exist(FileFolderPath,'file')
		FileName = [FileName Dim1File '.mat'];
		FlatterMatrix = 0;	% Higher Column count matrix
	elseif exist([FolderPath '\' FileName DimHighFile '.mat'],'file')
		FileName = [FileName DimHighFile '.mat'];
		FlatterMatrix = 1;  % Higher row count matrix
	else
		FlatterMatrix = -1; % No such file
	end
	
	
	if FlatterMatrix >= 0
		fprintf('\n\tLoading file %s...',FileName);
		Data = load([FolderPath '\' FileName]);
		Data = Data.Data;
	else
		break;
	end 
	if FileNumber == 1
		OutArr = Data;
	else
		if FlatterMatrix == 1
			OutArr = ACD_MergeMatrices(OutArr,Data);
% 			OutArr(end+1:end+length(Data),:) = Data;
		elseif FlatterMatrix == 0
			OutArr(:,end+1:end+length(Data)) = Data;
		else
			error('We should not get to here!');
		end
	end
	
	FileNumber = FileNumber + 1;
end
end
