data = load("approx.mat");
tri = triangulation(data.TRI,data.PTS);

pts = tri.Points;
cl = tri.ConnectivityList;

idx=17;
r=1;

values = zeros(size(pts,1),3);
ptCloud = getPointCloud(tri,idx);
%trik = getTriangleNaive(ptCloud);
trik = getTriangleOptimal(ptCloud);
p = pts(idx,:).';
val = barycentricMap(trik,p);
values(idx,1) = val(r);
val = barycentricMap(trik,p+[1;0]);
values(idx,2) = val(r)-values(idx,1);
val = barycentricMap(trik,p+[0;1]);
values(idx,3) = val(r)-values(idx,1);

spline = constructSpline(tri,values);

x = linspace(0,1,401);
y = linspace(0,1,401);
[X,Y] = meshgrid(x,y);
Z = zeros(size(X));
Z2 = zeros(size(X));
for i=1:401
    for j=1:401
        Z(i,j) = evaluateSpline(X(i,j),Y(i,j),tri,spline);
        val = barycentricMap(trik,[X(i,j); Y(i,j)]);
        Z2(i,j) = val(r);
    end
end

%checkSmoothnessSpline(tri,spline);

figure;
%subplot(1,2,1);
contour(X,Y,Z,50);
colorbar;
hold;
triplot(tri);
scatter(ptCloud(:,1),ptCloud(:,2),'red');
scatter(p(1),p(2),'green');
triplot([1,2,3],trik(:,1),trik(:,2),'red');
title('Bazna funkcija: i=17, r=1');
exportgraphics(gca, 'i17r1.pdf');
%subplot(1,2,2);
%contour(X,Y,Z2,50);
%colorbar;
%hold;
%triplot(tri);
%title('barycentric map component');