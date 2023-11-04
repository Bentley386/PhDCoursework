function res = scalarProduct(t,p1,p2,d)
% Scalar product of two polynomials in bernstein-bezier rep.
% t - 3x2 matrix of triangle vertices
% p1 - first polynomial B-B coefficients (flattened)
% p2 - second polynomial B-B coefficients (flattened)
% d - degree of the polynomial

B = getScalarProdMatrix(d);
area = triangleArea(t(1,:),t(2,:),t(3,:));
res = area* p1*B*(p2.');
end

