function b = interpolation(t,alpha)
% Solves HW4 (returns Bernstein-Bezier representation coefficients)
% t is a 3x2 matrix of the barycentric simplex vertices (in R2)
% alpha is a 3x3 matrix with the data of poly values/derivatives
% first col - values, second col - d/d1, third col - d/d2
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

