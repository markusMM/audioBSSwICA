function [L] = LikeICA(W,x)
% 
%       Likelihood function for ICA algorithm
% 
% This function calculates the likelihood of a given ICA data.
% 
% W ... de-mixture matrix
% x ... zero-mean unit-variance of the mixed source
% 

szx = size(x)
if szx(2) < szx(1), x=x'; end

T = size(x,2);
%N = size(x,1);
% 
% if T == 1,
%     absW = abs(W);
% else
%     absW = abs(det(W));
% end
whos
L = log(abs(norm(W))) + (1/T)*sum(sum(log(1./cosh(abs(W*x)))));

return;
end