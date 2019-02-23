function [s,x,fs,nCh] = genSignDSP2_(spNames,fs,N,Idata)
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
% s   ... source signal
% 
% x   ... N unitary drawn zero-mean unit-variance samples of "s"
% 
% fs  ... sampling rate
% 
% nCh ... number of channels for (each) generated signal
% 
% (C) Markus Meister, Universität Oldenburg
% 

if nargin  < 2 || isempty(fs),
    fs = NaN;
end
if nargin  < 3 || isempty(N),
    N = NaN;
end
if nargin >= 4 && isempty(Idata),
    s   =   Idata.s;
    x   =   Idata.x;
    fs  =   Idata.fs;
    nCh =   Idata.nCh;
    Int =   Idata.Int;
    cN  =   Idata.cN;
else
    Int =   0;
    cN  =   1;
end

%fs = NaN;
nCh = numel(spNames);
Nn = [];
g = cell(nCh,1);
cN_flag = false;
%% Quellsignale
tag = '';
for i = 1:nCh,
   
    if      strcmp(spNames{i},'gauss') || strcmp(spNames{i},'Gauss'),
        if ~isempty(tag) && ~strcmp(tag,'gauss'),
            cN_flag = true;
            Int = i-1;
            nCh = i-1;
            break;
        end
        if isnan(N),
            warning('No sample number declared! N will be set to 10000.');
            Nr = 10000; 
        else
            Nr = N;
        end
        g{i}     = randn(1,Nr); Nn(i)=Nr;
        tag = 'gauss';
    elseif  strcmp(spNames{i},'unit') || strcmp(spNames{i},'Unit'),
        if ~isempty(tag) && ~strcmp(tag,'unit'),
            cN_flag = true;
            Int = i-1;
            nCh = i-1;
            break;
        end
        if isnan(N),
            warning('No sample number declared! N will be set to 10000.');
            Nr = 10000; 
        else
            Nr = N;
        end
        g{i}     = rand( 1,Nr); Nn(i)=Nr;
        tag = 'unit';
    elseif  ~isnan(fs),
        if ~isempty(tag) && ~strcmp(tag,'speak'),
            cN_flag = true;
            Int = i-1;
            nCh = i-1;
            break;
        end
        g{i}     = audioin(spNames{i},fs);
        Nn(end+1)=size(g{i},2);
        tag = 'speak';
    else
        if ~isempty(tag) && ~strcmp(tag,'speak'),
            cN_flag = true;
            Int = i-1;
            nCh = i-1;
            break;
        end
       [g{i},fs] = audioin(spNames{i});
        Nn(end+1)=size(g{i},2);
        tag = 'speak';
    end
    
end

% maximum length of both channels
Nm = min(Nn);
s{cN} = zeros(nCh-Int,Nm);
if isnan(N),
    N_ = Nm;
else
    N_ = N;
end
x{cN} = zeros(nCh-Int,N_);
for i = 1:nCh,
    whos
    disp(Int)
    disp(i)
    disp(size(g{i}));
    % source signal (cut if length does not fit)
    g{i} = g{i}(1,1:Nm);
    %Nm = size(g{i},2); % getting the size
    s{cN}(i,:) = g{i};
    
    % N samples
    if ~isnan(N),
        u = g{i}(1,1:(fix(Nm/N)):(fix(Nm/N)*N));
        szu = size(u,2);
        if szu < N,
            u = [u zeros(1,N-szu)];
        end
    else
        u = g{i};
    end
    % Zero-Mean Unit-Variance
    x{cN}(i,:) = ( u - mean(u) )./sqrt(var(u));

end

if cN_flag,
    Idata.cN  = cN+1;
    Idata.fs  = fs;
    Idata.nCh = Int;
    Idata.Int = Int;
    Idata.x   = x;
    Idata.s   = s;
    spNames = spNames(Int+1:end);
    [s,x,fs,nCh] = genSignDSP2(spNames,fs,N,Idata);
    
end

return;
end