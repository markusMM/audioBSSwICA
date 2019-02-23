function [s,x,fs,nCh,fsx] = genSignDSP2(spNames,fs,N,N_flg)
% 
%   Generate Source Signals (DSP2)
% 
% This is a source signal generator out of multiple different file for each
% channel or randomly drawn values. It always draws N values of the
% original source, even if N was not set, it draws 10000 samples.
% 
% The signals will be read with another function named "audioin", which can
% automatically resample the files.
% 
% The N samples will also become zero-mean unit variance subtracted in the
% output x.
% 
% s   ... Ns unitary samples of the source signal
% 
% x   ... Nx unitary drawn zero-mean unit-variance samples of "s"
% 
% fs  ... sampling rate
% 
% nCh ... number of channels for the generated signal
% 
% N_flg - true -> Ns = number of source samples
%       - else -> Ns = Nx ... number of x samples
% 
% fsx ... sampling frequency of each sampled source
% 
% (C) Markus Meister, Universität Oldenburg
% 
if nargin < 4,
    N_flg = false;
end
if nargin < 2,
    fs = NaN;
end
if nargin < 3,
    N = NaN;
end

%fs = NaN;
nCh = numel(spNames);
Nn = zeros(nCh,1);
g = cell(nCh,1);

%% Quellsignale

for i = 1:nCh,
   
    if      strcmp(spNames{i},'gauss') || strcmp(spNames{i},'Gauss'),
        if isnan(N),
            warning('No sample number declared! N will be set to 10000.');
            Nr = 10000; 
        else
            Nr = N;
        end
        g{i}     = randn(1,Nr); Nn(i)=Nr;
    elseif  strcmp(spNames{i},'unit') || strcmp(spNames{i},'Unit'),
        if isnan(N),
            warning('No sample number declared! N will be set to 10000.');
            Nr = 10000; 
        else
            Nr = N;
        end
        g{i}     = rand( 1,Nr); Nn(i)=Nr;
    elseif  ~isnan(fs),
        g{i}     = audioin(spNames{i},fs);
        Nn(i)=size(g{i},2);
    else
       [g{i},fs] = audioin(spNames{i});
        Nn(i)=size(g{i},2);
    end
    
end

% maximum length of both channels
Nm = max(Nn);
if isnan(N),
    N_ = Nm;
else
    N_ = N;
end
x = zeros(nCh,N_);
s = zeros(nCh,Nm); if N_flg,s = zeros(nCh,N_);end
d = zeros(nCh,Nm);
for i = 1:nCh,
    whos
    % source signal (expanded with zeros if length doesn't fit)
    d = [g{i} zeros(1,Nm-Nn(i))];
    
    % N samples
    if ~isnan(N),
        u = g{i}(1,1:(fix(Nn(i)/N)):(fix(Nn(i)/N)*N));
    else
        u = g{i};
    end
    if N_flg, s(i,:) = u;else s(i,:) = d;end
    
    % Zero-Mean Unit-Variance
    x(i,:) = ( u - mean(u) )./sqrt(var(u));
    
    % new sampling frequency of x
    fsx{i} = fs*(N_/Nn(i));
end

return;
end