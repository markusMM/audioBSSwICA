function [x,mue,vrc] = zmean_uvar(s)
% 
%   Zero-Mean Unit-Variance Funktion
% 
% A  ... transformation matrix
% vrc... covariance := diag(var)
% mue... mean
% s  ... source
% x  ... output
% 

%% init

sz = size(s);
if sz(1) > sz(2), s = s'; sz = size(s); end

mue = est(s);
vrc = var(s,[],2);
std = sqrt(vrc);


%% x

x = (s-repmat(mue,1,sz(2)))./repmat(std,1,sz(2));

return;
end
%% estimation value function
function [e] = est(s,w)

sz = size(s);

if sz(1) > sz(2),
    s = s';
    if nargin >= 2, w = w';end
end

if nargin < 2,
    e = (1/sz(2)).*sum(s,2);
else
    e = sum(s(1,:).*w(1,:));
end

end