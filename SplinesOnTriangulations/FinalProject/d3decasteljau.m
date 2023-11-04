function b = d3decasteljau(B,U) %TODO optimizse d 3 decasteljau
% Description:
%  Computes the blossom of a degree 3 polynomial in two variables.
%
% Input parameters:
%  B    table of size 4 x 4 representing the coefficients of a
%       polynomial in two variables of degree d in the Bernstein-Bezier
%       form.
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