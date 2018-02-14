load Experiment2_Trials

Subj = [1:8; ...                        % same-field participants
        9:16];                          % opposing-field participants

nT   = 540;                             % total number of trials
expT = 33:440;                          % exposure trials
nQ   = 2;                               % number of contextual cues
nC   = 2;                               % number of contexts
nSC  = 2;                               % number of continuous hidden states per context
nS   = nC*nSC;                          % total number of continuous hidden states

% SSSM model parameters
A = diag(repmat([0.9946 0.9404],1,nC)); % continuous state transition matrix
Q = diag(repmat([0.0003 0.0068],1,nC)); % process noise matrix
C = repelem(eye(nC),1,nSC);             % observation vectors (one for each context)
R = 0.0792;                             % observation noise

% EM step size
alpha = 0.6067;
eta = alpha./(alpha+(1:nT)-1);

% initial state estimate and state uncertainty
x0 = zeros(nS,1);
ric1 = dare(A,[1 1 0 0]',Q,R);
ric2 = dare(A,[0 0 1 1]',Q,R);
V0 = (ric1+ric2)/2; 

% initial estimate of cue emission probabilities
phi0 = 0.5+1e-6;
Phi0 = toeplitz([phi0 1-phi0]);

% noiesless observations
y = zeros(16,nQ,nT);
y(:,1,expT) = 1;
y(1:8,2,expT) = 1;
y(9:16,2,expT) = -1;

Inference = SSSM(A,Q,C,R,Phi0,eta,y,x0,V0,q,Channel,nC,nS,nT,nQ,Subj);

%% Figures

% same-field example participant
figure
plot(Inference{1}.yp(1,:))
hold on
plot(Inference{1}.yp(2,:))

% opposing-field example participant
figure
plot(Inference{16}.yp(1,:))
hold on
plot(-Inference{16}.yp(2,:))

% cue emission probabilities
figure
plot(squeeze(Inference{16}.Phi(1,1,:)))
hold on
plot(squeeze(Inference{16}.Phi(2,1,:)))


