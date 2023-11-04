function blossom = deCasteljau(d,b,tau)
% De Casteljau algorithm for m=2 of any degree d
%  b is a (d+1)x(d+1) matrix with the coefficients
% tau is a (dx3) table with d barycentric coordinates
% blossom is the polynomial blossom value, for coefficients b and
% parameters tau
for r = 1:d
    for row = 1:(d-r+1)
        for col = 1:(d-r+1)
            b(row,col) = tau(r,1)*b(row,col) + tau(r,2)*b(row,col+1) + tau(r,3)*b(row+1,col);
        end
    end
end
blossom = b(1,1);
end