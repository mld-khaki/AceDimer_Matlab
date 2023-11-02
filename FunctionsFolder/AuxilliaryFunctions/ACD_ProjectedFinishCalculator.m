% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [ FinishMessage ] = ACD_ProjectedFinishCalculator_v16p0( InputToc, CurrentRecord, MaxRecordsCount, StartingRecord )
if nargin <= 3
    StartingRecord = 1;
end
PassedTime = InputToc;
TotalDuration = (MaxRecordsCount*PassedTime)/(CurrentRecord-StartingRecord+1);


FinishMessage = sprintf([   '\n\tPercentage = %6.4f%%, Record Number = %u' ...
    '\n\tTime takes for each account = %8.6f seconds -- ' ...
    '\n\tPassed Time = %s '...
    'Projected Finish = %s' ...
    '\n\tTotal duration = %s,' ...
    'Remaining time = %s'],...
    100*CurrentRecord/MaxRecordsCount , CurrentRecord,...
    PassedTime/(CurrentRecord-StartingRecord+1),...
    GenerateTotalDurationStr(PassedTime),...
    datestr(now+datenum(0,0,0,0,0,1)*(MaxRecordsCount-CurrentRecord)*PassedTime/(CurrentRecord-StartingRecord+1),'mm-dd HH:MM:SS'),...
    GenerateTotalDurationStr(TotalDuration),...
    GenerateTotalDurationStr((MaxRecordsCount-CurrentRecord)*PassedTime/(CurrentRecord-StartingRecord+1)));

    function Output = GenerateTotalDurationStr(TotalDur)
        Strings =     {'Month','Day','Hour','Minute','Second'};
        Multipliers = [   30  , 24  , 60   , 60     , 1      ];
        
        Output = '';
        TempDur = TotalDur;
        for ctr = 1:length(Multipliers)
            % 			prod(Multipliers(ctr:end))
            TotalTime = floor(TempDur / prod(Multipliers(ctr:end)));
            if TotalTime > 0
                if TotalTime == 1
                    TimeSingle = '';
                else
                    TimeSingle = 's';
                end
                Output = [Output sprintf('%u %s%s, ',TotalTime,Strings{ctr},TimeSingle)];
            end
            TempDur = TempDur - TotalTime*prod(Multipliers(ctr:end));
        end
    end
end

