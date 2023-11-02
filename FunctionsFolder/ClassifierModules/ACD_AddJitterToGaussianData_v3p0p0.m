% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_AddJitterToGaussianData_v3p0p0(Fold,InputObs,JitterPercentage,JitterWeight)
EntireFeatures = 1:length(InputObs);

SelectedFeatures = EntireFeatures(randperm(length(EntireFeatures)));
SelectedFeatures = SelectedFeatures(1:floor(JitterPercentage*100/length(EntireFeatures)));

DataSample = zeros(length(Fold.ObservationValuess),length(Fold.ObservationValuess{1}));
for iCtr=1:length(Fold.ObservationValuess)
DataSample(iCtr,:) = Fold.ObservationValuess{iCtr};
end

DataSTD = nanstd(DataSample,1);
DataAVG = nanmean(DataSample,1);
Noise = randn(size(InputObs)).* DataSTD + DataAVG;
% Out = InputObs + JitterWeight * Noise;
Vec1 = 1:ceil(randi(length(InputObs)));
Vec2 = length(Vec1)+1:length(InputObs);
Out = InputObs;
Out(Vec2) = Fold.ObservationValuess{randi(end)}(Vec2);
end
