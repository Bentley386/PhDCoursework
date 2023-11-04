function val = gammaFunctional(tri, m ,k, m2, k2, spline)
% Description:
%  Calculate the Gamma functional used to construct the cubic splines.
%
% Input parameters:
%  tri      The triangulation object. 
%  m        Index of the triangle for which the functional is to be
%           computed.
%  k        Index of the vertex in the triangle m.
%  m2       Index of the triangle that is adjacent to triangle m.
%  k2       Index of the point in triangle m2 that is opposite of point k.
%  spline   Ntrix4x4 table of the C0 Quadratic spline coefficients.
%
% Output parameter:
%  val      Value of the functional.

% Gamma functional that helps with the construction of splines


pts = tri.Points;
cl = tri.ConnectivityList;

% changing everything so the first two points are the common edge
t10 = [pts(cl(m,1),:); pts(cl(m,2),:); pts(cl(m,3),:)]; %original frame of m
t20 = [pts(cl(m2,1),:); pts(cl(m2,2),:); pts(cl(m2,3),:)]; %original frame of m2
intersection = cl(m,:);
intersection(intersection == k) = [];
t1 = [pts(intersection(1),:); pts(intersection(2),:); pts(k,:)]; %transformed frames
t2 = [pts(intersection(1),:); pts(intersection(2),:); pts(k2,:)];

b1new = changeBasis(t10,t1,squeeze(spline(m,:,:)));
b2new = changeBasis(t20,t2,squeeze(spline(m2,:,:)));

% get baryc coords (the tau in the formula)
A = [t1.';
    1 1 1];
rhs = [pts(k2,:).'; 1];
baryc = (A\rhs).';


val = b2new(3,1)+b2new(3,2);
val = val - baryc(1)*baryc(1)*(b1new(1,1)+b1new(1,2));
val = val -2*baryc(1)*baryc(2)*(b1new(1,2)+b1new(1,3));
val = val - baryc(2)*baryc(2)*(b1new(1,3)+b1new(1,4));
val = val - 2*baryc(1)*baryc(3)*b1new(2,1);
val = val - 2*baryc(2)*baryc(3)*b1new(2,3);
val = val - baryc(3)*baryc(3)*(b1new(3,1)+b1new(3,2));
val = val/(2*baryc(3)*(1-baryc(3)));
end

