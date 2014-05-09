function depth = readDepthBin(fileName)

fp = fopen(fileName, 'rb');

if fp < 0
    depth = [];
    return;
end

header = fread(fp, 3, 'int32');
nfrms = header(1); 
ncols = header(2); 
nrows = header(3);

depth = zeros(nrows, ncols, nfrms);

for i = 1:nfrms
    temp = fread(fp, [ncols, nrows], 'int32');
    depth(:, :, i) = temp';
end

fclose(fp);

end