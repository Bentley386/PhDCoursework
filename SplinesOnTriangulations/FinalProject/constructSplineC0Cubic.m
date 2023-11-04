function bs = constructSplineC0Cubic(tri,values)
% Description:
%  Provides Bernstein-Bezier coefficients for a C0 cubic spline
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

%first let's do a quadratic interpolation to get most coefficients:
bs = constructSplineC0Quadratic(tri,values);

%now we fix the 1,1,1 coefficients
cl = tri.ConnectivityList;
for i=1:size(cl,1)
    gammaVal = 0;
    number=0; %number of triangle neighbours
    ngh = neighbors(tri,i);
    for j=1:size(ngh,2)
        if isnan(ngh(j)) %boundary edge (aka no neighbour)
            continue;
        end
        tri1 = cl(i,:);
        tri2 = cl(ngh(j),:);
        ismem = ismember(tri1,tri2);
        k = tri1(~ismem); %vertex of tri1 that is not in tri2
        ismem = ismember(tri2,tri1);
        k2 = tri2(~ismem); %vertex of tri2 that is not in tri1
        gammaVal = gammaVal + gammaFunctional(tri,i,k,ngh(j),k2,bs);
        number = number+1;
    end
    gammaVal = gammaVal/number; %average gamma over all neighbors
    bs(i,2,2) = gammaVal;
end
end
