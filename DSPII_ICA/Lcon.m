function [c,ceq] = Lcon(W,x)
% 
%   Likelihood Constraint for ICA with f(Wx) = sech(Wx)
% 
% f ... PDF
% 
% sum(f) over all samples shall be I
% 

sz = size(x);

c = -sum((1./cosh(W*x))')';
ceq = diag(ones(1,sz(2)));

end