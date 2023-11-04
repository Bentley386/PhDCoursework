function area = triangleArea(p1,p2,p3)
% Description:
%  Computes the area of a given triangle.
%
% Input parameters:
%  p1,p2,p3   The triangle vertices given as 2x1 tables. 
%
% Output parameter:
%  area       area of the triangle [p1,p2,p3]

v1 = p2-p1;
v2 = p3-p1;
v1 = [v1 0];
v2 = [v2 0];
cross(v1,v2);
area = 0.5*norm(cross(v1,v2));
end

