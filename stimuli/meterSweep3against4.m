
% %%%%%%%%%%%%%%%%%%%%%%% IDEAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% effect of attention on this? 
% 
% 
% 
% 3 against 4 or 2 againt 3? 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 

pulse0 = [1 0 0 0 0 0 0 0 0 0 0 0];
pulse4 = [0 0 0 1 0 0 1 0 0 1 0 0];
pulse3 =  [0 0 0 0 1 0 0 0 1 0 0 0]; 


params.fs           = 44100;
params.datetime     = datetime; 
params.IOI          = 0.170; % IOI that will give pulse rates with same distance from 0.6 is 1.2/7 = 0.1714 
dur_sound           = params.IOI;
dur_pattern         = params.IOI*length(pulse0); 
params.rampon       = 0.010;  
params.rampoff      = 0.010;  
params.f0           = 440; 
params.max_amp      = 0.9; 
params.rms          = params.max_amp * 1/sqrt(2); 


% 6, 9
params.n_cycles_isochr      = 6; 
params.n_cycles_per_step    = 6; 
params.n_steps              = 9; % including isochronous


n_cycles_total = params.n_cycles_per_step*(params.n_steps-2) + params.n_cycles_isochr*2; 
samples_total = (n_cycles_total * length(pulse0) + 1) * params.IOI * params.fs; 


params.trial_duration = samples_total/params.fs; 
disp(sprintf('\n Trial duration is %.1f sec \n', params.trial_duration))

params.step_duration = params.n_cycles_per_step*length(pulse0)*params.IOI; 
disp(sprintf('\n Step duration is %.1f sec \n', params.step_duration ))

params.freq_res_per_step = 1/(params.n_cycles_per_step*length(pulse0)*params.IOI); 
disp(sprintf('\nWith current parameters, you get frequency resolution of %.3f Hz \n', params.freq_res_per_step))


n_frex = 5; 
frex3 = 1/(params.IOI*3) * [1:n_frex]; 
frex4 = 1/(params.IOI*4) * [1:n_frex]; 
N = round(params.n_cycles_per_step*dur_pattern*params.fs); 
frex3idx = round(frex3/params.fs*N)+1; 
frex4idx = round(frex4/params.fs*N)+1; 
freq = [0:N-1]/N*params.fs; 


%---------------------------------------------------------------------

% % dB scale
% dBFS_sweep = linspace(-10,0,params.n_steps); 
% params.I_sweep = 10.^(dBFS_sweep/20); 
% 

% linear scale
params.I_sweep = linspace(0,1,params.n_steps); 


% % quadratic scale
% params.I_sweep = sqrt(linspace(0,1,params.n_steps)); 



%----------------------------------------------------------------------


t = [0 : samples_total]/params.fs; 
s = params.max_amp * sin(2*pi*t*params.f0); 


env_event = ones(1,round(dur_sound*params.fs)); 
env_event(1:round(params.rampon*params.fs)) = linspace(0,1,round(params.rampon*params.fs)); 
env_event(end-round(params.rampoff*params.fs)+1 : end) = linspace(1,0,round(params.rampoff*params.fs)); 


%----------------------------------------------------------------------
I_sweep_incr_all = [repelem(params.I_sweep(1),params.n_cycles_isochr), repelem(params.I_sweep(2:end-1),params.n_cycles_per_step), repelem(params.I_sweep(end),params.n_cycles_isochr)]; 

env0 = zeros(1, length(s)); 
pattern_all = repmat(pulse0, 1, n_cycles_total); 
for cyclei=1:n_cycles_total
    for eventi=1:length(pulse0)
        if pulse0(eventi) == 1
            idx = round(((cyclei-1)*12+(eventi-1))*params.IOI*params.fs); 
            env0(idx+1:idx+length(env_event)) = env_event;         
        end
    end
end
% add one sound event at the end to have perfect symmetry! With this you
% can flip the stimulus. When analyzing, don't that this last even into
% account to have integer number of cycles!!!
idx = round(cyclei*12*params.IOI*params.fs); 
env0(idx+1:idx+length(env_event)) = env_event;         



env4_incr = zeros(1, length(s)); 
pattern_all = repmat(pulse4, 1, n_cycles_total); 
for cyclei=1:n_cycles_total
    for eventi=1:length(pulse4)
        if pulse4(eventi) == 1
            idx = round(((cyclei-1)*12+(eventi-1))*params.IOI*params.fs); 
            env4_incr(idx+1:idx+length(env_event)) = env_event * I_sweep_incr_all(cyclei);         
        end
    end
end

env3_decr = zeros(1, length(s)); 
pattern_all = repmat(pulse3, 1, n_cycles_total); 
for cyclei=1:n_cycles_total
    for eventi=1:length(pulse3)
        if pulse3(eventi) == 1
            idx = round(((cyclei-1)*12+(eventi-1))*params.IOI*params.fs); 
            env3_decr(idx+1:idx+length(env_event)) = env_event * I_sweep_incr_all(end+1-cyclei);         
        end
    end
end




%----------------------------------------------------------------------

env_4incr3decr = env0 + env4_incr + env3_decr; 
env_4decr3incr = flip(env_4incr3decr); 

%%%%%%%%%%%%%% result %%%%%%%%%%%%%%%%%%%%
s_4decr3incr = s .* env_4decr3incr; 
s_4incr3decr = s .* env_4incr3decr; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% figure('Position', [1924 1376 1050 203])
% plot(env0,'LineWidth',1.9)
% hold on
% plot(env3_incr,'LineWidth',1.9)
% plot(env4_decr,'LineWidth',1.9)



f = figure('color', 'white', 'Position', [1924 1376 1050 203]); 
ax = subplot(2,1,1); 
h = plot(t,s.*env0); 
hold on
h = plot(t,s.*env4_incr); 
h = plot(t,s.*env3_decr); 
box off
ax.XColor = 'none'; 
ax.YColor = 'none'; 

ax = subplot(2,1,2); 
h = plot(t,s.*flip(env0)); 
hold on
h = plot(t,s.*flip(env4_incr)); 
h = plot(t,s.*flip(env3_decr)); 
box off
ax.XColor = 'none'; 
ax.YColor = 'none'; 




%% SAVE


audiowrite('./out/s_4decr3incr.wav',s_4decr3incr,params.fs); 
audiowrite('./out/s_4incr3decr.wav',s_4incr3decr,params.fs); 

stimuli = struct('name',{'4decr3incr','4incr3decr'}, 's', {s_4decr3incr, s_4incr3decr}); 

save('./out/XPMeterSweep_4against3.mat', ...
    'stimuli', 'params'); 






%%


% fprintf('\n--------------------------------------\n')
% for stepi=1:params.n_steps
%     idx = round((stepi-1)*params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs); 
%     fprintf('step %d\trms = %f\tpower = %f\n', stepi, rms(s_3decr4incr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs))), rms(s_3decr4incr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs)))^2)
% end
% fprintf('--------------------------------------\n')
% fprintf('Whole trial duration: %.1f sec\n',length(s_3decr4incr)/params.fs)
% fprintf('--------------------------------------\n')



% 
% mean_amp3_3incr4decr = zeros(1,params.n_steps); 
% mean_amp4_3incr4decr = zeros(1,params.n_steps); 
% mean_z3_3incr4decr = zeros(1,params.n_steps); 
% mean_z4_3incr4decr = zeros(1,params.n_steps); 
% 
% mean_amp3_3decr4incr = zeros(1,params.n_steps); 
% mean_amp4_3decr4incr = zeros(1,params.n_steps); 
% mean_z3_3decr4incr = zeros(1,params.n_steps); 
% mean_z4_3decr4incr = zeros(1,params.n_steps); 
% 
% c_cycle = [1,0]; % [which cycle to start at, how many cycles to take from there] 
% for stepi=1:params.n_steps
%     
%     if stepi==1 | stepi==params.n_steps
%         c_cycle(2) = params.n_cycles_isochr; 
%     end
%     idx = round((c_cycle(1)-1)*params.IOI*length(pulse3)*params.fs); 
% 
%     %------- 4 incr 3 decr -------
%     x3decr4incr = env_3decr4incr(idx+1:idx+round(params.IOI*length(pulse4)*c_cycle(2)*params.fs)); 
%     mX3decr4incr = abs(fft(x3decr4incr)); 
%     
%     amps3decr4incr = mX3decr4incr([frex3idx,frex4idx]); 
%     z3decr4incr = zscore(amps3decr4incr); 
%     mean_amp3_3decr4incr(stepi) = mean(amps3decr4incr(1:n_frex)); 
%     mean_amp4_3decr4incr(stepi) = mean(amps3decr4incr(n_frex+1:end)); 
%     mean_z3_3decr4incr(stepi) = mean(z3decr4incr(1:n_frex)); 
%     mean_z4_3decr4incr(stepi) = mean(z3decr4incr(n_frex+1:end)); 
%     
%     %------- 3 incr 4 decr -------
%     x3incr4decr = env_3incr4decr(idx+1:idx+round(params.IOI*length(pulse4)*c_cycle(2)*params.fs)); 
%     mX3incr4decr = abs(fft(x3incr4decr)); 
% 
%     amps3incr4decr = mX3incr4decr([frex3idx,frex4idx]); 
%     z3incr4decr = zscore(amps3incr4decr); 
%     mean_amp3_3incr4decr(stepi) = mean(amps3incr4decr(1:n_frex)); 
%     mean_amp4_3incr4decr(stepi) = mean(amps3incr4decr(n_frex+1:end)); 
%     mean_z3_3incr4decr(stepi) = mean(z3incr4decr(1:n_frex)); 
%     mean_z4_3incr4decr(stepi) = mean(z3incr4decr(n_frex+1:end)); 
%     
%     
%     %------- plot -------
%     figure; 
%     subplot 211
%     plot(x3decr4incr)
%     subplot 212
%     freq = [0 : length(mX3decr4incr)-1]/length(mX3decr4incr)*params.fs; 
%     stem(freq,mX3decr4incr)
%     xlim([0,7])
%     
%     c_cycle = [c_cycle(1)+c_cycle(2), params.n_cycles_per_step]; 
% end
% 
% 
% 
% 
% 
% 
% f = figure('color','white','Position', [2066 1063 285 141]); 
% ax = axes; 
% plot(mean_amp3_3incr4decr, 'b-o', 'MarkerFaceColor','b'); 
% hold on
% plot(flip(mean_amp3_3decr4incr), 'r-o', 'MarkerFaceColor','r')
% box off
% xlim([1,params.n_steps])
% set(gca,'xtick',[1:params.n_steps],'ytick',[],'fontsize',16)
% ax.YAxis.Visible = 'off'; 
% ylabel('mean_amp3')
% 
% 
% 
% %%
% 










