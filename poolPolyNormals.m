function desc = poolPolyNormals(scheme, pns, locs, basis, codes, bb, hist)

% get row, column, and frame ranges of spatio-temporal grids
[ridx, cidx, fidx] = getSpatioTemporalGrids(bb, hist, scheme);

% normalization
if strcmp(scheme.code, 'SC')
    reg = sum(codes, 2);
    flag = reg == 0;
    
    % remove zero regularizations
    if sum(flag) > 0
        reg(flag) = [];
        pns(flag, :) = []; 
        codes(flag, :) = [];
        locs.rows(flag) = []; locs.cols(flag) = []; locs.frms(flag) = [];
    end
    
    % ell-1 norm
    reg = repmat(reg, 1, size(codes, 2));
    codes = codes ./ reg;
    
    % descriptor dimension of each spatio-temporal grid
    ndims = size(basis, 1) * size(pns, 2);
    
    % initialize
    desc = zeros(1, (scheme.nrow * scheme.ncol * (2^scheme.ntmp - 1)) * ndims);
end

s = 1; e = 0;

for i = 1:scheme.ntmp
    % number of temporal grids in the ith temporal level
    nTmpGrids = 2 ^ (i - 1);
    
    % descriptors from the ith temporal level
    idesc = poolOneTemporalLevel(scheme, pns, locs, basis, codes, ridx, cidx, fidx{i}, nTmpGrids);
    
    % concatenate descriptors
    e = e + length(idesc);
    desc(s:e) = idesc;
    s = e + 1;
end

end