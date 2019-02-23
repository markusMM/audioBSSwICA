% 
% 	Main Script - Testing Multi ICA
% 
% 
% 
% (c) Markus Meister
% 

close all;clf
clear all;clc

addpath 'DSPII_ICA';

%% reading source signals

% saNames = {...
%     'audio/13-14_X1.wav','audio/13-14_X2.wav'...
%     };
% 
% for i = 1:size(saNames,1),
%     nms = saNames(i,:);
%     [s{i},x_z1{i},fs{i},nCh{i}] = genSignDSP2(nms,16000);
%     x{i} = zmean_uvar(s{i});
% end
% nSig = size(saNames,1);

[s,fs] = audioin('audio/160318_02.WAV');
[nCh,N] = size(s);
x = zmean_uvar(s);


%% init

% params NWK
fparam.n_hidden = [2 4];
fparam.n_target = [2];
fparam.n_layers =  2 + numel(fparam.n_hidden);
fparam.eta_ICAs = .02;
fparam.dark_art =  '';


% params STFT
fs_     =  fs
nFFT    = fix((fs_/1000).^2)
nW      = fix(nFFT/2)
nWShift = fix(nW/2)
    
% params ICA
di=.25;
nI=30;
Winit = repmat(eye(2,2),1,1,fix(nFFT/2)+1);
MLEparam = {Winit,di,nI,[],[],1};

%  STFT ----------------------------------------------/
for i = 1:nCh,
    [Y(i,:,:), vsFreq(i,:), vsTime(i,:)] ...
     = spec(x(i,:)', 'han', [fs nFFT nWShift nW]);
end % ------------------------------------------------/


% Multi ICA ------------------------------------------/
[Yend,Wend,Like] = multiICA(Y,MLEparam,fparam);
% ----------------------------------------------------/

% Output Layers --------------------------------------/
% ----------------------------------------------------/


% ISTFT ----------------------------------------------/
for i = 1:size(Yend,3),
    %Yi = squeeze(Yend(:,:,i)); %size(Yi)
    y(i,:) = ovadd(Yend(:,:,i)','han',[fs nFFT nWShift nW 0]);
end % ------------------------------------------------/


%% soundsc - listen to the output

n_target = fparam.n_target;

bdur = 0.6; %[s]

bep1 = @(fs) .6*sin( 4000/fs*((-fs*bdur/2):(fs*bdur/2)) )...
           + .6*cos( 6000/fs*( .5*(0:(fs*bdur)) - .5*((fs*bdur):-2:(-fs*bdur)) ) );
bep2 = @(fs) .6*sin( 4000/fs*((-fs*bdur/2):(fs*bdur/2)) )...
           + .6*cos( 6000/fs*( .5*(0:(fs*bdur)) - .5*(0:-4:(-4*fs*bdur)) ) );

nodestr = 'bep2(fs_)';   
for n = 1:n_target,
    
    nodestr = [ nodestr sprintf(' y(%i,:) bep1(fs_)',n) ];
    
end
nodestr = nodestr(1:end-10);

% signals
eval(sprintf('soundsc([s(1,:) bep1(fs_) s(2,:) %s],fs_);',nodestr));

%% save results

if ~exist('results','dir'), mkdir('results'); end

results = dir('results');
kk = 0;
for jk = 3:numel(results),
    if strcmp(results(jk).name(1:3),'res'),
        if kk < str2num(results(jk).name(4:5)),
           kk = str2num(results(jk).name(4:5));
        end
    end
end

kk = kk+1;
if   kk/10 < 1,
     ks = ['0' num2str(kk)];
else
     ks =      num2str(kk) ;
end

res.Yf = Y;
res.Yend = Yend;
res.s = s;
res.x = x;
res.W = Wend;
res.y = y;

save(sprintf('results/res%s.mat',ks),'-struct','res');