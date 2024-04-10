function [Yend,W,Like] = multiICA(Y,MLEparam,fparam)
% 
%       Multi - ICA
% 
% An ICA overlay to use a specific ICA function on multiple layers using a
% neural structure, similar to a neural network but with ICA update rules.
% 
% 

addpath 'DSPII_ICA';

% if nargin < 1,
%     global Y
%     if ~isempty(Y),
%     fparam.n_hidden = [2];
%     fparam.n_target = [4];
%     fparam.n_layers = 2 + numel(n_hidden);
%     fparam.eta_ICAs = .02;
%     end
% end

n_hidden = fparam.n_hidden;
n_target = fparam.n_target;
n_layers = fparam.n_layers;
eta_ICAs = fparam.eta_ICAs;
dark_art = fparam.dark_art;



W_    = MLEparam{1};
di   = MLEparam{2};
nI   = MLEparam{3};
nflg = MLEparam{4};
pflg = MLEparam{5};

nCh  = size(Y,1);
%Tau  = size(Y,2);

n_nodes = [nCh n_hidden n_target];

nFFT2 = size(Y,2);

g = cell(n_layers,1);
W    = g;
Like = g;
Yf   = g;

%% init

if ~isempty(W_),
    if  numel(W_)  == n_layers,   W    =   W_;     end
    if  size(W_,1) == nCh,        W{1} =   W_;     
     for l = 2 : n_layers-1,      W{l} =   ...
         repmat(randn(n_nodes(l+1),n_nodes(l)),1,1,nFFT2);
     end
    end
else
    W{1} = repmat(eye(2,2),1,1,fix(nFFT/2)+1);
     for l = 2:n_layers-1,        W{l} =   ...
         repmat(randn(n_nodes(l+1),n_nodes(l)),1,1,nFFT2);
     end
end

%% process


if strcmp(  dark_art,'simple'  ) || strcmp(  dark_art,'none'  )...
|| isempty( dark_art ),

Yf{1} = Y;
for l = 1:n_layers-1

    % Maximum Likelihood Estimator loop (gradient method)
    h_wait = waitbar(0,'Loading...');   % wait bar 
    for k = 1:nFFT2,
        Yk = squeeze(Yf{l}(:,k,:)); %size(xk)
        [W{l}(:,:,k),Yf{l+1}(:,:,k),Like{l}(:,k)]...
           = gradMLE(Yk,W{l}(:,:,k),di,nI,nflg,pflg);
        waitbar(k/nFFT2); % wait bar
    end
    close(h_wait)

    Yf{l+1} = permute(Yf{l+1},[2,3,1]);

end

end

Yend = Yf{end};


return;
end
