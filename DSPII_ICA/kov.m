function [R] = kov(x)
% 
%   Kovarianzmatrizenfunktion
% 
% 
% 
% 


nCh = numel(x(:,1));
N  = numel(x(1,:));

for i=1:nCh,
    xm(i) = mittel(x(i,:));
end

R = (1/(N))*(x-repmat(xm',1,N))*(x-repmat(xm',1,N))';

%R = [var(x(1,:)) cov(x(1,:),x(2,:))'; var(x(2,:)) cov(x(2,:),x(1,:))'];

return;
end

% mittelwert
function [m] = mittel(x) 

m = sum(x)/numel(x);

end