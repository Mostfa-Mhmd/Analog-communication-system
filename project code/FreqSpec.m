function [f, p]= FreqSpec(m, fs)
l= length(m);
M= fft(m);
f= fs*(-l/2:l/2-1) / l;
M_shifted= fftshift(M); % Shift zero-frequency component to center
p= abs(M_shifted) / l;
p = abs(p) / max(abs(p));
end