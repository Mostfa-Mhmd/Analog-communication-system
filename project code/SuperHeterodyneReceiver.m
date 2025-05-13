function m_out= SuperHeterodyneReceiver(FDM_signal,fc,fs,bw,beta,key)
% modulated signal , Tunning frequency  ,  sampling f , bandwidth
f_IF= 25000;
%% RF stage
f1= (fc-bw) / (fs/2);    % lower cutoff
f2= (fc+bw) / (fs/2);      % upper cutoff
n= 6;              % filter order
Rs= 70;              % stoband attenuation
[b,a]= cheby2(n,Rs,[f1,f2],'bandpass');
rf_out= filter(b,a,FDM_signal);
%fvtool(b, a, 'Fs', fs);
%% RF spectrum
[f_rf, p_rf]= FreqSpec(rf_out, fs);
figure('Name',sprintf('Super-Heterodyne Receiver - fc = %d KHz',fc/1000));
subplot(2,2,1);
plot(f_rf,p_rf)
title('RF Stage Spectrum')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
%% Mixer stage
f_lo= fc + f_IF;
t= 0 : 1/fs : (length(rf_out)-1)/fs;
lo= cos(2*pi*f_lo*t);
mixer_out= rf_out.*lo';
% spectrum
[f_mixer, p_mixer]= FreqSpec(mixer_out, fs);
subplot(2,2,2);
plot(f_mixer,p_mixer)
title('Local Oscillator Translation')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
hold on;
xline(f_IF,'--r','F_I_F')   % mark Intermediate frequncy
xline(f_lo,'--r','F_L_O')   % marl Local Oscillator frequency 
%% IF stage
fp1= (f_IF-bw) / (fs/2);      % lower cutoff
fp2= (f_IF+bw) / (fs/2);      % upper cutoff
n2= 4;              % filter order
[b2,a2]= butter(n2,[fp1 fp2],'bandpass');
if_out= filtfilt(b2,a2,mixer_out);
%fvtool(b2, a2, 'Fs', fs);
% IF spectrum
[f_i, p_i]= FreqSpec(if_out, fs);
subplot(2,2,3);
plot(f_i,p_i)
title('IF Stage Spectrum')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
%% Baseband detection
if key < 3    % SSB
    t= 0 : 1/fs : (length(if_out)-1)/fs;
    c_IF= cos(2*pi*f_IF*t);
    s= if_out.*c_IF';
    f_cut= (bw) / (fs/2);
    n3= 10;              % filter order
    Rs= 50;              % stoband attenuation
    [b3,a3]= cheby2(n3,Rs,f_cut,'low');
    m= filter(b3,a3,s);  % Demodulated signal
    m= m - mean(m);      % Remove DC
    gain= 40;
    m_out= gain*m;      % Amplifying the signal to redeem the lost power
    %fvtool(b3, a3, 'Fs', fs);
else   % NBFM
    baseband = hilbert(if_out);
    phase = unwrap(angle(baseband));
    instantaneous_freq = [0; diff(phase)] * fs/(2*pi);
    m_out = instantaneous_freq / beta;    % Scaling by beta
    m_out = m_out - mean(m_out);          % Remove DC offset
    
   % Low-pass filter for smoothing
    f_cut = bw/(fs/2);
    [b_lpf, a_lpf] = butter(4, f_cut, 'low'); 
    m_out = filtfilt(b_lpf, a_lpf, m_out);
end
% Demodulated signal spectrum
[f_m, p_m]= FreqSpec(m_out, fs);
subplot(2,2,4);
plot(f_m,p_m)
title('Baseband detection stage')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
end