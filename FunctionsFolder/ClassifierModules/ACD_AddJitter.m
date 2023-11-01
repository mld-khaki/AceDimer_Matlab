% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_AddJitter_v16p0(FeaturesStruct,InputObs,JitterPercentage,JitterProbability)
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
