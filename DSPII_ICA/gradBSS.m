function [y,Yf,W,L,gParam] = gradBSS(x,fs,nFFT,nWShift,nW,MLEparam)
% 
%   Gradient Blind Source Separation
% 
% This function separates an multichannel mixed source signal into its
% components using the ICA algorithm with the gradient MLE optimization.
% 

W    = MLEparam{1};
di   = MLEparam{2};
nI   = MLEparam{3};
nflg = MLEparam{4};
pflg = MLEparam{5};

nCh = size(x,1);
%T   = size(x,2);

for i = 1:nCh,
    [Xf(i,:,:), vsFreq(i,:), vsTime(i,:)] ...
     = spec(x(i,:)', 'han', [fs nFFT nWShift nW]);
     %= SPECf(x, size(x,2), nWShift, nW, fs)
end

% Maximum Likelihood Estimator loop (gradient method)
h_wait = waitbar(0,'Loading...');   % wait bar 
for k = 1:fix(nFFT/2)+1,
    xk = squeeze(Xf(:,k,:)); %size(xk)
    [W(:,:,k),Yf(:,:,k),L(:,k)]...
        = gradMLE(xk,W(:,:,k),di,nI,nflg,pflg);
    waitbar(k/(fix(nFFT/2)+1)); % wait bar
end
close(h_wait)

for i = 1:nCh,
    Yi = squeeze(Yf(i,:,:)); %size(Yi)
    y(i,:) = ovadd(Yi.','han',[fs nFFT nWShift nW 0]);
end

gParam = {vsFreq vsTime};

Yf = permute(Yf,[2,3,1]);

return;
end