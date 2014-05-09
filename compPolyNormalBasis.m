function compPolyNormalBasis(info, scheme)

%%% get polynormals for learning basis

% allocate a large matrix to hold normals
ndim = 3 * scheme.lx * scheme.ly * scheme.lt;
feats = zeros(5E6, ndim);

% cloud point sampling rate
rate = 0.055;

% sample polynormals 
s = 1; e = 0;

for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    disp(['sampling normals from class: ', idxcls, ' ......']);
    
    for j = 1:length(info.train)
        idxsbj = sprintf('s%02d', j);
        
        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k);
            
            % read normals and masks
            normalName = [info.normpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_norm.mat'];
            
            % some missed videos
            if ~exist(normalName, 'file')
                continue;
            end
            
            load(normalName, 'dx', 'dy', 'dt');
            [pns, ~, ~, ~] = getPolyNormals(dx, dy, dt, scheme.lx, scheme.ly, scheme.lt);
            
            % remove all-zero polynormals
            flag = sum(pns ~= 0, 2);
            pns(~flag, :) = [];
            
            % randomly select a subset
            idxrand = randperm(size(pns, 1));
            idxrand = idxrand(1:round(length(idxrand) * rate));
            pns = pns(idxrand, :);
            
            % fill in
            e = e + size(pns, 1);
            feats(s:e, :) = pns;
            s = e + 1;
        end
    end
end

feats(s:end, :) = [];
disp(['number of polynormals: ', num2str(size(feats, 1))]);

%%% learn polynormal basis

basis = learnPolyNormalBasis(scheme, feats);
basis = basis';

basisName = [scheme.code, '_', num2str(scheme.ncenters), '_', ...
             num2str(scheme.lx), num2str(scheme.ly), num2str(scheme.lt), '.mat'];
save(basisName, 'basis');

end