function [S,Phi] = EM(S,Phi,cPost,nC,nQ,CueT,eta,t)
% Online EM

% E-step
s         = zeros(nQ,nC);
s(CueT,:) = cPost(:,t)';
if t == 1
    S(:,:,t) = eta(t)*s;
else
    S(:,:,t) = (1-eta(t))*S(:,:,t-1) + eta(t)*s;
end

% M-step
if t > 7
    Phi(:,:,t+1) = S(:,:,t)./repmat(sum(S(:,:,t)),nQ,1);
else
    Phi(:,:,t+1) = Phi(:,:,t);
end
