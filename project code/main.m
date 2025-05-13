clc; clear; close all;
%% Modulation process

files = {'sample1.wav', 'sample4.mp3','sample3.wav', 'sample5.mp3'};  % Load audio signals
fc_list = [100e3, 150e3, 200e3, 250e3];  % list Carrier frequencies
beta = 0.9;     % FM deviation ratio
[FDM_signal1,fs]= modUnify(files, fc_list,beta);

 bw= 15e3;
%% Demodulation
     i=3;   % selecting each signal by its index
     key = i;
     m_out= SuperHeterodyneReceiver(FDM_signal1,fc_list(i),fs,bw,beta,key);

%% Resampling
m_out=resample(m_out,44100,fs);

%% Comparing signals before and after
    [m_in, fm] = audioread(files{i});
    [f_m_in, p_m_in]= FreqSpec(m_in, fm); 
    figure;
    subplot(2,1,1);
    plot(f_m_in,p_m_in)
    title('Original Signal Spectrum')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    % restored signal
    [f_m_out, p_m_out]= FreqSpec(m_out, fm);  
    subplot(2,1,2);
    plot(f_m_out,p_m_out)
    title('Restored Signal Spectrum')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
% sound(m_out,fm)