function [fdm_signal,fs]= modUnify(files, fc_list,beta)
num_signals = length(files);
% Read and upsample
m_upsampled = cell(1, num_signals);
m_len = 0;
for i = 1:num_signals
    [m, fm] = audioread(files{i});
    if size(m,2) > 1
        m = mean(m, 2);  % Convert stereo to mono
    end
    fs = 15 * fm;               % Upsample rate (for FM)
    m_up = interp(m, 15);       % Upsample
    m_upsampled{i} = m_up;
    m_len = max(m_len, length(m_up));  % Keep highest length
end
% Pad all signals to the max length
for i = 1:num_signals
    current_len = length(m_upsampled{i});
    if current_len < m_len
        m_upsampled{i}(end+1:m_len) = 0; % Zero-padding to match max length
    end
end
t = (0:m_len-1)' / fs;   % Time vector

% using cell array store all modulated signals' spectrum components
p = cell(1, num_signals);
f = cell(1, num_signals);
fdm_signal = zeros(m_len, 1);  % Composite signal
for i = 1:num_signals      % Modulate each message onto its carrier 
    if i < 3
        % SSB
        m_i = m_upsampled{i};
        m_h= imag(hilbert(m_i));
        c= cos(2*pi*fc_list(i)*t);
        c_h= sin(2*pi*fc_list(i)*t);
        s1= m_i.*c;
        s2= m_h.*c_h;
        phi= s1+s2;      %LSB
        fdm_signal = fdm_signal + phi/8;  % Add to FDM composite
         % reduce power of ssb parts to prevent interference at demodulaton

        [f_i, p_i]= FreqSpec(phi, fs);
        p{i}= p_i;
        f{i}= f_i;
    else
        % NBFM
        m_i = m_upsampled{i};
        intg = beta * cumsum(m_i) * 2*pi / fs;
        nbfm = cos(2*pi*fc_list(i)*t + intg);
       % nbfm = nbfm * 6=;         
        fdm_signal = fdm_signal + nbfm;  % Add to FDM composite
        [f_i, p_i]= FreqSpec(nbfm, fs);
        p{i}= p_i;
        f{i}= f_i;
    end
end
fdm_signal = fdm_signal / max(abs(fdm_signal)); % Normalize FDM Signal

% Plot FDM Spectrum
figure;
hold on;  % Allow multiple plots on the same figure
for i = 1:length(f)
    plot(f{i}/1000, p{i});  % f{i}/1000 to convert to kHz
end
xlabel('Frequency (kHz)');   ylabel('Magnitude');  title('FDM Spectrum'); 
grid on;
legend(arrayfun(@(i) sprintf('Signal %d', i), 1:length(f), 'UniformOutput', false));
hold off;