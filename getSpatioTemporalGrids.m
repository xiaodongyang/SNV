function [ridx, cidx, fidx] = getSpatioTemporalGrids(bb, hist, scheme)

nrow = bb.rmax - bb.rmin + 1;
ncol = bb.cmax - bb.cmin + 1;

% row ranges of spatial grids
ridx = bb.rmin;
rstep = nrow / scheme.nrow;

for i = 1:(scheme.nrow - 1)
    ridx = [ridx, bb.rmin + round(i * rstep)];
end

ridx = [ridx, bb.rmax];

% column ranges of spatial grids
cidx = bb.cmin;
cstep = ncol / scheme.ncol;

for i = 1:(scheme.ncol - 1)
    cidx = [cidx, bb.cmin + round(i * cstep)];
end

cidx = [cidx, bb.cmax];

% frame ranges of adaptive temporal pyramids grids
fidx = cell(scheme.ntmp, 1);

% normalized accumulated motion energy
energy = cumsum(hist / sum(hist));

for i = 1:scheme.ntmp
    nbins = 2 ^ (i - 1);
    fstep = 1 / nbins;
    buff = 1;
    
    for j = 1:nbins
        % index of the element that is the most closed to (j * fstep)  
        [~, frm] = min(abs(energy - j * fstep));
        buff = [buff, frm];
    end
    
    fidx{i} = buff;
end

end