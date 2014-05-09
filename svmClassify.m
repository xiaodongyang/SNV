function svmClassify(info, scheme)

% initialize 
load([info.descpath, '\a01_s01_e01_desc.mat'], 'desc');
ndims = length(desc);
nsamples = 300;

featTrain = zeros(nsamples, ndims);
featTest = zeros(nsamples, ndims);
tarTrain = zeros(nsamples, 1);
tarTest = zeros(nsamples, 1);

% prepare training and testing data
itrain = 1;
itest = 1;

for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    
    for j = 1:info.nsbj
        idxsbj = sprintf('s%02d', j);
        
        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k);
            
            % load video descriptor
            descName = [info.descpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_desc.mat'];
            
            if ~exist(descName, 'file')
                continue;
            end
            
            load(descName, 'desc');
            
            % fill in
            if ismember(j, info.train)
                featTrain(itrain, :) = desc;
                tarTrain(itrain) = i;
                itrain = itrain + 1;
            else
                featTest(itest, :) = desc;
                tarTest(itest) = i;
                itest = itest + 1;
            end
        end
    end
end

% remove extra rows
featTrain(itrain:end, :) = [];
tarTrain(itrain:end) = [];
featTest(itest:end, :) = [];
tarTest(itest:end) = [];

% scale data
[featTrainScale, matScale] = scaleData(featTrain, 0, 1);
clear featTrain;

featTestScale = scaleData(featTest, 0, 1, matScale);
clear featTest;

% weighting
unit = size(featTrainScale, 2) / 7;

featTrainScale(:, 1:unit) = featTrainScale(:, 1:unit) * 4;
featTrainScale(:, unit + 1:3 * unit) = featTrainScale(:, unit + 1:3 * unit) * 3;

featTestScale(:, 1:unit) = featTestScale(:, 1:unit) * 4;
featTestScale(:, unit + 1:3 * unit) = featTestScale(:, unit + 1:3 * unit) * 3;

% liblinear training
model = train(tarTrain, sparse(featTrainScale));

% liblinear testing
[label, rate, score] = predict(tarTest, sparse(featTestScale), model);

% save prediction result
predName = [scheme.code, '_', num2str(scheme.ncenters), '_', num2str(scheme.lx),...
            num2str(scheme.ly), num2str(scheme.lt), '_PRED.mat'];
save(predName, 'matScale', 'model', 'tarTest', 'label', 'rate', 'score');

end