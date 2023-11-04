function b = decasteljau(B,U)
% Description:
%  decasteljau computes the blossom of a polynomial in two variables
%
% Definition:
%  b = decasteljau(B,U)
%
% Input parameters:
%  B    table of size d+1 x d+1 representing the coefficients of a
%       polynomial in two variables of degree d in the Bernstein-Bezier
%       form (table entry at position (i,j), j <= n+2-i, determines the
%       polynomial coefficient with index (d+2-i-j, j-1, i-1)),
%  U    table of size d x 3 whose rows correspond to barycentric
%       coordinates of the points with respect to the domain triangle for
%       which the blossom is being computed
%
% Output parameter:
%  b    the blossom value of the polynomial determined by table B at points
%       given by table U

d = size(B,1) - 1;
for r = 1:d
    for i = 1:d-r+1
        for j = 1:d-r+1-(i-1)
            B(i,j) = U(r,1)*B(i,j) + U(r,2)*B(i,j+1) + U(r,3)*B(i+1,j);
        end
    end
end
b = B(1,1);

end