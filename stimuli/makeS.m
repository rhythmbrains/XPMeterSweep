function [s,fs,env,devcycle] = makeS(pattern, n_cycles, varargin)

    fs = 44100; 
    f0 = 440; 
    IOI = 0.2; 
    dutycycle = IOI; 
    rampon = 0.01; 
    rampoff = 0.01; 

    if any(strcmpi(varargin,'fs'))
        fs = varargin{find(strcmpi(varargin,'fs'))+1}; 
    end
    if any(strcmpi(varargin,'IOI'))
        IOI = varargin{find(strcmpi(varargin,'IOI'))+1}; 
        dutycycle = IOI; 
    end
    if any(strcmpi(varargin,'rampon'))
        rampon = varargin{find(strcmpi(varargin,'rampon'))+1}; 
    end
    if any(strcmpi(varargin,'rampoff'))
        rampoff = varargin{find(strcmpi(varargin,'rampoff'))+1}; 
    end
    if any(strcmpi(varargin,'duty'))
        dutycycle = varargin{find(strcmpi(varargin,'duty'))+1}; 
    end
    
    
    rampon_samples = round(rampon*fs); 
    rampoff_samples = round(rampoff*fs); 
    duty_samples = round(dutycycle*fs); 
    
    t = [0:round(fs*(IOI*length(pattern)*n_cycles))-1]/fs; 
    s = sin(2*pi*f0*t); 
    
    env_event = ones(1,round(fs*(dutycycle))); 
    env_event(1:rampon_samples) = env_event(1:rampon_samples) .* linspace(0,1,rampon_samples); 
    env_event(end-rampoff_samples+1:end) = env_event(end-rampoff_samples+1:end) .* linspace(1,0,rampoff_samples); 
    
    c=0; 
    env = zeros(1,length(s)); 
    for cycle=1:n_cycles
        for i=1:length(pattern)
            if pattern(i)
                env(round(c*IOI*fs)+1:round(c*IOI*fs)+length(env_event)) = pattern(i).*env_event; 
            end
            c=c+1; 
        end
    end
    
    s = s.* env; 
    
    if any(strcmpi(varargin,'countin'))
        t = [0:round(fs*IOI*length(pattern))-1]/fs; 
        countin = zeros(size(t)); 
        click = repmat(0.9,1,round(0.005*fs)); 
        for i=1:3
            idx = round((i-1)*IOI*4*fs); 
            countin(idx+1:idx+length(click)) = click; 
        end
        s = [countin, s]; 
    end
    
end