function compVidDesc(info, scheme)

basisName = [scheme.code, '_', num2str(scheme.ncenters), '_', ...
             num2str(scheme.lx), num2str(scheme.ly), num2str(scheme.lt), '.mat'];
load(basisName, 'basis');

for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    
    for j = 1:info.nsbj
        idxsbj = sprintf('s%02d', j);

        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k);
            disp(['computing video descriptor: ', idxcls, '_', idxsbj, '_', idxemp, ' ......']);
            
            % read normals and masks
            normalName = [info.normpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_norm.mat'];
            
            % some missed videos
            if ~exist(normalName, 'file')
                continue;
            end
            
            load(normalName, 'dx', 'dy', 'dt', 'masks');           
            [pns, rows, cols, frms] = getPolyNormals(dx, dy, dt, scheme.lx, scheme.ly, scheme.lt);
            clear dx dy dt;
            
            % remove all-zero polynormals
            flag = sum(pns ~= 0, 2);
            pns(~flag, :) = [];
            rows(~flag) = []; cols(~flag) = []; frms(~flag) = [];
            
            locs.rows = rows; locs.cols = cols; locs.frms = frms;
            clear rows cols frms;
            
            % whitening
            if strcmp(scheme.code, 'SC')
                pns = pns';
                pns = pns - repmat(mean(pns), size(pns, 1), 1); % zero-mean
                pns = pns ./ (repmat(sqrt(sum(pns.^2)), size(pns, 1), 1) + eps); % unit-variance
                pns = pns';
            end
            
            % coding polynormals
            codes = codePolyNormals(scheme, pns, basis);
            
            % determine the max bounding box of action region
            bb = getBoundBox(masks);
            
            % load motion energy
            energyName = [info.enerpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_ener.mat'];
            load(energyName, 'hist');
            
            % pooling polynormals
            desc = poolPolyNormals(scheme, pns, locs, basis, codes, bb, hist);
            
            % save
            descName = [info.descpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_desc.mat'];
            save(descName, 'desc');
        end
    end
end

end