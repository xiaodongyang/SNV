close all; clear; clc;

% set parameters
[info, scheme] = setParams;

% compute normals
compNormals(info);

% compute normal basis (dictionary)
compPolyNormalBasis(info, scheme);

% compute descriptors of video sequences
compVidDesc(info, scheme);

% training and testing
svmClassify(info, scheme);