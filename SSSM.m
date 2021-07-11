classdef SSSM < matlab.mixin.Copyable
    
    properties
        
        % model parameters - values taken from Heald et al. Nature human behaviour (2018) Table S2
        retention_fast = 0.9404;
        retention_slow = 0.9946;
        process_noise_variance_fast = 0.0068;
        process_noise_variance_slow = 0.0003;
        observation_noise_variance = 0.0792;
        EM_step_size_parameter = 0.6067;

        % number of contexts
        nC = 2;
        
        % vector of perturbations (NaN on channel trials)
        perturbations
        
        % vector of sensory cues (encode cues using integers starting from 1)
        cues
        
        % user data
        user_data

    end

    methods
        
        function D = simulate_SSSM(obj)
            
            % initialise the model
            D = obj.initialise_SSSM;
            
            % main loop
            D = main_loop(obj,D);
            
        end
        
        function D = initialise_SSSM(obj)
            
            % number of continuous hidden states per context
            D.nSC = 2;
            
            % total number of continuous hidden states
            D.nS = D.nSC*obj.nC;
            
            % number of trials
            D.T = numel(obj.perturbations);
            
            % number of contextual cues
            D.nQ = 2;
            
            % state dynamics matrix
            D.A = diag(repmat([obj.retention_slow obj.retention_fast],1,obj.nC));
            
            % process noise covariance matrix
            D.Q = diag(repmat([obj.process_noise_variance_slow obj.process_noise_variance_fast],1,obj.nC));
            
            % observation vectors (one for each context)
            D.C = repelem(eye(obj.nC),1,D.nSC);
            
            % EM step size time series
            D.eta = obj.EM_step_size_parameter./(obj.EM_step_size_parameter+(1:D.T)-1);

            % predicted state estimate
            D.xPred = zeros(D.nS,obj.nC,D.T);
            
            % predicted state covariance matrix
            D.vPred = zeros(D.nS,D.nS,D.T);

            % filtered state estimate
            D.xFilt = zeros(D.nS,obj.nC,D.T);
            
            % filtered state covariance matrix
            D.vFilt = zeros(D.nS,D.nS,obj.nC,D.T);

            % moment matched state estimate
            D.xMerged = zeros(D.nS,D.T);
            
            % moment matched state covariance matrix
            D.vMerged = zeros(D.nS,D.nS,D.T);

            % context log likelihood
            D.cLogLike = zeros(obj.nC,D.T);

            % posterior context probability
            D.cPost = zeros(obj.nC,D.T);

            % net predicted perturbation
            D.xHat = zeros(1,D.T);

            % sufficient statistics
            D.S = zeros(obj.nC,obj.nC,D.nQ,D.T);

            % estimate of the context-specific cue emission probabilities
            D.Phi = zeros(D.nQ,obj.nC,D.T);
            
        end
            
        function D = main_loop(obj,D)
                
            for trial = 1:D.T
                
                D.t = trial;
                
                D = KF(obj,D);   % run a bank of Kalman filters
                D = GPB1(obj,D); % GBP1 algorithm (merge histories by moment matching)
                D = EM(obj,D);   % online EM
                
            end
            
        end
        
        function D = KF(obj,D)
            
            if D.t == 1

                % initial state estimate and state uncertainty
                xp = zeros(D.nS,1);
                r1 = dare(D.A,[1 1 0 0]',D.Q,obj.observation_noise_variance);
                r2 = dare(D.A,[0 0 1 1]',D.Q,obj.observation_noise_variance);
                D.vPred(:,:,D.t) = (r1+r2)/2;
                
                % initial estimate of cue emission probabilities
                phi0 = 0.5 + 1e-6;
                D.Phi(:,:,1) = toeplitz([phi0 1-phi0]);
                
            else
                
                % propagate state estimate
                xp = D.A*D.xMerged(:,D.t-1);
                
                % propagate state covariance matrix
                D.vPred(:,:,D.t) = D.A*D.vMerged(:,:,D.t-1)*D.A' + D.Q;
                
            end

            % perturbation prediction error
            if isnan(obj.perturbations(D.t))
                e = zeros(obj.nC,1);
            else
                e = obj.perturbations(D.t) - D.C*xp;
            end

            % update state estimate
            S = diag(D.C*D.vPred(:,:,D.t)*D.C') + obj.observation_noise_variance;
            K = (D.vPred(:,:,D.t)*D.C')./S';
            D.xFilt(:,:,D.t) = xp + K.*e';
            D.xPred(:,:,D.t) = repmat(xp,1,obj.nC);

            % update state covariance matrix
            InS = eye(D.nS);
            for c = 1:obj.nC
                D.vFilt(:,:,c,D.t) = (InS - K(:,c)*D.C(c,:))*D.vPred(:,:,D.t);
            end

            % context log likelihood
            D.cLogLike(:,D.t) = log(1./sqrt(2*pi*S)) - 0.5*(e./sqrt(S)).^2;
            
        end
        
        function D = GPB1(obj,D)
            
            % predicted context probability 
            cPred = D.Phi(obj.cues(D.t),:,D.t);
            
            % log joint probability of the context and the observation
            cyLogJoint = D.cLogLike(:,D.t) + log(cPred)';
            
            % log marginal probability of the observation (log-sum-exp trick to avoid numerical underflow)
            yLogProb = max(cyLogJoint) + log(sum(exp(cyLogJoint - max(cyLogJoint))));
            
            % posterior context probability 
            D.cPost(:,D.t) = exp(cyLogJoint - yLogProb);

            % moment matched state estimate
            D.xMerged(:,D.t) = D.xFilt(:,:,D.t)*D.cPost(:,D.t);
            
            err = D.xFilt(:,:,D.t) - repmat(D.xMerged(:,D.t),1,obj.nC);
            for c = 1:obj.nC
                % moment matched state covariance matrix
                D.vMerged(:,:,D.t) = D.vMerged(:,:,D.t) + (D.vFilt(:,:,c,D.t) + err(:,c)*err(:,c)')*D.cPost(c,D.t);
            end

            % net predicted perturbation
            D.xHat(D.t) = sum(dot(D.C',D.xPred(:,:,D.t)).*cPred);

        end
        
        function D = EM(obj,D)

            % E-step
            s = zeros(D.nQ,obj.nC);
            s(obj.cues(D.t),:) = D.cPost(:,D.t)';
            if D.t == 1
                D.S(:,:,D.t) = D.eta(D.t)*s;
            else
                D.S(:,:,D.t) = (1-D.eta(D.t))*D.S(:,:,D.t-1) + D.eta(D.t)*s;
            end

            % M-step
            if D.t < 8 % inhibit re-estimation of the context-specific cue emission probabilities for the first 7 trials
                D.Phi(:,:,D.t+1) = D.Phi(:,:,D.t);
            else
                D.Phi(:,:,D.t+1) = D.S(:,:,D.t)./repmat(sum(D.S(:,:,D.t)),D.nQ,1);
            end
            
        end

    end
    
end
