function alpha = makeSplineBasisData(tri,i,r)
% Description:
%  For a given triangulation, prepare the data that can be used
%  to make spline basis function (i,r)
%
% Input parameter:
%  tri      The triangulation object. 
%
% Output paramete:
%  alpha    a Ntx3 table, consisting of the data that corresponds to 
%           the basis function. i-th row contains (value, d/dx, d/dy)

pts = tri.Points;

alpha = zeros(size(pts,1),3);
ptCloud = getPointCloud(tri,i);
trik = getTriangleOptimal(ptCloud);

p = pts(i,:).';
val = barycentricMap(trik,p);
alpha(i,1) = val(r);
val = barycentricMap(trik,p+[1;0]);
alpha(i,2) = val(r)-alpha(i,1);
val = barycentricMap(trik,p+[0;1]);
alpha(i,3) = val(r)-alpha(i,1);
end

