% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [StringOut,TicStart] = ACD_TocPercent(TicStart,CurrentCnt,StartCnt,MaxCnt)
if nargin <= 0
    TicStart = [];
    TicStart.tic = tic;
    TicStart.LastTic = tic;
    TicStart.TicCnt = 100;
    TicStart.DefaultPercentageTime = 5;
    TicStart.Misses = 0;
end

Difference = toc(TicStart.LastTic);

if Difference < TicStart.DefaultPercentageTime
    StringOut = '';
    if Difference / TicStart.DefaultPercentageTime < 0.5
        TicStart.TicCnt = floor(TicStart.TicCnt*1.1);
    end
    TicStart.Misses = TicStart.Misses+1;
    return;
else
    StringOut = sprintf('Processing...time since last display = %s...\n%s',GenerateTotalDurationStr(toc(TicStart.LastTic)),ACD_ProjectedFinishCalculator_v3p0p0(toc(TicStart.tic),CurrentCnt,MaxCnt,StartCnt));
    TicStart.LastTic = tic;
    TicStart.Misses = 0;
    if Difference > 1.5*TicStart.DefaultPercentageTime
        TicStart.TicCnt = ceil(TicStart.TicCnt/2);
    end
end


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