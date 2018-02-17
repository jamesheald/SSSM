function [cPost,xm,Vm,yp] = MM(C,Phi,nC,nS,q,cLy,t,xf,xp,V,s)
% Merge histories by moment matching (assumed density filtering)
% INPUTS:
% C     - observation vectors
% cLy   - context log likelihood
% cJ    - joint probability of observation and context
% xf     - state estimate
% V     - state covariance matrix
% OUTPUTS:
% cPost - context posterior probability
% xm    - moment matched state estimate
% Vm    - moment matched state covariance matrix

% Using log-sum-exp trick to avoid numerical underflow when Bayes' rule
Jcq = Phi(q(t,s),:,t);
cPre = Jcq/sum(Jcq);
num = cLy(:,t) + log(cPre)';
denom = max(num) + log(sum(exp(num - max(num))));
cPost = exp(num - denom);

% Approximate mixture of Gaussians with a single Gaussian
% Minimise KL divergence between p and q by matching moments
xm = xf(:,:,t)*cPost;
err = xf(:,:,t) - repmat(xm,1,nC);
Vm = zeros(nS,nS);
for c = 1:nC
    Vm = Vm + (V(:,:,c,t) + err(:,c)*err(:,c)')*cPost(c);
end
% Vm = sum((V(:,:,:,t) + repmat(reshape(err,[1,nS,nC]),[nS,1,1]).*repmat(reshape(err,[nS,1,nC]),[1,nS,1])).*permute(repmat(cPost,1,nS,nS),[3,2,1]),3);

% Predict observation
yp = sum(dot(C',xp(:,:,t)).*cPre);

