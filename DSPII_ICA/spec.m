function [mOSpec, vsFreq, vsTime] = spec(vISig, vcWType, vParam)

%
%   function [mOSpec, vsFreq, vsTime] = spec(vISig, vcWType, vParam);
%
% A Spectogram will be calculated from 'vISig'.
%
% The frames in mOSpec will
% have 'Nfft' Samples if 'vISig' is imaginary and 'Nfft/2+1' (or
% '(Nfft+1)/2') if vISig is purely real and 'Nfft' is even (or odd).
%
% vISig  : Input Signal vector.
% vcWType: Window function 'han', 'ham', 'rec'.
%          (optional, default 'han')
%          If length(vcWType(:,1)) == nFFT vcWType includes 2 window vectors:
%          vcWType(1:nW,1) then is the input window vector and
%          vcWType(1:nFFT,2) then is the output window vector. This option has
%          been included for window optimisation purpose.
% vParam : Set of parameters for OVL
%          vParam = [FSamp nFFT nWShift nW alDB aoWOut]
%          where:
%             FSamp   : Sampling frequency
%             nFFT    : length for FFT in samples
%             nWShift : Window shift in samples
%             nW      : length of the window function in samples
%            (optional, default [48000 2048 512 1024])
% mOSpec : Output spectogram.
% vsFreq : Frequency scale for spectogram.
% vsTime : Time scale for spectogram.
%
% See also : ovl-routines, specgram
%
% author / date : jens-e. appell / 1.95
% modified by ~ane, 26.1.99
	 
	 
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % get input Parameters
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 if nargin < 3,
		 vParam = [48000 2048 512 1024];
		 if nargin < 2,
			 vcWType = 'han';
			 if nargin < 1;
				 error('ovl(): Missing Arguments');
			 end;
		 end;
	 end;

	 FSamp   = vParam(1);
	 nFFT    = vParam(2);
	 nWShift = vParam(3);
	 nW      = vParam(4);
	 clear vParam;
	 
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % make windowed-time-frames
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
	 % create frame matrix
	 nCol      = floor((length(vISig)-nW)/nWShift)+1;		% number of cols/frames
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
		 if     strcmp(vcWType(1:3),'han'),
			 vW = hanning(nW);
		 elseif strcmp(vcWType(1:3),'ham'),
			 vW = hamming(nW);
		 elseif strcmp(vcWType(1:3),'rec'),
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
	 
	 % windowing of frames
	 mISigW  = vW(:,ones(1,nCol)).* mISigW;
	 clear vW
	 
	 % pad zeros at beginning and end
	 nPad      = nFFT-nW;
	 nlPad     = fix(nPad/2);
	 mISigW    = [zeros(nlPad,nCol); mISigW; zeros(nPad-nlPad,nCol)];
	 clear nPad;
	 clear nlPad;
	 
	 % time scales
%	 vsWTime  = ((0:(nFFT-1))/FSamp)';
	 vsTime   = ((0:(nCol-1))*nWShift/FSamp)';
%	 nTime		= length(vsTime); % nTime == 1 -> only one frame
	 
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % calculate input-spectrums
	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 oInSigReal = ~any(any(imag(mISigW)));
	 mOSpec     = fft(mISigW)/nFFT;
	 clear mISigW;
	 
	 if  oInSigReal
		 if rem(nFFT,2),    					% nfft odd
             select = 1:(nFFT+1)/2;
         else   								% nfft even
			 select = 1:nFFT/2+1;
         end;
		 % spectrum must be multiplied by two to keep the total energy
		 mOSpec = mOSpec(select,:) *  2;%^(1/2);
		 vsFreq = (select-1) / nFFT * FSamp;
		 clear select;
     else
		 vsFreq = (0:(nFFT - 1))'/ nFFT * FSamp;
     end
     
return;
end

