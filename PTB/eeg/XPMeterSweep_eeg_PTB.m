
%% Meter Sweep tapping pilot

% -----------------------------------------------
% CHANGELOG
% 
% 
% -----------------------------------------------
% TO DO 
% 
% 
% -----------------------------------------------




% INITIALIZE
clear all
sca
rand('state',sum(100*clock));
WaitSecs(0.1);
GetSecs;
PsychDefaultSetup(2);



% INFO
SUBJECT     = input('Subject ID: '); %Gets Subject Number
c           = clock; %Current date and time as date vector. [year month day hour minute seconds]
date_time   = sprintf('%d-%d-%d_%d-%d',c(2),c(3),c(1),c(4),c(5)); %makes unique filename
experiment  = 'XPMeterSweep'; 





% PATHS
addpath(genpath('~/Documents/MATLAB/stimulusPresentationLib'));
load_path   = fullfile('./to_load/XPMeterSweep_4against3.mat');
log_path    = fullfile('.','log',log_path,sprintf('ID%d',SUBJECT)); 
if ~isdir(log_path); mkdir(log_path); end



% PARAMETERS

params_exp = XPMeterSweep_eeg_PTB_paramsClass;




% SCREEN
PsychDebugWindowConfiguration
screen = max(Screen('Screens'));
blackcol = 0;
col_text = [255,255,255];
[win,rect] = PsychImaging('OpenWindow',screen,blackcol,[0,0,1000,500]);
Screen('BlendFunction',win,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
Screen('TextSize',win,32);

% cross
n_pix       = 20;
x_coord     = [-n_pix n_pix 0 0];
y_coord     = [0 0 -n_pix n_pix];
fix_coord   = [x_coord; y_coord];
col_cross   = [255,255,255]/2;





% KEYBOARD
keyspace    = KbName('space');
keyy        = KbName('y');
keyn        = KbName('n');
key1to7     = KbName({'1!','2@','3#','4$','5%','6^','7&'});
key1to5     = KbName({'1!','2@','3#','4$','5%'});
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue
ListenChar(-1);






% SOUND
InitializePsychSound(1);  % [reallyneedlowlatency=0]
devices = PsychPortAudio('GetDevices'); 
dev_idx = find(~cellfun(@isempty, regexpi({devices.DeviceName},'Fireface UC Mac'))); 
devID = devices(dev_idx).DeviceIndex; 
dev_n_channels = devices(dev_idx).NrOutputChannels; 


pahandle = PsychPortAudio('Open', devID, 3, 3, 44100, 18, [], [], [0:17]);% pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
PsychPortAudio('Volume',pahandle,0.2); 
PsychPortAudio('GetAudioData', pahandle, 120); %preallocate tapping buffer












%% INTRO


% load sounds
load(load_path)
params_stim = params; 


% set audio volume
need_gain = 20*log10((1/sqrt(2)/params_stim.rms)); % how much gain in dB do we need considering the RMS of s (and the fact that we are calibrating with unit-amplitude sinusiod)
[thr,UD] = setVolumeUDPTB(win, pahandle, dev_idx); 
target_vol = 10^((thr+params_exp.ptbvolume_dBSL+need_gain)/20); 
PsychPortAudio('Volume',pahandle,target_vol); 


% odd-numbered subjects will start with stimulus 1 and even-numbered subjects will start with stimulus 2 
if mod(SUBJECT,2)
    trial_order_type = [1,2]; 
else
    trial_order_type = [2,1]; 
end











% =================================== TAPPING SESSION 1 ====================================

% get trial order for this session
trial_order_tap1 = repmat(trial_order_type,1,params_exp.ntrials_per_rhythm_tap1); 

% draw instructions on the screen, wait for spacebar
DrawFormattedText(win,params_exp.instr_intro_tap1,'center','center',col_text);
Screen('Flip',win);
waitForKey(keyspace);


res.data(1).session = 'tap1'; 

for triali=1:length(trial_order_tap1)

    % DRAW CROSS
    Screen('DrawLines',win,fix_coord,4,col_cross,[xcenter,ycenter],2);
    Screen('Flip',win);

    % PREPARE SOUND
    s_name = stimuli(trial_order_tap1(triali)).name; 
    s = stimuli(trial_order_tap1(triali)).s; 
    s_out = zeros(dev_n_channels, length(s)); 
    s_out(1,:) = s; 
    s_out(2,:) = s; 
    
    PsychPortAudio('FillBuffer',pahandle,s_out);
    WaitSecs(rand(1)+1);  % wait 1-2 sec

    % PLAY SOUND
    DrawFormattedText(win,'Tap','center','center',col_text);
    Screen('Flip',win);
    startTime = PsychPortAudio('Start',pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
    PsychPortAudio('Stop',pahandle,1); %actualStartTime is the same as returned by Start command in WaitForStart mode

    % SAVE tapping as audiofile
    tapata = PsychPortAudio('GetAudioData', pahandle); 
    tapdata = tapdata(1,:); 
    file_name_tap = fullfile(log_path, sprintf('%s_tappingSession1_ID%d_%s_%s_trial%d.wav', experiment, SUBJECT, date_time, s_name, triali)); 
    audiowrite(file_name_tap, tapData', fs); 

    % SAVE tapping as matfile
    res.data(1).trial(triali).stimulus = stimuli(trial_order_tap1(triali));
    res.data(1).trial(triali).response = tapdata;

    % DISPLAY message
    if triali<length(trial_order_tap1)
        to_disp = sprintf('Take a break...\n\nPress SPACE to continue...');
        DrawFormattedText(win,to_disp,'center','center',col_text);
        Screen('Flip',win);
        waitForKey(keyspace);
    end
    
end








% ===================================== EEG SESSION ====================================

% get trial order for this session
trial_order_eeg = repmat(trial_order_type,1,params_exp.ntrials_per_rhythm_eeg); 

% draw instructions on the screen, wait for spacebar
DrawFormattedText(win,params_exp.instr_intro_eeg,'center','center',col_text);
Screen('Flip',win);
waitForKey(keyspace);


res.data(2).session = 'eeg'; 

for triali=1:length(trial_order_eeg)

    % DRAW CROSS
    Screen('DrawLines',win,fix_coord,4,col_cross,[xcenter,ycenter],2);
    Screen('Flip',win);

    % PREPARE SOUND
    s_name = stimuli(trial_order_eeg(triali)).name; 
    s = stimuli(trial_order_eeg(triali)).s; 
    s_out = zeros(dev_n_channels, length(s)); 
    s_out(1,:) = s; 
    s_out(2,:) = s; 
    
    % TRIGGER
    trig = zeros(size(s)); 
    trig(1:round(0.010*params_stim.fs)) = 1; 
    if trial_order_eeg(triali)==1
        trig_chan = 3; 
    elseif trial_order_eeg(triali)==2
        trig_chan = 4; 
    end
    s_out(trig_chan,:) = trig; 
    
    % PLAY SOUND
    PsychPortAudio('FillBuffer',pahandle,s_out);
    WaitSecs(rand(1)+1);  % wait 1-2 sec

    startTime = PsychPortAudio('Start',pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
    PsychPortAudio('Stop',pahandle,1); %actualStartTime is the same as returned by Start command in WaitForStart mode

    % SAVE matfile
    res.data(2).trial(triali).stimulus = stimuli(trial_order_eeg(triali));
    
    % DISPLAY message
    if triali<length(trial_order_eeg)
        to_disp = sprintf('Take a break...\n\nPress SPACE to continue...');
        DrawFormattedText(win,to_disp,'center','center',col_text);
        Screen('Flip',win);
        waitForKey(keyspace);
    end
    
end












% =================================== TAPPING SESSION 2 ====================================

% get trial order for this session
trial_order_tap2 = repmat(trial_order_type,1,params_exp.ntrials_per_rhythm_tap2); 

% draw instructions on the screen, wait for spacebar
DrawFormattedText(win,params_exp.instr_intro_tap1,'center','center',col_text);
Screen('Flip',win);
waitForKey(keyspace);


res.data(3).session = 'tap2'; 

for triali=1:length(trial_order_tap2)

    % DRAW CROSS
    Screen('DrawLines',win,fix_coord,4,col_cross,[xcenter,ycenter],2);
    Screen('Flip',win);

    % PREPARE SOUND
    s_name = stimuli(trial_order_tap2(triali)).name; 
    s = stimuli(trial_order_tap2(triali)).s; 
    s_out = zeros(dev_n_channels, length(s)); 
    s_out(1,:) = s; 
    s_out(2,:) = s; 
    
    PsychPortAudio('FillBuffer',pahandle,s_out);
    WaitSecs(rand(1)+1);  % wait 1-2 sec

    % PLAY SOUND
    DrawFormattedText(win,'Tap','center','center',col_text);
    Screen('Flip',win);
    startTime = PsychPortAudio('Start',pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
    PsychPortAudio('Stop',pahandle,1); %actualStartTime is the same as returned by Start command in WaitForStart mode

    % SAVE tapping as audiofile
    tapata = PsychPortAudio('GetAudioData', pahandle); 
    tapdata = tapdata(1,:); 
    file_name_tap = fullfile(log_path, sprintf('%s_tappingSession2_ID%d_%s_%s_trial%d.wav', experiment, SUBJECT, date_time, s_name, triali)); 
    audiowrite(file_name_tap, tapData', fs); 

    % SAVE tapping as matfile
    res.data(3).trial(triali).stimulus = stimuli(trial_order_tap2(triali));
    res.data(3).trial(triali).response = tapdata;

    % DISPLAY message
    if triali<length(trial_order_tap2)
        to_disp = sprintf('Take a break...\n\nPress SPACE to continue...');
        DrawFormattedText(win,to_disp,'center','center',col_text);
        Screen('Flip',win);
        waitForKey(keyspace);
    end
    
end

















%% END
to_disp = sprintf('Thank you for participation!');
DrawFormattedText(win,to_disp,'center','center',col_text);
Screen('Flip',win);
WaitSecs(5);


%% SAVE
res.subjectID = SUBJECT;
res.experiment = experiment;
res.paramsExp = params_exp;
res.paramsStim = params_stim;
res.timeStamp = date_time; 
res.script = mfilename; 

c = clock; %Current date and time as date vector. [year month day hour minute seconds]

baseName=['log_', experiment,'_ID',num2str(SUBJECT) '_' num2str(c(2)) '.' num2str(c(3)) '.' num2str(c(1)) '.' num2str(c(4)) num2str(c(5)) '.mat']; %makes unique filename
save([log_path,filesep,baseName],'res');

% copy the script file to the log folder
if ~isempty(mfilename)
    copyfile([mfilename,'.m'], fullfile(log_path,[mfilename,'.m'])); 
end

%% CLEAR UP
sca;
PsychPortAudio('Close');
Priority(0);
ListenChar(0);
ShowCursor();
KbQueueStop;
KbQueueRelease;








