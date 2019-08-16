
% %%%%%%%%%%%%%%%%%%%%%%% IDEAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% effect of attention on this? 
% 
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 

pulse0 = [1 0 0 0 0 0];
pulse2 = [0 0 0 1 0 0];
pulse3 = [0 0 1 0 1 0]; 


params.fs           = 44100;
params.datetime     = datetime; 
params.IOI          = 0.200; % to get the same distance from 0.6 s -> IOI = 0.240 s, same distance from 0.5 s is IOI = 0.200
dur_sound           = params.IOI;
dur_pattern         = params.IOI*length(pulse0); 
params.rampon       = 0.010;  
params.rampoff      = 0.010;  
params.f0           = 440; 
params.max_amp      = 0.9; 
params.rms          = params.max_amp * 1/sqrt(2); 



params.n_cycles_isochr      = 10; 
params.n_cycles_per_step    = 10; 
params.n_steps              = 9; % including isochronous


n_cycles_total = params.n_cycles_per_step*(params.n_steps-2) + params.n_cycles_isochr*2; 
samples_total = (n_cycles_total * length(pulse2) + 1) * params.IOI * params.fs; 




params.trial_duration = samples_total/params.fs; 
disp(sprintf('\n Trial duration is %.1f sec \n', params.trial_duration))

params.step_duration = params.n_cycles_per_step*length(pulse0)*params.IOI; 
disp(sprintf('\n Step duration is %.1f sec \n', params.step_duration ))

params.freq_res_per_step = 1/(params.n_cycles_per_step*length(pulse0)*params.IOI); 
disp(sprintf('\nWith current parameters, you get frequency resolution of %.3f Hz \n', params.freq_res_per_step))




%---------------------------------------------------------------------

% % dB scale
% dBFS_sweep = linspace(-20,0,params.n_steps); 
% params.I_sweep = 10.^(dBFS_sweep/20); 


% linear scale
params.I_sweep = linspace(0,1,params.n_steps); 


% % log scale
% params.I_sweep = logspace(log10(0.01),log10(1),params.n_steps); 



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
            idx = round(((cyclei-1)*length(pulse0)+(eventi-1))*params.IOI*params.fs); 
            env0(idx+1:idx+length(env_event)) = env_event;         
        end
    end
end
% add one sound event at the end to have perfect symmetry! With this you
% can flip the stimulus. When analyzing, don't that this last even into
% account to have integer number of cycles!!!
idx = round(cyclei*length(pulse0)*params.IOI*params.fs); 
env0(idx+1:idx+length(env_event)) = env_event;         



env2_incr = zeros(1, length(s)); 
pattern_all = repmat(pulse2, 1, n_cycles_total); 
for cyclei=1:n_cycles_total
    for eventi=1:length(pulse2)
        if pulse2(eventi) == 1
            idx = round(((cyclei-1)*length(pulse0)+(eventi-1))*params.IOI*params.fs); 
            env2_incr(idx+1:idx+length(env_event)) = env_event * I_sweep_incr_all(cyclei);         
        end
    end
end



env3_decr = zeros(1, length(s)); 
pattern_all = repmat(pulse3, 1, n_cycles_total); 
for cyclei=1:n_cycles_total
    for eventi=1:length(pulse3)
        if pulse3(eventi) == 1
            idx = round(((cyclei-1)*length(pulse0)+(eventi-1))*params.IOI*params.fs); 
            env3_decr(idx+1:idx+length(env_event)) = env_event * I_sweep_incr_all(end+1-cyclei);         
        end
    end
end




%----------------------------------------------------------------------

env_2incr3decr = env0 + env2_incr + env3_decr; 
env_2decr3incr = flip(env_2incr3decr); 

%%%%%%%%%%%%%% result %%%%%%%%%%%%%%%%%%%%
s_2decr3incr = s .* env_2decr3incr; 
s_2incr3decr = s .* env_2incr3decr; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




f = figure('color', 'white', 'Position', [1924 1376 1050 203]); 
ax = axes; 
h = plot(t,s.*env0); 
hold on
h = plot(t,s.*env2_incr); 
h = plot(t,s.*env3_decr); 
box off
ax.XColor = 'none'; 
ax.YColor = 'none'; 



%% SAVE


audiowrite('./out/s_2decr3incr.wav',s_2decr3incr,params.fs); 
audiowrite('./out/s_2incr3decr.wav',s_2incr3decr,params.fs); 


stimuli = struct('name',{'2decr3incr','2incr3decr'}, 's', {s_2decr3incr, s_2incr3decr}); 

save('./out/XPMeterSweep_2against3.mat', ...
    'stimuli', 'params'); 




%%

n_frex = 5; 
frex3 = 1/(params.IOI*3) * [1:n_frex]; 
frex4 = 1/(params.IOI*4) * [1:n_frex]; 
N = round(params.n_cycles_per_step*dur_pattern*params.fs); 
frex3idx = round(frex3/params.fs*N)+1; 
frex4idx = round(frex4/params.fs*N)+1; 
freq = [0:N-1]/N*params.fs; 



% 
% 
% %%
% 
% 
% % fprintf('\n--------------------------------------\n')
% % for stepi=1:params.n_steps
% %     idx = round((stepi-1)*params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs); 
% %     fprintf('step %d\trms = %f\tpower = %f\n', stepi, rms(s_3decr4incr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs))), rms(s_3decr4incr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs)))^2)
% % end
% % fprintf('--------------------------------------\n')
% % fprintf('Whole trial duration: %.1f sec\n',length(s_3decr4incr)/params.fs)
% % fprintf('--------------------------------------\n')
% 
% 
% 
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
%     idx = round((c_cycle(1)-1)*params.IOI*length(pulse2)*params.fs); 
% 
%     %------- 4 incr 3 decr -------
%     x3decr4incr = env_3decr4incr(idx+1:idx+round(params.IOI*length(pulse3)*c_cycle(2)*params.fs)); 
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
%     x3incr4decr = env_3incr4decr(idx+1:idx+round(params.IOI*length(pulse3)*c_cycle(2)*params.fs)); 
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
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
