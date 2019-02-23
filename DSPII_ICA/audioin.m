function [s,fs,N] = audioin(fnm,fs,length)

[x,fs1] = audioread(fnm);

sz = size(x);
if sz(1) > sz(2), x = x'; sz = size(x); end

N = size(x,2);
C = size(x,1);

if nargin > 1 && ~isempty(fs),
    if      fs > fs1,
        for j = 1:C,
            s(j,:) = interp(x(j,:),fix(fs/fs1));
        end
    elseif  fs < fs1,
        for j = 1:C,
            s(j,:) = x( j, 1:fix(fs1/fs):N );
        end
    else
        s = x;
    end
else
    s=x;
    fs=fs1;
end
N = size(s,2);
if nargin <  3, length = N; end


if      N < length,
    s = [s;zeros(length-N,sz(2))]; N=length;
elseif  N > length,
    s = s(1:length); N=length;
end

return;
end