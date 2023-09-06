function [B]   =  SVD_shrink(I, X, svdMethod, opts )

rank_B = opts.rank_B;

for iter = 1:opts.Innerloop_B
%% B-subproblem
    [U, S, V] = svds(I- X, rank_B+1, 'L');
    diagS = diag(S);

    temp    = (diagS-opts.tau/opts.delta).*double( (diagS-opts.tau/opts.delta) > 0 );
    B       = U * diag(temp) * V';
end
