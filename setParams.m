function [info, scheme] = setParams

%%% data information
info.ncls = 20;
info.nsbj = 10;
info.nemp = 3;
info.train = [1, 3, 5, 7, 9];
info.test = [2, 4, 6, 8, 10];
info.vidpath = 'MSRAction3D';
info.normpath = 'normals';
info.descpath = 'descs';
info.enerpath = 'energy';

%%% descriptor parameters
% local neighbor size
scheme.lx = 3; 
scheme.ly = 3;
scheme.lt = 3;

% spatio-temporal pyramid
scheme.nrow = 4;
scheme.ncol = 3;
scheme.ntmp = 3;

% coding
scheme.code = 'SC';
scheme.ncenters = 100;

%%% external libary
addpath('LibMatlab\SPAMS');
addpath('LibMatlab\SVM');

end