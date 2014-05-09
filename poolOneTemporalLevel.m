function desc = poolOneTemporalLevel(scheme, pns, locs, basis, codes, ridx, cidx, fidx, ntmps)

% descriptor dimension of each spatio-temporal grid
ndims = scheme.ncenters * size(pns, 2); 

% initialize
desc = zeros(1, (scheme.nrow * scheme.ncol) * ntmps * ndims);

s = 1; e = 0;

for i = 1:ntmps
    for j = 1:scheme.nrow
        for k = 1:scheme.ncol
            % polynormal index of one spatio-temporal grid
            stidx = (locs.frms >= fidx(i)) & (locs.frms <= fidx(i + 1)) & ...
                    (locs.rows >= ridx(j)) & (locs.rows <= ridx(j + 1)) & ...
                    (locs.cols >= cidx(k)) & (locs.cols <= cidx(k + 1));
            
            % if this grid contains all-zero polynormals
            if sum(stidx) == 0
                e = e + ndims;
                s = e + 1;
                continue;
            end
                
            % polynormals, codes, and frames of one spatio-temporal grid
            stpns = pns(stidx, :);
            stcodes = codes(stidx, :);
            stfrms = locs.frms(stidx);
            
            count = 1;
            nfrms = length(unique(stfrms));
            feats = zeros(nfrms, ndims);
            
            for f = fidx(i):fidx(i + 1)
                if sum(stfrms == f) == 0
                    continue;
                end
                
                % polynormals and codes of one frame
                tpns = stpns(stfrms == f, :);
                tcodes = stcodes(stfrms == f, :);
                
                for c = 1:scheme.ncenters
                    % coefficient-weighted difference
                    buff = tpns - repmat(basis(c, :), size(tpns, 1), 1);
                    buff = buff .* repmat(tcodes(:, c), 1, size(tpns, 2));
                    buff = sum(buff);
                    
                    % spatial averaging
                    reg = (ridx(j + 1) - ridx(j) + 1) * (cidx(k + 1) - cidx(k) + 1);
                    buff = buff / reg;

                    scol = (c - 1) * size(tpns, 2) + 1;
                    ecol = c * size(tpns, 2);
                    feats(count, scol:ecol) = buff;
                end
                
                count = count + 1;
            end
            
            % remove rows corresponding to all-zero polynormal frames
            if count < nfrms
                feats(count:end, :) = [];
            end
            
            % temporal max pooling
            if nfrms > 1
                adesc = max(feats);
            else
                adesc = feats;
            end
            
            % concatenation
            e = e + ndims;
            desc(s:e) = adesc;
            s = e + 1;
        end 
    end
end

end