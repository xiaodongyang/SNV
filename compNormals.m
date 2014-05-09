function compNormals(info)

for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    
    for j = 1:info.nsbj
        idxsbj = sprintf('s%02d', j);
        
        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k);
            
            disp(['computing normals of video: ', idxcls, '_', idxsbj, '_', idxemp, ' ......']);
            
            % read depth sequences from a binary file
            vidName = [info.vidpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_sdepth.bin'];
            depth = readDepthBin(vidName);

            % some missed videos
            if isempty(depth)
                continue;
            end
            
            % compute derivatives of depth sequence
            [nrows, ncols, nfrms] = size(depth);
            dx = zeros(nrows, ncols, nfrms - 1);
            dy = zeros(nrows, ncols, nfrms - 1);
            dt = zeros(nrows, ncols, nfrms - 1);
            
            for f = 1:nfrms-1
                % smooth
                frame1 = medfilt2(depth(:, :, f), [5, 5]);
                frame2 = medfilt2(depth(:, :, f + 1), [5, 5]);
                
                % derivatives along x/y/t
                [dx(:, :, f), dy(:, :, f)] = gradient(frame1);
                dt(:, :, f) = frame2 - frame1;
            
                % normalize
                reg = sqrt(dx(:, :, f).^2 + dy(:, :, f).^2 + dt(:, :, f).^2);
                dx(:, :, f) = dx(:, :, f) ./ reg;
                dy(:, :, f) = dy(:, :, f) ./ reg;
                dt(:, :, f) = dt(:, :, f) ./ reg;
                
                dx(isinf(dx)) = 0; dx(isnan(dx)) = 0;
                dy(isinf(dy)) = 0; dy(isnan(dy)) = 0;
                dt(isinf(dt)) = 0; dt(isnan(dt)) = 0;
            end

            % to mask cloud points belonging to human body
            masks = logical(depth);
            masks(:, :, end) = [];
            
            % save normals and masks
            normalName = [info.normpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_norm.mat'];
            save(normalName, 'dx', 'dy', 'dt', 'masks');
        end
    end
end

end