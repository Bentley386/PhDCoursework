function area = triangleArea(p1,p2,p3)
% area of triangle given by 3 poins.
v1 = p2-p1;
v2 = p3-p1;
v1 = [v1 0];
v2 = [v2 0];
cross(v1,v2);
area = 0.5*norm(cross(v1,v2));
end

