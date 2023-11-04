function res = thirdTerm(tri,i,vi,vj,vk,spline)
% Description:
%  Helper function to calculate the third term in the formula for the
%  (1,1,1) Bernstein-Bezier coefficient when constructing C1 Cubic splines.
%
% Input parameters:
%  tri      Original triangulation object.
%  i        Index of the triangle currently being considered.
%  vi       Index of the point corresponding to the first triangle vertex.
%  vj       Index of the point corresponding to the second triangle vertex.
%  vk       Index of the point corresponding to the third triangle vertex.
%  spline   Ntrix4x4 table of the C0 Quadratic spline coefficients.
%
% Output parameter:
%  res      The value of the third term in the formula.

if boundaryEdge(tri,vi,vj)
    if boundaryEdge(tri,vj,vk)
        [m2,k2] = getOpposite(tri,i,vj);
        res = gammaFunctional(tri,i,vj,m2,k2,spline);
    elseif boundaryEdge(tri,vk,vi)
        [m2,k2] = getOpposite(tri,i,vi);
        res = gammaFunctional(tri,i,vi,m2,k2,spline);
    else
        [m21,k21] = getOpposite(tri,i,vi);
        [m22,k22] = getOpposite(tri,i,vj);
        res = 1/2*(gammaFunctional(tri,i,vi,m21,k21,spline) + gammaFunctional(tri,i,vj,m22,k22,spline));
    end
else
    [m2,k2] = getOpposite(tri,i,vk);
    res = gammaFunctional(tri,i,vk,m2,k2,spline);
end
res = 1/3*res;
end

