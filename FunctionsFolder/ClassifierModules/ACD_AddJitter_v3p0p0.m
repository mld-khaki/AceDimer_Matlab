% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_AddJitter_v3p0p0(FeaturesStruct,InputObs,JitterPercentage,JitterProbability)
EntireFeatures = 1:length(InputObs);

SelectedFeatures = EntireFeatures(randperm(length(EntireFeatures)));
SelectedFeatures = SelectedFeatures(1:floor(JitterPercentage*100/length(EntireFeatures)));

for iCtr=SelectedFeatures
    assert(isfield(FeaturesStruct(iCtr),'Type')==true);

    if rand <= JitterProbability
        switch FeaturesStruct(iCtr).Type
            case 'double'
            case 'categorical'
            case 'binary'
                InputObs(iCtr) = ~InputObs(iCtr);
        end
    end
end

Out = InputObs;
end
