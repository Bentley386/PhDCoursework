function [tri2, k2] = getOpposite(tri,i,k)
% Description:
%  Helper function to find the vertex that is opposite of a vertex in a 
%  given triangle.
%
% Input parameters:
%  tri      The triangulation object. 
%  i        Index of the triangle given triangle.
%  k        Point index of one of the ith triangle vertices.
%
% Output parameters:
%  tri2     Index of the triangle, adjecent to i, that is to the opposite
%           of the vertex k.
%  k2       Point index of the tri2's vertex that is not vertex of i-th
%           triangle. (aka opposite vertex to k)

cl = tri.ConnectivityList;
vertices = cl(i,:);
vertices(vertices == k) = [];
neightris = edgeAttachments(tri,vertices(1),vertices(2));
neightris = neightris{1};
neightris(neightris == i) = [];
tri2 = neightris;
triangle1 = cl(i,:);
triangle2 = cl(tri2,:);
ismem = ismember(triangle2,triangle1);
k2 = triangle2(~ismem);
end

