function I = SSSM(A,Q,C,R,Phi0,eta,y,x0,V0,q,Channel,nC,nS,nT,nQ)
    
% predicted state estimate
I.xp = zeros(nS,nC,nT);
I.Vp = zeros(nS,nS,nT);

% filtered state estimate
I.xf = zeros(nS,nC,nT);
I.Vf = zeros(nS,nS,nC,nT);

% moment matched state estimate
I.xm = zeros(nS,nT);
I.Vm = zeros(nS,nS,nT);

% prior context probability
I.cPre = zeros(nQ,nC,nT);

% context log likelihood
I.cL = zeros(nC,nT);

% posterior context probability
I.cPost = zeros(nC,nT);

% predicted observation
I.yp = NaN(nQ,nT);

% sufficient statistics
I.S = zeros(nC,nC,nQ,nT);

% parameter estimate
I.Phi = zeros(nQ,nC,nT);

for t = 1:nT
    if t == 1
        xprev = x0;
        Vprev = V0;
        Phi(:,:,1) = Phi0;
    else
        xprev = xm(:,t-1);
        Vprev = Vm(:,:,t-1);
    end
    [I.xp(:,:,t),I.Vp(:,:,t),I.xf(:,:,t),I.Vf(:,:,:,t),I.cL(:,t)] = KF(A,Q,C,R,y,q,Channel,nC,nS,t,xprev,Vprev);
    [I.cPost(:,t),I.xm(:,t),I.Vm(:,:,t),I.yp(q(t,s),t)] = ADF(C,I.Phi,nC,nS,q,I.cL,t,I.xf,I.xp,I.Vf);
    [I.S,I.Phi] = EM(I.S,I.Phi,I.cPost,nC,nQ,q(t,s),eta,t);
end
