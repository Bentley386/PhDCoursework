function bs = constructSplineFromFuncFoleyOpitz(tri, f, d1f, d2f)
% construct spline from values/derivatives given by a function
% tri - triangulation object
% f - function to sample from
% d1f - first derivative of f w/ respect to x
% d2f - first derivative of f w/ respect to y

pts = tri.Points;
npts = size(pts,1);

alpha = zeros(npts,3);
for i = 1:npts
    x = pts(i,1);
    y = pts(i,2);
    alpha(i,1) = f(x,y);
    alpha(i,2) = d1f(x,y);
    alpha(i,3) = d2f(x,y);
end
bs = constructSplineC0Cubic(tri,alpha);
end