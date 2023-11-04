function bs = constructSplineC0Quadratic(tri,values)
% Description:
%  Provides Bernstein-Bezier coefficients for a C0 quadratic spline
%  interpolating the given data on a given triangulation.
%
% Input parameters:
%  tri      Triangulation object over which the spline is to be computed. 
%  values   Nvx3 table, where Nv is the number of points in tri. The i-th
%           row of the table is the data for the i-th vertex
%           in the form of (value, d/dx, d/dy).
%
% Output parameter:
%  bs       table of size NTx4x4 representing the Bernstein-Bezier 
%   	    coefficients for each triangle. Nt is the number of triangles
%           in tri.

cl = tri.ConnectivityList;
pts = tri.Points;

ntri = size(cl,1);
bs = NaN(ntri,4,4);
for i = 1:ntri
    t = [pts(cl(i,1),:);
        pts(cl(i,2),:);
        pts(cl(i,3),:)];
    alpha = [values(cl(i,1),:);
        values(cl(i,2),:);
        values(cl(i,3),:)];
    bs(i,:,:) = interpolateTriangle(t,alpha);
end
end