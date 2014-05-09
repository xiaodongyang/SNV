function codes = codePolyNormals(scheme, pns, basis)

switch scheme.code
    case 'SC'
        % parameters
        param.lambda = 0.15; % spasity-inducing regualarizer
        param.pos = 1; % non-negativity constraints on coefficients
        
        % lasso
        codes = mexLasso(pns', basis', param);
        codes = full(codes)';
end

end