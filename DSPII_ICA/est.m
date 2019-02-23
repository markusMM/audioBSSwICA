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

return;
end