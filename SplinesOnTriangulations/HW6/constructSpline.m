function bs = constructSpline(tri,values)
%   constructs a cubic spline over the triangulation
% tri - trinagulation object
% values - nvx3 matrix with values at a vertex + both derivatives
% returns a list of bersntein-bezier coefficients for each triangle.

cl = tri.ConnectivityList;
pts = tri.Points;

ntri = size(cl,1);
bs = NaN(ntri,4,4);
for i = 1:ntri
    t = [pts(cl(i,1),:);
        pts(cl(i,2),:);
        pts(cl(i,3),:)];
    alpha = [values(cl(i,1),:);
        values(cl(i,2),:);
        values(cl(i,3),:)];
    bs(i,:,:) = interpolation(t,alpha);
end
end