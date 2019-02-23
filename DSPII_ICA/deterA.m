function [D,L,U,s] = deterA(A)

[L,U] = lu(A);
s = det(L);
D = s*prod(diag(U));

return;
end