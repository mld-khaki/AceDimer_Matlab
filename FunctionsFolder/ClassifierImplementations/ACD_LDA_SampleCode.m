% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

clearvars -except TrainClass TrainData
if ~exist('TrainData','var')
      % Generate example data: 2 groups, of 10 and 15, respectively
      TrainData = [randn(10,2); randn(15,2) + 1.5];  
      TrainClass = [-5*ones(10,1); ones(15,1)*5];
end

ClassCount = length(TrainClass);
hpartition = cvpartition(ClassCount,'Holdout',0.5); % Nonstratified partition

TrnObserve = TrainData(hpartition.training,:);
TrnClasses = TrainClass(hpartition.training);

TstObserve = TrainData(hpartition.test,:);
TstClasses = TrainClass(hpartition.test);


LDA_Model = ACD_LDA_v16p1(TrnObserve,TrnClasses);

LDA_Predictions = ACD_LDA_Predict_v16p1(LDA_Model,TstObserve);

CorrectClassifications = nansum(LDA_Predictions == TstClasses);


fprintf('\nAccuracy is = %5.2f%%\n',CorrectClassifications*100/length(TstClasses));