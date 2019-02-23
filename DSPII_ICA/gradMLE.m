function [W,y,L] = gradMLE(x,W,di,nI,nflg,pflg,wnormFlag,convFlag,dLmin)
% 
%   MLE Optimization using Gradient for ICA
% 
% f(y) = c/cosh(y)
% 
% W    ... parameter for ICA (transformation matrix) 
%          #Note: The input is the initial W
% L    ... log-likelihood for W on x with nI+1 entries.
%          The  first entry is the initial W
% x    ... (normalized) source signal
% di   ... iteration step size
% nI   ... iteration limit (def::250)
% nflg ... flag if using natural gradient
% ...
%   if nflg is not set it automaticall chooses the natural gradient
%   if nflg is zero it uses the normal gradient
% 
% pflg ... flag if plotting the log likelihood (def::false)
% 
% optional: wnormFlag (def::1)
%           ...
%             if the rows of the optimized W matrix shall be normed
%           
%           convFlag (def::0)
%           ...
%             if running until convergence with nI as max. iteration lim.
%           
%           dLmin (def::2*eps)
%           ...
%             if running until convergence with dLmin is the convergence
%             criteria.
% 
% 
% (c) Markus Meister, University of Oldenburg (Olb) Germany
% 

%% preset for unset parameters

if nargin < 2 || isempty(x),
    error('No source signal! You need the source signal!');
end
if nargin < 3 && iscell(W),
    Wx   = W; clear W;
    W    = Wx{1};
    di   = Wx{2};
    nI   = Wx{3};
    nflg = Wx{4};
    pflg = Wx{5};
end
if nargin < 3 || isempty(di),
    di = .25;
end
if nargin < 4 || isempty(nI),
    nI = 250;
end
if nargin < 5 || isempty(nflg),
    nflg = 1;
end
if nargin < 6 || isempty(nflg),
    pflg = 0;
end
if nargin < 7 || isempty(wnormFlag),
    wnormFlag = 1;
end
if nargin < 8 || isempty(convFlag),
    convFlag = 0;
end
if nargin < 9 || isempty(dLmin),
    dLmin = 2*eps;
end

szw = size(W);
szx = size(x);

if szx(2) < szx(1), x=x'; end


% if szx(1) ~= szw(2),
%     error([...
%         'Dimension mismatch of W and x! '...
%         'W needs to be an MxM and x an MxN matrix!'...
%         ]);
% end
%% init log-likelihood (if desired)

if nargout > 2 || pflg,
    L = zeros(1,nI+1);
    % initial log-likelihood
    L(1) = LikeICA(W,x);
end

%% calculation loop


for i=1:nI

    % pre calc of y
    y=W*x;
    
    if nflg,
        
        % normal  gradient
        dL = grdnL(W,y);

    else

        % natural gradient
        dL = gradL(W,y);

    end
    
    W = W + di.*dL;

    
    % log - likelihood (if desired)
    if ~isempty(L),
        L(i+1) = LikeICA(W,x);
    end
    
    % convergence break (if desired)
    if convFlag,
        if dL <= dLmin,
            break;
        end
    end
    
end

%normalization of the rows of W_opt (if desired)
if wnormFlag %&& nflg, 
	for i = 1:size(W,1), W(i,:) = W(i,:)./norm(W(i,:));end 
end

%% final separation

y = W*x;

%% plot for the log-likelihood, if desired
if pflg,
    
    figure('name','Log-Likelihood')
    plot(L)
    xlabel('Iterations');
    ylabel('log-likelihood');
    if nflg,
        title('Log-likelihood for W*x (natural gradient method)')
    else
        title('Log-likelihood for W*x (normal  gradient method)')
    end
    
end

return;
end
%% Gradient grdnL ... natural, gradL ... normal
function dL = gradL(W,y)
    dL = ( eye(size(y,1)) - (1/size(y,2)).*vf(y)*y' )/W';
end
function dL = grdnL(W,y)
    dL = ( eye(size(y,1)) - (1/size(y,2)).*vf(y)*y' )*W;
end
%% v(y) 
function vf = vf(y)
    vf = sign(y).*tanh(abs(y));
end