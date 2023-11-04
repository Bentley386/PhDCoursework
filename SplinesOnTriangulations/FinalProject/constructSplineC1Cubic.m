function [newTri,bs] = constructSplineC1Cubic(tri, values)
% Description:
%  Provides Bernstein-Bezier coefficients for a C1 cubic spline
%  interpolating the given data on a given triangulation.
%
% Input parameters:
%  tri      Triangulation object over which the spline is to be computed. 
%  values   Nvx3 table, where Nv is the number of points in tri. The i-th
%           row of the table is the data for the i-th vertex
%           in the form of (value, d/dx, d/dy).
%
% Output parameters:
%  newTri   New (finer) triangulation object over which the spline is
%           defined.
%  bs       table of size NTx4x4 representing the Bernstein-Bezier 
%   	    coefficients for each triangle. Nt is the number of triangles
%           in newTri.

pts = tri.Points;
cl = tri.ConnectivityList;

spline = constructSplineC0Quadratic(tri,values); %Used to calc gamma

newpts = NaN(size(cl,1)+size(pts,1),2);
newtriangles = Nan(size(cl,1)*3,3);
bs = NaN(size(cl,1)*3,4,4);
triCounter=1;
ptCounter=1;
for i=1:size(cl,1)
    % construct the 3 new triangles
    p1 = pts(cl(i,1),:);
    p2 = pts(cl(i,2),:);
    p3 = pts(cl(i,3),:);
    p4 = 1/3*(p1+p2+p3);
    ps = [p1;p2;p3;p4];
    pti = zeros(4); %indices of the 4 pts to prevent dupliation
    for j=1:4
        if ismember(ps(j,:),newpts,'rows')
            pti(j) = find(ismember(newpts,ps(j,:),'rows'));
        else
            newpts(ptCounter,:) = ps(j,:);
            pti(j) = ptCounter;
            ptCounter = ptCounter+1;
        end
    end
    newtriangles(triCounter,:) = [pti(1) pti(2) pti(4)];
    newtriangles(triCounter+1,:) = [pti(2) pti(3) pti(4)];
    newtriangles(triCounter+2,:) = [pti(3) pti(1) pti(4)];
    t = [p1;p2;p4];
    alpha = [values(cl(i,1),:) ; values(cl(i,2),:) ; 0 0 0]; %don't have given values at new vertex
    newb1 = interpolateTriangle(t,alpha); %mk
    newb1(2,2) = 1/3*newb1(1,2)+1/3*newb1(1,3) + thirdTerm(tri,i,cl(i,1),cl(i,2),cl(i,3),spline);
    t = [p2;p3;p4];
    alpha = [values(cl(i,2),:) ; values(cl(i,3),:) ; 0 0 0]; %don't have given values at new vertex
    newb2 = interpolateTriangle(t,alpha); %mi
    newb2(2,2) = 1/3*newb2(1,2)+1/3*newb2(1,3) + thirdTerm(tri,i,cl(i,2),cl(i,3),cl(i,1),spline);
    t = [p3;p1;p4];
    alpha = [values(cl(i,3),:) ; values(cl(i,1),:) ; 0 0 0]; %don't have given values at new vertex
    newb3 = interpolateTriangle(t,alpha); %mj
    newb3(2,2) = 1/3*newb3(1,2)+1/3*newb3(1,3) + thirdTerm(tri,i,cl(i,3),cl(i,1),cl(i,2),spline);
    newb1(3,1) = 1/3*newb1(2,1)+1/3*newb1(2,2)+1/3*newb3(2,2);
    newb3(3,2) = newb1(3,1);
    newb2(3,1) = 1/3*newb2(2,1)+1/3*newb2(2,2)+1/3*newb1(2,2);
    newb1(3,2) = newb2(3,1);
    newb3(3,1) = 1/3*newb3(2,1)+1/3*newb3(2,2)+1/3*newb2(2,2);
    newb2(3,2) = newb3(3,1);
    newb1(4,1) = 1/3*newb1(3,1)+1/3*newb2(3,1)+1/3*newb3(3,1);
    newb2(4,1) = newb1(4,1);
    newb3(4,1) = newb1(4,1);
    bs(triCounter,:,:) = newb1;
    bs(triCounter+1,:,:) = newb2;
    bs(triCounter+2,:,:) = newb3;
    triCounter = triCounter + 3;
end
newTri = triangulation(newtriangles,newpts);
end

