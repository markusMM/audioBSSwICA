function [k] = kurt(x,nflag)
% 
%   Kurtosis
% 
% x     ... samples
% nflag ... if taking the kurtosis without "-3"
% k     ... kurtosis
% 
% 
% 
% (c) Markus Meister, University of Oldenburg (Olb.)
% 


if nargin < 2, nflag = 0; end

sz = size(x);

N = sz(2);
C = sz(1);

if N < C,
    x=x.';
    n = N;
    N = C;
    C = n;
end

mue = repmat(mean(x,2),1,N);

k = (sum((x-mue).^4,2)./N)./(sum((x-mue).^2,2)./N).^2-repmat(3*~nflag,C,1);

k = k';

% at the end the same as
%k = kurtosis(x) - 3;

return;
end
