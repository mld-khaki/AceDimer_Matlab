% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $

function Output = ACD_SortByStructField(X, StructField,Ascending)
% SORTstruct    Sort a struct in ascending order.
%
% Description: SORTstruct sorts the input struct according to the
%   field (columns) specified by the user.
%
% Usage: Y = SortByStructField(X, StructField)
%
% Input:
%	   X: the struct array to be sorted.
%   StructField: 
%
% Output:
%     Y: the sorted struct array.
%
% Example:    Y = sortstruct(X, [3 2])
%
% Note that this function has only been tested on mixed struct arrays
% containing character strings and numeric values.
% 
% Documentation Date: Feb.01,2007 13:36:04
% 
% Tags:
% {TAG} {TAG} {TAG}
% 
% 
%   Copyright 2007  Jeff Jackson (Ocean Sciences, DFO Canada)
%   Creation Date: Jan. 24, 2007
%   Last Updated:  Jan. 25, 2007
%   Last Updated and revised by Milad Khaki : 2021-05-07

% Check to see if no input arguments were supplied.  If this is the case,
% stop execution and output an error message to the user.
if nargin == 1
	error('No input arguments were supplied.  At least one is expected.');
% Check to see if the only input argument is a struct array.  If it isn't
% then stop execution and output an error message to the user. Also set the
% DIM value since it was not supplied.
elseif nargin == 2
	if ~isstruct(X)
		error('Input argument is not a struct array.  A struct array is expected.');
	end
% Check to see if the first input argument is a struct array and the second
% one is numeric.  If either check fails then stop execution and output an
% error message to the user.
elseif nargin == 3
	if ~isstruct(X)
		error('The first input argument is not a struct array.  A struct array is expected.');
	end
	if ~ischar(StructField)
		error('The second input argument is not character array. ');
	end
% Check to see if too many arguments were input.  If there were then exit
% the function issuing a error message to the user.
elseif nargin > 3
	error('Too many input arguments supplied.  Only two are allowed.');
end

DirectionStr = 'ascend';
if nargin <= 2
    Ascending = 1;
end

if Ascending == -1
    DirectionStr = 'descend';
end
% Place the structs for this field in table variable 'B'.

BTable = struct2table(X);
B = eval(['BTable.' StructField]);



% Sort the current array and return the new index.
[vals,ix] = sort(B,DirectionStr);

% Using the index from the sorted array, update the input struct array and
% return it.
X = X(ix);
Output = X;
