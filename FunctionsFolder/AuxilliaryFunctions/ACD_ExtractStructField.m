function Array = ACD_ExtractStructField(myStruct,FieldName)
% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
Type =-1;
try
    for mCtr=1:length(myStruct)
        if (Type == -1 && isnumeric(myStruct(mCtr).(FieldName)) || iscategorical(myStruct(mCtr).(FieldName)))...
                || Type == 1
            Type = 1;
            if mCtr==1 
                if isnumeric(myStruct(mCtr).(FieldName))
                    Array = nan(1,length(myStruct));
                elseif iscategorical(myStruct(mCtr).(FieldName))
                    Array = categorical(1,length(myStruct));
                end
			end
			if  isempty(myStruct(mCtr).(FieldName)) 
                continue;
			elseif iscategorical(myStruct(mCtr).(FieldName)) 
				if isundefined(myStruct(mCtr).(FieldName))
					continue;
				end
			elseif nansum(isnan(myStruct(mCtr).(FieldName)))>0
				continue;
			end
            Array(mCtr) = myStruct(mCtr).(FieldName);
        elseif Type == -1 || Type == 2
            Type = 2;
            if mCtr==1
                Array = {};
            end
            if  isempty(myStruct(mCtr).(FieldName)) || ...
                    nansum(isnan(myStruct(mCtr).(FieldName)))>0
                Array{mCtr} = '';
            else
                Array{mCtr} = myStruct(mCtr).(FieldName);
            end
        end
    end
catch ME
    rethrow(ME);
end
end
