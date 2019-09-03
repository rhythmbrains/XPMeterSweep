
fs = 44100; 
out_path = './out_training'; 

% isochronous
s=makeS([1 0 0 0 1 0 0 0 1 0 0 0],8,'IOI',0.2);
audiowrite(fullfile(out_path,'1_isochronous_200ms.wav'),s,fs); 

s=makeS([1 0 0 0 1 0 0 0 1 0 0 0],8,'IOI',0.07);
audiowrite(fullfile(out_path,'2_isochronous_70ms.wav'),s,fs); 

% quadruple
s=makeS([1 0 0 1 1 0 1 0 1 0 0 0],8,'IOI',0.2);
audiowrite(fullfile(out_path,'3_quadruple1_200ms.wav'),s,fs); 

s=makeS([1 0 0 1 1 1 1 0 1 0 1 0],8,'IOI',0.2);
audiowrite(fullfile(out_path,'4_quadruple2_200ms.wav'),s,fs); 

s=makeS([1 0 0 1 0 1 1 0 1 0 1 0],8,'IOI',0.2);
audiowrite(fullfile(out_path,'5_quadruple3_200ms.wav'),s,fs); 

% triple
s=makeS([1 0 0 1 0 0 1 0 1 1 0 1],8,'IOI',0.25);
audiowrite(fullfile(out_path,'6_triple1_250ms.wav'),s,fs); 

s=makeS([1 0 0 1 0 0 1 0 1 1 1 1],8,'IOI',0.25);
audiowrite(fullfile(out_path,'7_triple2_250ms.wav'),s,fs); 

s=makeS([1 0 0 1 0 0 1 0 1 0 1 1],8,'IOI',0.25);
audiowrite(fullfile(out_path,'8_triple3_250ms.wav'),s,fs); 


