function bb = getBoundBox(masks)

rmax = 0;
rmin = size(masks, 1);
cmax = 0;
cmin = size(masks, 2);

nfrms = size(masks, 3);

for i = 1:nfrms
    bw = regionprops(masks(:, :, i), 'BoundingBox');
    
    % merge multiple bounding boxes
    if length(bw) > 1
        rmaxbw = 0;
        rminbw = size(masks, 1);
        cmaxbw = 0;
        cminbw = size(masks, 2);
        
        for j = 1:length(bw)
            cminbw = min(cminbw, round(bw(j).BoundingBox(1)));
            cmaxbw = max(cmaxbw, round(bw(j).BoundingBox(1) + bw(j).BoundingBox(3)));
            rminbw = min(rminbw, round(bw(j).BoundingBox(2)));
            rmaxbw = max(rmaxbw, round(bw(j).BoundingBox(2) + bw(j).BoundingBox(4)));
        end
        
        bw = [];
        bw.BoundingBox = [cminbw, rminbw, cmaxbw - cminbw, rmaxbw - rminbw];
    end
    
    cmin = min(cmin, round(bw.BoundingBox(1)));
    cmax = max(cmax, round(bw.BoundingBox(1) + bw.BoundingBox(3)));
    rmin = min(rmin, round(bw.BoundingBox(2)));
    rmax = max(rmax, round(bw.BoundingBox(2) + bw.BoundingBox(4)));
end

% round in
rmin = max(1, rmin);
rmax = min(size(masks, 1), rmax);
cmin = max(1, cmin);
cmax = min(size(masks, 2), cmax);

bb.rmin = rmin;
bb.rmax = rmax;
bb.cmin = cmin;
bb.cmax = cmax;

end