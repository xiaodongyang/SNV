function basis = learnPolyNormalBasis(scheme, feats)

switch scheme.code
    % by sparse coding
    case 'SC'
        disp('learning polynormal dictionary by sparse coding ......');
               
        % whitening
        feats = feats';
        feats = feats - repmat(mean(feats), size(feats, 1), 1); % zero-mean
        feats = feats ./ (repmat(sqrt(sum(feats.^2)), size(feats, 1), 1) + eps); % unit-variance
        
        % parameters
        param.iter = 1000; % number of iterations
        param.K = scheme.ncenters; % codebook size
        param.lambda = 0.15; % spasity-inducing regualarizer
        
        basis = mexTrainDL_Memory(feats, param);
end

end