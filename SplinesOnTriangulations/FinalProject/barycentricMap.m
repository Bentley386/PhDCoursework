function res = barycentricMap(t,p)
% Description:
%  Express a point in barycentric coordinates with respect to a given
%  frame
%
% Input parameters:
%  t        Table of size 3x2, where each row represents (x,y) coordinates 
%           of a triangle vertex.
%  p        2x1 vector representing a point to be expressed in baryc.
%
% Output parameter:
%  res      3x1 vector containing the barycentric coordinates. 

A = [t.';
    1 1 1];

res = A\[p;1];
end

