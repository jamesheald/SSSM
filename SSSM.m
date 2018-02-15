function Inference = SSSM(A,Q,C,R,Phi0,eta,y,x0,V0,q,Channel,nC,nS,nT,nQ,Subj)

Inference = cell(1,nS);

for s = Subj(:)'
    
    % predicted state estimate
    xp = zeros(nS,nC,nT);
    Vp = zeros(nS,nS,nT);
    
    % filtered state estimate
    xf = zeros(nS,nC,nT);
    Vf = zeros(nS,nS,nC,nT);
    
    % moment matched state estimate
    xm = zeros(nS,nT);
    Vm = zeros(nS,nS,nT);
    
    % prior context probability
    cPre = zeros(nQ,nC,nT);
    
    % context log likelihood
    cL = zeros(nC,nT);
    
    % posterior context probability
    cPost = zeros(nC,nT);
    
    % predicted observation
    yp = NaN(nQ,nT);
    
    % sufficient statistics
    S = zeros(nC,nC,nQ,nT);
    
    % parameter estimate
    Phi = zeros(nQ,nC,nT);

    for t = 1:nT
        if t == 1
            xprev = x0;
            Vprev = V0;
            Phi(:,:,1) = Phi0;
        else
            xprev = xm(:,t-1);
            Vprev = Vm(:,:,t-1);
        end
        [xp(:,:,t),Vp(:,:,t),xf(:,:,t),Vf(:,:,:,t),cL(:,t)] = KF(A,Q,C,R,y,q,Channel,nC,nS,t,xprev,Vprev,s);
        [cPost(:,t),xm(:,t),Vm(:,:,t),yp(q(t,s),t)] = MM(C,Phi,nC,nS,q,cL,t,xf,xp,Vf,s);
        [S,Phi] = EM(S,Phi,cPost,nC,nQ,q(t,s),eta,t);
    end

    Inference{s}.xp = xp;
    Inference{s}.Vp = Vp;
    Inference{s}.xf = xf;
    Inference{s}.Vf = Vf;
    Inference{s}.xm = xm;
    Inference{s}.Vm = Vm;
    
    Inference{s}.cPre = cPre;
    Inference{s}.cL = cL;
    Inference{s}.cPost = cPost;
    
    Inference{s}.yp = yp;
    
    Inference{s}.S = S;
    Inference{s}.Phi = Phi;
    
end
