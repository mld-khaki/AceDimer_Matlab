function OutStr = ACD_CombineDirectoryWithFileFold(Folder,FileFold)
OutStr = [Folder '\' FileFold];

PrvStr = '';
while(strcmpi(OutStr,PrvStr) == 0)
	PrvStr = OutStr;
	OutStr = strrep(OutStr,'\\','\');
end
end
