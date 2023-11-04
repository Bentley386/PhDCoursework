function val = evaluateSpline(x,y,tri,bs)
% Evaluates the spline at x,y
% x,y - evaluation coordinates
% tri - triangulation object
% bs - 3 dimensional array of spline coefficients

relTri = pointLocation(tri,[x y]);
pts = tri.Points;
cl = tri.ConnectivityList;

b = squeeze(bs(relTri,:,:));
t = [pts(cl(relTri,1),:);
    pts(cl(relTri,2),:);
    pts(cl(relTri,3),:)];
val = bpolyval(b,t,x,y);
end

