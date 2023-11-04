function Z = bpolyval(B,T,X,Y)
% Description:
%  bpolyval computes the values of a polynomial in two variables specified
%  in the Bernstein-Bezier representation with respect to a domain triangle
%
% Definition:
%  Z = bpolyval(B,T,X,Y)
%
% Input parameters:
%  B    table of size d+1 x d+1 representing the coefficients of a
%       polynomial in two variables of degree d in the Bernstein-Bezier
%       form (table entry at position (i,j), j <= n+2-i, determines the
%       polynomial coefficient with index (d+2-i-j, j-1, i-1)),
%  T    table of size 3 x 2, each row of which specifies the Cartesian
%       coordinates of a vertex of the domain triangle
%  X,Y  tables of x and y coordinates at which the polynomial is being
%       evaluated
%
% Output parameter:
%  Z    table of the same size as X and Y containing the values of the
%       polynomial (the entry at position (i,j) stores the value of the
%       polynomial at (X(i,j), Y(i,j)))

m = size(X,1);
n = size(X,2);
d = size(B,1)-1;
Z = NaN(m,n);
for i = 1:m
    for j = 1:n
        bar = ([1 1 1; T']\[1; X(i,j); Y(i,j)])';
        Z(i,j) = decasteljau(B,repmat(bar,d,1));
    end
end

end