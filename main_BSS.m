clear('all','hidden');clf
close('all','hidden');clc
% DSP Blockpraktikum II
% 
%      7. Blind Source Separation using Gradient MLE
% 
% Here two channel audio cature test were run. There test signals always
% had two dominant signals present overlapping in time.
% 
% The BSS is running using 
% 
% 

addpath 'DSPII_ICA';
%% reading source signals

% saNames = {...
%     'audio/13-14_X1.wav','audio/13-14_X2.wav'...
%     };
% 
% for i = 1:size(saNames,1),
%     nms = saNames(i,:);
%     [s{i},x_z1{i},fs{i},nCh{i}] = genSignDSP2(nms);
%     x{i} = zmean_uvar(s{i});
% end
% nSig = size(saNames,1);

[s{1},fs{1}] = audioin('audio/160318_02.WAV');
[nCh{1},N] = size(s{1})
% x = zero mean unnit variance of s
x{1} = zmean_uvar(s{1});
nSig = 1;

% substring for plot names
revstrg = '_Lreverb';

% params gradient optimization function
di=.1;
nI=100;

for i = 1:nSig
    
    x_ = x{i};
    
    % params STFT
    fs_     =  fs{i}
    nFFT    = fix((fs_/1000).^2)
    nW      = fix(nFFT/2)
    nWShift = fix(nW/2)
    
    % params MLE
    Winit = repmat(eye(2,2),1,1,nW+1);
    MLEparam = {Winit,di,nI,[],[],1};
    
    [y{i},Yf{i},W{i},L{i},gParam{i}] = ...
        gradBSS(x_,fs_,nFFT,nWShift,nW,MLEparam);

end

%% soundsc - listen to the output

bdur = 0.6; %[s]

bep1 = @(fs) .6*sin( 4000/fs*((-fs*bdur/2):(fs*bdur/2)) )...
           + .6*cos( 6000/fs*( .5*(0:(fs*bdur)) - .5*((fs*bdur):-2:(-fs*bdur)) ) );
bep2 = @(fs) .6*sin( 4000/fs*((-fs*bdur/2):(fs*bdur/2)) )...
           + .6*cos( 6000/fs*( .5*(0:(fs*bdur)) - .5*(0:-4:(-4*fs*bdur)) ) );

% signals
soundsc([...
         s{1}(1,:) bep1(fs_) s{1}(2,:)...
         bep2(fs_)...
         y{1}(1,:) bep1(fs_) y{1}(2,:)...
        ],fs_);

    
% observed signal
%soundsc(x,fs_);
    
% separated signals (mono)
%soundsc(y{1}(1,:),fs_);
%soundsc(y{1}(2,:),fs_);



%% plots
%spectrograms 


figure('name',sprintf('SpecBSS%s',revstrg))
hold on
for i = 1:nCh{1}

    [X(:,:,i),freq,time] = spec(x(i,:),'hanning',[fs_,nFFT,nWShift,nW]);
    
    %observed channels
    subplot(2,2,i)
    imagesc(time,freq/1000,log(abs(X(:,:,i))))
    axis xy
    title(sprintf('Observed Channel #%i',i))
    xlabel('time [s]')
    ylabel('freqency [kHz]')
    
    %separated channels
    subplot(2,2,i+2)
    imagesc(time,freq/1000,log(abs(Yf{1}(:,:,i)')))
    axis xy
    title(sprintf('Speparated Channel #%i',i))
    xlabel('time [s]')
    ylabel('freqency [kHz]')
    
end
hold off
print(gcf,['figures/' get(gcf,'name')],'-depsc','-tiff');


%logLikelihood
figure('name',sprintf('logLikelihoodBSSf%s',revstrg))
imagesc((0:size(L{1},1)),freq/1000,L{1}')
axis xy
colorbar
title('log-Likelihood of the BSS for each Bin across Iterations')
xlabel('iterations [i]')
ylabel('freqency [kHz]')
print(gcf,['figures/' get(gcf,'name')],'-depsc','-tiff');

