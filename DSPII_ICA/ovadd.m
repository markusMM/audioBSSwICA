
function [vOSig] = ovadd(mISpec, vcWType, vParam);

%
%    function [vOSig, mOSpec, mISpec, vsFreq, vsTime] =
%                        ovl(vISig, vcFunc, vcWType, vParam, OvlStage);
%
% Overlapp-Add-Rotutine (OVL). 
%
% vcWType: Window function 'han', 'ham', 'rec'.
%          (optional, default 'han')
%          If length(vcWType(:,1)) == nFFT vcWType includes 2 window vectors:
%          vcWType(1:nW,1) then is the input window vector and
%          vcWType(1:nFFT,2) then is the output window vector. This option has
%          been included for window optimisation purpose.
% vParam : Set of parameters for OVL
%          vParam = [FSamp nFFT nWShift nW aoWOut]
%          where:
%             FSamp  : Sampling frequency
%             nFFT    : length for FFT in samples
%             nWShift : Window shift in samples
%             nW      : length of the window function in samples
%             aoWOut  : aoWOut == 1 -> output Time Signal will be
%                       windowed with a hanning window (factor 1
%                       for nW samples, hanning window for the
%                       aliasing parts of the time signal after
%                       processing with 'vcFunc'. If nW == nFFT
%                       the length of the hanning window will be
%                       nFFT).
%            (optional, default [48000 2048 512 1024 0])
% vOSig  : Output signal.
% mISpec : Input spectogram.
%
% See also : ovl-routines, specgram
%
% author / date : jens-e. appell / 1.95
%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% get input Parameters
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 3,
		vParam = [48000 2048 512 1024 0];
		if nargin < 2,
			vcWType = 'han';
			if nargin < 1;
				error('ovl(): Missing Arguments');
			end;
		end;
	end;

	FSamp  = vParam(1);
	nFFT    = vParam(2);
	nWShift = vParam(3);
	nW      = vParam(4);
	aoWOut  = vParam(5);
	clear vParam;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% make windowed-time-frames
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% create frame matrix
	nCol      = size(mISpec,2);
 	viRow     = (1:nW)';								% indices along one row
 	viCol     = (0:(nCol-1)) * nWShift;					% start indices for each col
 	vISig(nW + viCol(nCol))   = 0;       				% pad zeros to make all indices accesible
 	mISigW    = zeros(nW,nCol);							% create matrix dimensions for vISigW
 	mISigW(:) = vISig( viRow(:,ones(1,nCol)) + viCol(ones(nW,1),:));
 	clear vISig;
 	clear viRow;
 	clear viCol;
 
	% create window vector
	if length(vcWType(:,1)) == nFFT,
		vW = vcWType(1:nW,1);
	else
		if vcWType == 'han',
			vW = hanning_(nW);
		elseif vcWType == 'ham',
			vW = hamming(nW);
		elseif vcWType == 'rec',
			vW = ones(nW,1);
		end;
	end;

	% calibrate window:
	% because of zero padding the intensity must be 
	% divided by (nW/nFFT).
	% Because of the window function the intensity must
	% be divided by (sum(vW.^2)/nW).
	% Due to the whole windowing this results in an
	% intensity division by (sum(vW.^2)/nFFT).
	% applied to the amplitude the root must be taken.
	WindowCal = ((sum(vW.^2)/nFFT).^.5);
	vW = vW / WindowCal;


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Inverse FFT
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	oInSigReal=1;
	if oInSigReal,
		mISpec  = mISpec / 2^(1/2);				% divid by two to keep energy
		if rem(nFFT,2),    					% nFFT odd
			mISpec2 = [mISpec ; flipud( real(mISpec(2:((nFFT+1)/2),:))-i*imag(mISpec(2:((nFFT+1)/2),:)) )];
		else										% nFFT even
			mISpec2 = [mISpec ; flipud( real(mISpec(2:(nFFT/2),:))-i*imag(mISpec(2:(nFFT/2),:)) )];
		end;
	else,
		mISpec2 = mISpec;
	end;
	
	mOSigW = real(ifft(mISpec2))  * ((2 * nWShift / nW) * (WindowCal * nFFT));
	clear mISpec2;
	
	if nargout < 2,
		clear mISpec;
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% window output frames
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if aoWOut == 1,
		if length(vcWType(:,2)) == nFFT,
			vHanW = vcWType(1:nFFT,2);
		else
			nHan = nFFT-nW;
			if nHan == 0,
				vHanW = (hanning_(nFFT)).^.5;
			else,
				vHanW = hanning_(nHan);
				n     = fix(nHan/2);
				vHanW = [vHanW(1:n); ones(nW,1) ; vHanW(n+1:nHan)];
			end;
		end;
		mOSigW = mOSigW .* vHanW(:,ones(1,nCol));
	end;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% create output time signal
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% in this case the for loop saves memory because otherwise
	% ceil(wlen / wshift) * siglen floats + indice vectors have
	% to be allocated.
	vOSig = zeros( (nCol-1)*nWShift+nFFT ,1);
	for(Ind=1:nCol),
		il = (Ind-1)*nWShift+1;
		ih = il+nFFT-1;
		vOSig(il:ih) = mOSigW(:,Ind) + vOSig(il:ih);
	end;
	
	% realign output time signal, ~ane
	N=fix((nFFT-nW)/2);
	l=(nCol-1)*nWShift+nW;
	vOSig=vOSig((N+1):(N+l));
	
	return;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% changes :
	%
	%   30.01.95/ja: - hanning.m (sig. proc. toolbox) replaced by
	%                  hanning_.m (less reconstruction error when calculating
	%                  output vs output-input signal, old ver -50dB, new ver -300dB !!!).
	%                - some changes in respect to funny matlab indexing (x(1.5) == x(2)).
	%                - better calculation error plot for window overlap 1/4, 1/8, ...
	%   31.01.95/ja: - Bug fix for nWShift == nW/4. (carefull with specgram.m
	%                  (sig.proc.toolbox) which still might have the same bug)
	%                - ovl_win.m pasted in ovl.m
	%                - length of Output-hanning-window for nW==nFFT set to nFFT.  
	%    7.03.95/ja: - less waiting for keys if bPlotPause == 1
	%    8.03.95/ja: - Calibration of input signal frames due to window function
	%                  and number of zeros padded.
	%    5.04.95/ja: - Calibration due to window shift (exact for hanning window)
	%                - vcFunc == 0,1,2 changed in OvlStage
	%   10.04.95/ja: - input signal vector padded with zeros to make enough indices
	%                  accessible. ovl() will no longer shorten the input signal.
	%   04.05.95/ja: - vcWType now may include the window function itself. In that case
	%                  vcWType(1:nW,1) is the input window vector and
	%                  vcWType(1:nFFT,2) is the output window vector.
	%   31.05.95/ja/mm: - for real input signals only half of the spectrum is given
	%                  to 'vcFunc', therefore the amplitude has to be multiplied
	%                  by root(2) before 'vcFunc' and divided by root(2) after 'vcFunc'
	%   26.01.99/ane:   - ceil -> floor in nCol calculation (now in
	%                     spec.m)
	%                   - realign output signal to be in sync with original signal
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
