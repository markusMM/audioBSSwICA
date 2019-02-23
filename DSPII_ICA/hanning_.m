 function w = hanning_(n);
%
%    function w = hanning_(n);
%
% returns the n-point Hanning window in a column vector.
% Formular is 0.5 - 0.5*cos(2*pi*(0:N-1)'/N) where N
% equals fix(n).
%
% See Also : hanning (sig. proc. toolbox)
%
% author / date : jens-e. appell / 1.95
%
N = fix(n);
w = .5*(1-cos(2*pi*(0:N-1)'/N));
return;
%%-------------------------------------------------------------------------
%%
%%	Copyright (C) 1995   	Jens-E. Appell, Carl-von-Ossietzky-Universitat
%%	
%%	Permission to use, copy, and distribute this software/file and its
%%	documentation for any purpose without permission by the author
%%	is strictly forbidden.
%%
%%	Permission to modify the software is granted, but not the right to
%%	distribute the modified code.
%%
%%	This software is provided "as is" without express or implied warranty.
%%
%%
%%	AUTHOR
%%
%%		Jens-E. Appell
%%		Carl-von-Ossietzky-Universitat
%%		Fachbereich 8, AG Medizinische Physik
%%		26111 Oldenburg
%%		Germany
%%
%%		e-mail:		jens@hinz.physik.uni-oldenburg.de
%%
%%-------------------------------------------------------------------------
