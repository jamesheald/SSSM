function [xp,Vp,xf,Vf,cL] = KF(A,Q,C,R,y,q,Channel,nC,nS,t,xprev,Vprev)
% Bank of Kalman filters

if t == 1
  xp = xprev;
  Vp = Vprev;
else
  xp = A*xprev;                         % predict state
  Vp = A*Vprev*A' + Q;                  % update state covariance matrix
end

% prediction error
if Channel(t,s)
    e = zeros(nC,1);
else
    e = y(s,q(t),t) - C*xp;
end

% update state estimate
S = diag(C*Vp*C') + R; % innovation covariance
K = (Vp*C')./S';       % Kalman gain
xf = xp + K.*e';

% update state covariance matrix
InS = eye(nS);
Vf = zeros(nS,nS,nC);
for c = 1:nC
    Vf(:,:,c) = (InS - K(:,c)*C(c,:))*Vp;
end
xp = repmat(xp,1,nC);

% context log likelihood
cL = log(1./sqrt(2*pi*S)) - 0.5*(e./sqrt(S)).^2;
