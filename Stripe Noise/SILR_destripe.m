function [U,D1] = SILR_destripe(I,opts)

%% initialization
[m,n] = size(I);
U = I;
S  = zeros(m,n);
D1 = zeros(m,n);
D2 = zeros(m,n);
D3 = zeros(m,n);
J1 = zeros(m,n);
J2 = zeros(m,n);
J3 = zeros(m,n);
[conjoDx,conjoDy,Denom1,Denom2] = getC(I);
tol = 1.e-6;

%% main
for iter = 1:opts.MaxIter
    
    nrmUS = norm([U,S],'fro');

    %% S - subproblem
    Fs = ( fft2( I - U ) + opts.delta*fft2(D1-J1/opts.delta) )./( 1 + opts.delta ) ; 
    dS = S;
    S = real( ifft2( Fs ) ); % compute new S
    dS = S - dS;
    
    %% D1 - subproblem
    [D1]   =  SVD_shrink(S, -J1/opts.delta, 'svds', opts );
    
    %% U - subproblem
    Denom = opts.belta*Denom2 + opts.gamma*Denom1 + 1 ;
    Fu = ( fft2( I - S ) + opts.belta*conjoDy.*fft2(D2) - conjoDy.*fft2(J2) + opts.gamma*conjoDx.*fft2(D3) - conjoDx.*fft2(J3))./Denom ; 
    dU = U;
    U = real( ifft2( Fu ) ); % compute new U
    dU = U - dU;
    
    %% D2 and D3 - subproblem
    temp2 = diff(U,1,1);          % row diff
    dy = [temp2; temp2(m-1,:)];   
    D2 = soft_shrink(dy + J2/opts.belta,opts.lamda2/opts.belta);
    
    temp3 = diff(U,1,2);          % colomn diff
    dx = [temp3 temp3(:,n-1)];   
    D3 = soft_shrink(dx + J3/opts.gamma,opts.lamda3/opts.gamma);

    %% Update J1 J2 J3
    J1 = J1 - opts.delta * (D1 - S);
    J2 = J2 - opts.belta * (D2 - dy);
    J3 = J3 - opts.gamma * (D3 - dx);
    
    opts.delta = opts.delta*1.02;
    opts.belta = opts.belta*1.02;
    opts.gamma = opts.gamma*1.02;

    %% stopping criterion
    RelChg = norm([dU,dS],'fro') / (1 + nrmUS);
    if RelChg < tol, break; end
    out.exit = 'Stopped by RelChg < tol';
    if iter == opts.MaxIter, out.exit = 'Maximum iteration reached'; end
end

function [conjoDx,conjoDy,Denom1,Denom2] = getC(f)
% compute fixed quantities
sizeI = size(f);
otfDx = psf2otf([1,-1],sizeI);
otfDy = psf2otf([1;-1],sizeI);
conjoDx = conj(otfDx);
conjoDy = conj(otfDy);
Denom1 = abs(otfDx).^2;
Denom2 = abs(otfDy).^2;
