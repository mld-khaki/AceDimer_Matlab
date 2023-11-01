% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function LDA_Model = ACD_LDA_v16p1(Input,Target,Priors)
% AceDimer Toolbox v16.0
% ACD_LDA - MATLAB function to perform linear discriminant analysis
% implemented by Milad Khaki
%
% Usage:
%       LDA_Model = ACD_LDA(Input,Target,Priors)
%
% LDA_Model = discovered linear coefficients (first column is the constants)
% Input     = predictor data (variables in columns, observations in rows)
% Target    = target variable (class labels)
% Priors    = vector of prior probabilities (optional)
%
% Note: discriminant coefficients are stored in LDA_Model in the order of unique(Target)
%
% Example:
%
%       % Generate example data: 2 groups, of 10 and 15, respectively
%       X = [randn(10,2); randn(15,2) + 1.5];  Y = [zeros(10,1); ones(15,1)];
%
%       % Calculate linear discriminant coefficients
%       LDA_Model = ACD_LDA(X,Y);
%
%       % Calculate linear scores for training data
%       L = [ones(25,1) X] * W';
%
%       % Calculate class probabilities
%       P = exp(L) ./ repmat(sum(exp(L),2),[1 2]);
%
% Last modification date: April 4, 2021

persistent PooledCov
% Determine size of input data
[n, m] = size(Input);

% Discover and count unique class labels
ClassLabel = unique(Target);
ObservationCount = length(ClassLabel);

% Initialize
nGroup     = NaN(ObservationCount,1);     % Group counts
GroupMean  = NaN(ObservationCount,m);     % Group sample means
LDA_Model  = struct;
LDA_Model.Weights = NaN(ObservationCount,m+1);   % model coefficients
LDA_Model.ClassLabels = ClassLabel;

if isempty(PooledCov) || ~isequal(size(PooledCov),[m m])
    PooledCov  = zeros(m,m);   % Pooled covariance
else
    PooledCov(1:m,1:m) = 0;
end

if  (nargin >= 3)
    PriorProb = Priors;
end

% Loop over classes to perform intermediate calculations
for iCtr = 1:ObservationCount
    % Establish location and size of each class
    Group      = (Target == ClassLabel(iCtr));
    nGroup(iCtr)  = sum(double(Group));
    
    % Calculate group mean vectors
    GroupMean(iCtr,:) = mean(Input(Group,:));
    
    % Accumulate pooled covariance information
    PooledCov = PooledCov + ((nGroup(iCtr) - 1) / (n - ObservationCount) ).* cov(Input(Group,:));
end

% Assign prior probabilities
if  (nargin >= 3)
    % Use the user-supplied priors
    PriorProb = Priors;
else
    % Use the sample probabilities
    PriorProb = nGroup / n;
end

% Loop over classes to calculate linear discriminant coefficients
PooledCov(isnan(PooledCov)) = 0;
PooledCovI = pinv(PooledCov);

for iCtr = 1:ObservationCount
    % Intermediate calculation for efficiency
    % This replaces:  GroupMean(g,:) * inv(PooledCov)
    %     Temp = GroupMean(iCtr,:) / PooledCov;
    Temp = GroupMean(iCtr,:) * PooledCovI;
    % Constant
    LDA_Model.Weights(iCtr,1) = -0.5 * Temp * GroupMean(iCtr,:)' + log(PriorProb(iCtr));
    
    % Linear
    LDA_Model.Weights(iCtr,2:end) = Temp;
end

end


