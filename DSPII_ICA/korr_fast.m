function [k] = korr_fast(x,y)
% if      nargin < 1 && ~exist('ans','var'),
%     error('Not enough input!');
% elseif  nargin < 1,
%     x = ans;
% end;

if nargin < 2, y = x; end

x=x(:); y=y(:);
if isreal(x) && isreal(y), Re = true; end
n1 = size(x); n2 = size(y);
nm = max(n1(1),n2(1)); %nn = min(n1(1),n2(1));

if n2(1) > n1(1),
	x = [x;zeros(n2(1)-n1(1),1)];
else
	y = [y;zeros(n1(1)-n2(1),1)];
end;

X = fft(x,2^nextpow2(2*nm(1)-1));
Y = fft(y,2^nextpow2(2*nm(1)-1));

k = ifft(X.*conj(Y));

k = [k((end-nm+2):end);k(1:nm)];
if Re, k = real(k); end

return;
end
%{

 -- Schnelle Faltung -- 

Vorgänge:

-Eingangsvectoren in : Form bringen
-Die Dimensionen bestimmen von y, x und die Maximallänge
-Das Kürzere Signal mit Nullen auf die gleiche Länge bringen
    (Vorsicht: Sorgt, wenn N(x) ungleich N(y) Nullränder!)
-Beide Signale in den Fourier-Raum übertragen
    mit 2^(dem nächsten Vielfachen von 2 von l_{max}) Fourierkoeffs.
-inverse FFT des hadamard-Betragsquadrates beider FFT
-Nauanordnung der Lsg-menge (die Menge wurde verschoben/gewrappt)
    +autom. Weglassen der Nullen, die zu viel sind

%}