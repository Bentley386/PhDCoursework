function result = integrateOverTriangle(integrand,t)
% Description:
%  Perform a numeric 2D integration over a triangle.
%
% Input parameters:
%  integrand  vectorized function that takes two arguments - barycentric
%             coordinates (tau0,tau1) (with tau2 = 1-tau0-tau1)
%  t          3x2 table with the triangle vertices.

% Output parameter:
%  result     Result of the integration.

ymax = @(x) 1-x;
jacobian = 2*triangleArea(t(1,:),t(2,:),t(3,:));
result = integral2(integrand, 0, 1, 0, ymax)*jacobian; %TODO - Tolerance
end

