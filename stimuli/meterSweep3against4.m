
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






%% PLOT


% fprintf('\n--------------------------------------\n')
% for stepi=1:params.n_steps
%     idx = round((stepi-1)*params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs); 
%     fprintf('step %d\trms = %f\tpower = %f\n', stepi, rms(s_4incr3decr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs))), rms(s_4incr3decr(idx+1:idx+round(params.IOI*length(pulse4)*params.n_cycles_per_step*params.fs)))^2)
% end
% fprintf('--------------------------------------\n')
% fprintf('Whole trial duration: %.1f sec\n',length(s_4incr3decr)/params.fs)
% fprintf('--------------------------------------\n')



n_frex = 5; 
frex3 = 1/(params.IOI*4) * [1:n_frex]; 
frex4 = 1/(params.IOI*3) * [1:n_frex]; 
frex2remove = intersect(frex3,frex4); 
frex3(frex3==frex2remove) = []; 
frex4(frex4==frex2remove) = []; 

N = round(params.n_cycles_per_step*dur_pattern*params.fs); 
frex3idx = round(frex3/params.fs*N)+1; 
frex4idx = round(frex4/params.fs*N)+1; 
idx_maxHz = round(12/params.fs*N)+1; 
freq = [0:N-1]/N*params.fs; 


 
sum_amp3_4decr3incr = zeros(1,params.n_steps); 
sum_amp4_4decr3incr = zeros(1,params.n_steps); 
sum_z3_4decr3incr = zeros(1,params.n_steps); 
sum_z4_4decr3incr = zeros(1,params.n_steps); 

sum_amp3_4incr3decr = zeros(1,params.n_steps); 
sum_amp4_4incr3decr = zeros(1,params.n_steps); 
sum_z3_4incr3decr = zeros(1,params.n_steps); 
sum_z4_4incr3decr = zeros(1,params.n_steps); 


f = figure('position',[242 780 1629 251],'color','white'); 
p = panel(f); 
p.pack('h',params.n_steps); 

c_cycle = [1,0]; % [which cycle to start at, how many cycles to take from there] 
for stepi=1:params.n_steps
    
    if stepi==1 | stepi==params.n_steps
        c_cycle(2) = params.n_cycles_isochr; 
    end
    idx = round((c_cycle(1)-1)*params.IOI*length(pulse3)*params.fs); 

    %------- 4 incr 3 decr -------
    x4decr3incr = env_4decr3incr(idx+1:idx+round(params.IOI*length(pulse4)*c_cycle(2)*params.fs)); 
    mX4decr3incr = abs(fft(x4decr3incr)); 
    
    amps4decr3incr = mX4decr3incr([frex3idx,frex4idx]); 
    z4decr3incr = zscore(amps4decr3incr); 
    sum_amp3_4decr3incr(stepi) = sum(amps4decr3incr(1:n_frex)); 
    sum_amp4_4decr3incr(stepi) = sum(amps4decr3incr(n_frex+1:end)); 
    sum_z3_4decr3incr(stepi) = sum(z4decr3incr(1:n_frex)); 
    sum_z4_4decr3incr(stepi) = sum(z4decr3incr(n_frex+1:end)); 
    
    %------- 3 incr 4 decr -------
    x4incr3decr = env_4incr3decr(idx+1:idx+round(params.IOI*length(pulse4)*c_cycle(2)*params.fs)); 
    mX4incr3decr = abs(fft(x4incr3decr)); 

    amps4incr3decr = mX4incr3decr([frex3idx,frex4idx]); 
    z4incr3decr = zscore(amps4incr3decr); 
    sum_amp3_4incr3decr(stepi) = sum(amps4incr3decr(1:n_frex)); 
    sum_amp4_4incr3decr(stepi) = sum(amps4incr3decr(n_frex+1:end)); 
    sum_z3_4incr3decr(stepi) = sum(z4incr3decr(1:n_frex)); 
    sum_z4_4incr3decr(stepi) = sum(z4incr3decr(n_frex+1:end)); 
    
    
    %------- plot -------
    p(stepi).pack('v',2); 
    p(stepi,1).select(); 
    plot(x4decr3incr)
    xlabel('time (s)')
    box off
    p(stepi,2).select(); 
    freq = [0 : idx_maxHz-1]/length(mX4decr3incr)*params.fs; 
    h = plot([freq;freq],[zeros(1,idx_maxHz);mX4decr3incr(1:idx_maxHz)],'k','linewidth',1.5); 
    for fi=1:length(frex3idx); h(frex3idx(fi)).Color = [0 0 1]; end; 
    for fi=1:length(frex4idx); h(frex4idx(fi)).Color = [1 0 0]; end; 
    xlabel('frequency (Hz)')
    box off
    xlim([0,10])
    
    c_cycle = [c_cycle(1)+c_cycle(2), params.n_cycles_per_step]; 
end

saveas(f,'./figures/specta.fig'); 
saveas(f,'./figures/specta.tiff'); 
close(f); 



%----------------------------------------------------------
f = figure('color','white','Position', [2066 1063 285 141]); 
ax = axes; 
plot(sum_amp3_4decr3incr, 'b-o', 'MarkerFaceColor','b'); 
hold on
plot(flip(sum_amp3_4incr3decr), 'r-o', 'MarkerFaceColor','r')
box off
xlim([1,params.n_steps])
set(gca,'xtick',[1:params.n_steps],'ytick',[],'fontsize',16)
ax.YAxis.Visible = 'off'; 
title('summed 3pulse amplitudes')
l = legend({'4decr3incr','4incr3decr(flip)'}); 
l.FontSize = 10; 
l.Position = [0.0684 0.5496 0.3456 0.2376]; 

saveas(f,'./figures/3pulse_sumAmp.fig'); 
saveas(f,'./figures/3pulse_sumAmp.tiff'); 
close(f); 



f = figure('color','white','Position', [2066 1063 285 141]); 
ax = axes; 
plot(sum_amp4_4decr3incr, 'b-o', 'MarkerFaceColor','b'); 
hold on
plot(flip(sum_amp4_4incr3decr), 'r-o', 'MarkerFaceColor','r')
box off
xlim([1,params.n_steps])
set(gca,'xtick',[1:params.n_steps],'ytick',[],'fontsize',16)
ax.YAxis.Visible = 'off'; 
title('summed 4pulse amplitudes')
l = legend({'4decr3incr','4incr3decr(flip)'}); 
l.FontSize = 10; 
l.Position = [0.5508 0.5567 0.3772 0.2376]; 

saveas(f,'./figures/4pulse_sumAmp.fig'); 
saveas(f,'./figures/4pulse_sumAmp.tiff'); 
close(f); 


%%











