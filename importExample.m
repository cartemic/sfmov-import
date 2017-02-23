clear
close all
clc

% Get names of files using fNameGet().
fNames=fNameGet();

% Extract data and frame rate using sfmovImport() for each filename.
% sfmovImport() accepts a single cell input containing the filename,
% without any filetype extension. For example, to import 'data1.sfmov'
% without using fNameGet, one might use the code:
%   fName = {'data1'};
%   dataIn = sfmovImport(fName);
for i=1:length(fNames)
    [dataIn fps] = sfmovImport(fNames(i));
end