data = load("approx.mat");
tri = triangulation(data.TRI,data.PTS);

% old, naive way
% fprintf("Doing the approximation with old, naive way...\n");
% spline = constructSplineFromFunc(tri,data.F,data.d1F,data.d2F);
% 
% 
% x = linspace(0,1,401);
% y = linspace(0,1,401);
% [X,Y] = meshgrid(x,y);
% Z = zeros(size(X));
% for i=1:401
%     for j=1:401
%         Z(i,j) = evaluateSpline(X(i,j),Y(i,j),tri,spline);
%     end
% end
% figure;
% contour(X,Y,Z,50);
% 
% fprintf("Maximal absolute error in a 401x401 grid is %f\n",getLinfError(tri,spline,data.F));
% 
% checkSmoothnessSpline(tri,spline);
% 
% nRefinements = 5;
% errors = zeros(nRefinements,1);
% hs = zeros(nRefinements,1);
% for i=1:nRefinements
%     E = edges(tri);
%     pts = tri.Points;
%     spline = constructSplineFromFunc(tri,data.F,data.d1F,data.d2F);
%     h = 0;
%     for j=1:size(E,1)
%         h = max([h norm(pts(E(j,1),:)-pts(E(j,2),:))]);
%     end
%     e = getLinfError(tri,spline,data.F);
%     fprintf("Error for h %f is %f\n",h,e);
%     errors(i) = e;
%     hs(i) = h;
%     tri = doubleTriangulation(tri);
% end
% 
% figure;
% scatter(hs,errors, 'DisplayName', 'data')
% set(gca,'xscale','log')
% set(gca,'yscale','log')
% hold on
% grid on
% box on
% axis equal
% %
% Bp = polyfit(log10(hs), log10(errors), 1);
% Yp = polyval(Bp, log10(hs));
% Yp2 = 10.^(Yp);
% %
% plot(hs, Yp2, '-r', 'DisplayName', 'Fit');
% text(hs(1), errors(1), strcat('Slope =', num2str(Bp(1))), 'Interpreter', 'none');
% title('Convergence of the approximation');
% xlabel('h');
% ylabel('max error')
% legend

% 
% 
% tri = triangulation(data.TRI,data.PTS);
% 
% % foley opitz
% fprintf("Doing the approximation with Foley Opitz...\n");
% spline = constructSplineFromFuncFoleyOpitz(tri,data.F,data.d1F,data.d2F);
% x = linspace(0,1,401);
% y = linspace(0,1,401);
% [X,Y] = meshgrid(x,y);
% Z = zeros(size(X));
% for i=1:401
%     for j=1:401
%         Z(i,j) = evaluateSpline(X(i,j),Y(i,j),tri,spline);
%     end
% end
% figure;
% contour(X,Y,Z,50);
% 
% fprintf("Maximal absolute error in a 401x401 grid is %f\n",getLinfError(tri,spline,data.F));
% 
% checkSmoothnessSpline(tri,spline);
% 
% nRefinements = 5;
% errors = zeros(nRefinements,1);
% hs = zeros(nRefinements,1);
% for i=1:nRefinements
%     E = edges(tri);
%     pts = tri.Points;
%     spline = constructSplineFromFuncFoleyOpitz(tri,data.F,data.d1F,data.d2F);
%     h = 0;
%     for j=1:size(E,1)
%         h = max([h norm(pts(E(j,1),:)-pts(E(j,2),:))]);
%     end
%     e = getLinfError(tri,spline,data.F);
%     fprintf("Error for h %f is %f\n",h,e);
%     errors(i) = e;
%     hs(i) = h;
%     tri = doubleTriangulation(tri);
% end
% 
% figure;
% scatter(hs,errors, 'DisplayName', 'data')
% set(gca,'xscale','log')
% set(gca,'yscale','log')
% hold on
% grid on
% box on
% axis equal
% %
% Bp = polyfit(log10(hs), log10(errors), 1);
% Yp = polyval(Bp, log10(hs));
% Yp2 = 10.^(Yp);
% %
% plot(hs, Yp2, '-r', 'DisplayName', 'Fit');
% text(hs(1), errors(1), strcat('Slope =', num2str(Bp(1))), 'Interpreter', 'none');
% title('Convergence of the approximation');
% xlabel('h');
% ylabel('max error')
% legend




tri = triangulation(data.TRI,data.PTS);

% clough tocher
fprintf("Doing the approximation with Clough Toucher...\n");
[tri2, spline] = constructSplineFromFuncCloughTocher(tri,data.F,data.d1F,data.d2F);
pts2 = tri2.Points;
% x = linspace(0,1,401);
% y = linspace(0,1,401);
% [X,Y] = meshgrid(x,y);
% Z = zeros(size(X));
% linf = 0;
% for i=1:401
%     for j=1:401
%         Z(i,j) = evaluateSpline(X(i,j),Y(i,j),tri2,spline);
%     end
% end
%figure;
%contour(X,Y,Z,50);
fprintf("Maximal absolute error in a 401x401 grid is %f\n",getLinfError(tri2,spline,data.F));
 
% es = checkSmoothnessSpline(tri2,spline);
% E = edges(tri2);
% triplot(tri);
% figure;
% triplot(tri2);
% hold on;
% for i=1:size(es,2)
%     edge = E(es(i),:);
%     p1 = edge(1);
%     p2 = edge(2);
%     line([pts2(p1,1),pts2(p2,1)],[pts2(p1,2),pts2(p2,2)],'Color','r');
% end

tri = doubleTriangulation(tri);
[tri2, spline] = constructSplineFromFuncCloughTocher(tri,data.F,data.d1F,data.d2F);
pts2 = tri2.Points;
es = checkSmoothnessSpline(tri2,spline);
E = edges(tri2);
triplot(tri);
figure;
triplot(tri2);
hold on;
for i=1:size(es,2)
    edge = E(es(i),:);
    p1 = edge(1);
    p2 = edge(2);
    line([pts2(p1,1),pts2(p2,1)],[pts2(p1,2),pts2(p2,2)],'Color','r');
end
% 
% nRefinements = 5;
% errors = zeros(nRefinements,1);
% hs = zeros(nRefinements,1);
% for i=1:nRefinements
%     E = edges(tri);
%     pts = tri.Points;
%     [tri2, spline] = constructSplineFromFuncCloughTocher(tri,data.F,data.d1F,data.d2F);
%     h = 0;
%     for j=1:size(E,1)
%         h = max([h norm(pts(E(j,1),:)-pts(E(j,2),:))]);
%     end
%     e = getLinfError(tri2,spline,data.F);
%     fprintf("Error for h %f is %f\n",h,e);
%     errors(i) = e;
%     hs(i) = h;
%     tri = doubleTriangulation(tri);
% end
% 
% figure;
% scatter(hs,errors, 'DisplayName', 'data')
% set(gca,'xscale','log')
% set(gca,'yscale','log')
% hold on
% grid on
% box on
% axis equal
% %
% Bp = polyfit(log10(hs), log10(errors), 1);
% Yp = polyval(Bp, log10(hs));
% Yp2 = 10.^(Yp);
% %
% plot(hs, Yp2, '-r', 'DisplayName', 'Fit');
% text(hs(1), errors(1), strcat('Slope =', num2str(Bp(1))), 'Interpreter', 'none');
% title('Convergence of the approximation');
% xlabel('h');
% ylabel('max error')
% legend