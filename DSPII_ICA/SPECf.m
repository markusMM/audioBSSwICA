function [mOSpec, vsFreq, vsTime] = SPECf(x, N, M, NC, fs, W)
% 
%       SPEC.m - Spektogrammfunktion
% 
% N     ... segment length
% M     ... time shift for the segments
% Q     ... output data
% S     ... spectogram
% x     ... input signal
% NC    ... number of fourier coefficients
% W     ... window function can be left blank
% 
%   Struktur
% 
%    1: Rahmenl�nge berechnen
%    2: Zeitskala bestimmen
%    3: FFT ohne Spiegelfreqz
%    4: nbit �bergeben
%    5: schleife pro Frame (start bis endi)
%       1 - S 	... Frequenz im Fenster mit NC
%       2 - Q.S ... Spektogramm mit �berlapp und NC
%    6: Jetzt: S ... Spektogramm
%    7: logarithmisches quadrat mit dBx(S^2) , S... Spektogramm
% 
%% 

if nargin < 6, W = hanning_(N); end

NFrames = round(1 + floor((length(x) - N) / M));
%Q.T = linspace(0,(numel(x)-1)/fs,NFrames); %time vector
Q.T   = ((0:(NFrames-1))*M/fs)';
%Q.F = fft(x,NC); %frequency vector
%Q.F = abs(Q.F(1:fix(NC/2))); %No mirror freqz
%Q.F = zeros(NFrames,1);
%Q.F = linspace(0,max(abs(fft(x,NC)).*fs/2),NFrames);
Q.F = (0:(NC - 1))'/ NC * fs/2;
%Q.n = n; %bit number audio sample
start = 1;
endi = start+N-1;
for xi=1:NFrames,
    S = fft(x(start:endi).*W',NC); %fft with mirror frequencies
    S = S(1:fix(NC/2)); %-> no mirror frequencies
    Q.S(1:fix(NC/2),xi) = S;
    start   = start+M;
    endi    = start+N-1;
end
%Q.SdB   = dBx(abs(Q.S).^2);
%S       = Q.SdB;
mOSpec = Q.S';
vsFreq = Q.F;
vsTime = Q.T;
