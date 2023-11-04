function b = interpolateTriangle(t,alpha)
% Description:
%  Provides Bernstein-Bezier coefficients for a polynomial on a triangle
%  interpolating given data.
%
% Input parameters:
%  t        Table of size 3x2, where each row represents (x,y) coordinates 
%           of a triangle vertex.
%  alpha    Table of size 3x3 where i-th row gives data for i-th vertex
%           in the form of (value, d/dx, d/dy)
%
% Output parameter:
%  b        table of size 4x4 representing the Bernstein-Bezier 
%   	    coefficients of the interpolating polynomial.

    b = NaN(4,4);
    
    b(1,1) = alpha(1,1); %(3,0,0) = P(p0)
    b(1,4) = alpha(2,1); %(0,3,0) = P(p1)
    b(4,1) = alpha(3,1); %(0,0,3) = P(p2)
    b(1,2) = dot(alpha(1,2:end),t(2,:)-t(1,:))/3 + b(1,1); %(2,1,0)
    b(2,1) = dot(alpha(1,2:end),t(3,:)-t(1,:))/3 + b(1,1); % (2,0,1)
    b(1,3) = dot(alpha(2,2:end),t(1,:)-t(2,:))/3 + b(1,4); %(1,2,0)
    b(2,3) = dot(alpha(2,2:end),t(3,:)-t(2,:))/3 + b(1,4); %(0,2,1)
    b(3,1) = dot(alpha(3,2:end),t(1,:)-t(3,:))/3 + b(4,1); %(1,0,2)
    b(3,2) = dot(alpha(3,2:end),t(2,:)-t(3,:))/3 + b(4,1); %(0,1,2)
    b(2,2) = 0.25*(b(1,2)+b(2,1)+b(2,3)+b(1,3)+b(3,1) + b(3,2)) -1/6*(b(1,1)+b(1,4)+b(4,1)); %(1,1,1)
end

