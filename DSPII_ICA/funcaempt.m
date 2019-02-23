function [w,a] = funcaempt(c)

if isempty(c),
    w = 0;
    a = 'c is not set.';
else
    w = 1;
    a = 'c is set.';
end

return;
end