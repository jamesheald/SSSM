%% simulate experiment 2 of Heald et al. Nature human behaviour (2018)

try
    load('paradigm.mat','perturbations','cues')
catch
    error('Download the paradigm.mat file in the examples folder.')
end

same_field_subjects = 1:8;
opoosing_field_subjects = 9:16;
number_of_subjects = 16;

D = cell(1,number_of_subjects);
for subject = 1:number_of_subjects
    
    obj = SSSM;
    obj.perturbations = perturbations(:,subject);
    obj.cues = cues(:,subject);
    D{subject} = obj.simulate_SSSM;
    
    % channel trials for control point 1
    channel_trials(1,:,subject) = find(isnan(obj.perturbations).*obj.cues==1);
    
    % channel trials for control point 2
    channel_trials(2,:,subject) = find(isnan(obj.perturbations).*obj.cues==2);
    
    % adaptation on channel trials for control point 1
    xHat(1,:,subject) = D{subject}.xHat(channel_trials(1,:,subject));
    
    % adaptation on channel trials for control point 2
    xHat(2,:,subject) = D{subject}.xHat(channel_trials(2,:,subject));
    
    % normalise cue emission probabilities to calculate predicted context probabilities
    cPred(:,:,subject) = D{subject}.Phi(1,:,:)./sum(D{subject}.Phi(1,:,:));

end

%% figures

% linewidth
LW = 2; 

figure
subplot(2,2,1)
hold on
plot(mean(channel_trials(1,:,same_field_subjects),3),mean(xHat(1,:,same_field_subjects),3),'r','LineWidth',LW)
plot(mean(channel_trials(2,1:26,same_field_subjects),3),mean(xHat(2,1:26,same_field_subjects),3),'b','LineWidth',LW)
legend('control point 1','control point 2','autoupdate','off','box','off','location','best')
plot([0 540],[0 0],'k--')
plot(mean(channel_trials(2,27:end,same_field_subjects),3),mean(xHat(2,27:end,same_field_subjects),3),'b','LineWidth',LW)
ylabel('adaptation')
xlabel('trial')
axis([0 540 -.2 1])
title('same-field group')

subplot(2,2,2)
hold on
plot(mean(channel_trials(1,:,opoosing_field_subjects),3),mean(xHat(1,:,opoosing_field_subjects),3),'r','LineWidth',LW)
plot(mean(channel_trials(2,1:26,opoosing_field_subjects),3),-mean(xHat(2,1:26,opoosing_field_subjects),3),'b','LineWidth',LW)
legend('control point 1','control point 2','autoupdate','off','box','off','location','best')
plot([0 540],[0 0],'k--')
plot(mean(channel_trials(2,27:end,opoosing_field_subjects),3),-mean(xHat(2,27:end,opoosing_field_subjects),3),'b','LineWidth',LW)
ylabel('adaptation')
xlabel('trial')
axis([0 540 -.2 1])
title('opposing-field group')

subplot(2,2,3)
hold on
plot(mean(cPred(2,:,same_field_subjects),3),'r','LineWidth',LW)
plot(mean(cPred(1,:,same_field_subjects),3),'b--','LineWidth',LW)
legend('context 1','context 2','autoupdate','off','box','off','location','best')
xlabel('trial')
ylabel('probability of context | right control point')
axis([0 540 0 1])
title('same-field group')

subplot(2,2,4)
hold on
plot(mean(cPred(2,:,opoosing_field_subjects),3),'r','LineWidth',LW)
plot(mean(cPred(1,:,opoosing_field_subjects),3),'b','LineWidth',LW)
legend('context 1','context 2','autoupdate','off','box','off','location','best')
xlabel('trial')
ylabel('probability of context | right control point')
axis([0 540 0 1])
title('opposing-field group')
