classdef XPMeterSweep_eeg_PTB_paramsClass_v1
    
    
    
    
    
    properties
        
        ntrials_per_rhythm_tap1 = 1; 
        ntrials_per_rhythm = 10; 
        ntrials_per_rhythm_tap2 = 10; 
        
        ptbvolume_dBSL = 50; 
        
        instr_intro_tap1 = sprintf(['Welcome. \nYour task will be to tap the steady beat (pulse) \nyou hear in the rhythm.\n\n', ...
                   'Imagine you were at a concert and you were clapping along the beat of music.\n', ...
                   'Or imagine tapping your foot to your favourite song.\n', ...
                   'Use the index finger of your dominant hand to tap the pulse.\n\n', ...
                   'Start tapping as soon as the sound starts and keep tapping until the sound stops.\n', ...
                   'Don''t worry if you loose the pulse for a moment. Try to find it again.\n', ...
                   'Tap the pulse that feels most comfortable (natural) and try to stay synchronized with the rhythm.\n', ...
                   '...\n\nIf everything is clear, press SPACE to start the first trial...']);
               
               
               
        instr_intro_eeg = sprintf(['Well done. \n\n\n', ...
                   'Now we will record your brain activity as you are listening to the rhythms without any movement.\n', ...
                   'Please DO NOT move in synchrony with the sounds.\n', ...
                   'Also, don''t forget to relax your muscles and keep your eyes on the fixation cross when the sound is on.\n', ...
                   '...\n\nIf everything is clear, press SPACE to start the first trial...']);
               
               
               
        instr_intro_tap2 = sprintf(['Awesome. The EEG session is done. \n\n', ...
                   'Now we will record some more finger tapping. \n', ...
                   'As before, use the index finger of your dominant hand to tap the pulse you hear in the rhythm.\n', ...
                   'Tap the pulse that feels most comfortable (natural) and try to stay synchronized with the rhythm.\n', ...
                   '...\n\nIf everything is clear, press SPACE to start the first trial...']);
                
    end
    
    
    
    
    
    
    
    
    
    
    
    
        
        
    methods
        
        function sc = paramsClass()
            
        end
            
    end
    
    
    
end