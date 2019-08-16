classdef XPMeterSweep_eeg_PTB_paramsClass_v1
    
    
    
    
    
    properties
        
        ntrials_per_rhythm = 10; 
        ntrials_per_rhythm_tap = 5; 
        
        ptbvolume_dBSL = 50; 
        
        instr_intro = sprintf(['Welcome. \nYour task will be to tap the steady beat (pulse) \nyou hear in the rhythms.\n\n', ...
                   'Imagine you were at a concert and you were clapping along the beat of music.\n', ...
                   'Or imagine tapping your foot to the rhythm of music.\n', ...
                   'Use the index finger of your dominant hand to tap that same pulse.\n\n', ...
                   'Start tapping as soon as the sound starts and keep tapping until the sound stops.\n', ...
                   'Tap the pulse that feels most comfortable (natural) and try to stay synchronized with the rhythm.\n', ...
                   '...\n\nIf everything is clear, press SPACE to start the first trial...']);

                
    end
    
    
    
    
    
    
    
    
    
    
    
    
        
        
    methods
        
        function sc = paramsClass()
            
        end
            
    end
    
    
    
end