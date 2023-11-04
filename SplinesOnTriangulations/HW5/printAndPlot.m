function printAndPlot(t1, t2, b1, b2, r)
% For given information about two polynomials and C^r smoothness
% print information about the conditions and plot the spline.
% t1 3x2 table of the first barycentric coords
% t2 3x2 table of the second barycentric coords
% b1 Bezier-bernstein coefficients of P1
% b2 Bezier-bernstein coefficeints of P2 (before smoothnes cond. are taken
% into account)
% r integer controlling the smoothness (r=-1 means no conditions)

disp("P1 Coefficients:")
disp(b1)
disp("P2 Coefficients before applying smoothness conditions:")
disp(b2)
disp("P2 coefficients required by smoothness:")
if r < 0
    b = NaN(size(b2,1));
else
    b = coeffSmoothness(t1,t2,r,b1);
end
disp(b);
disp("P2 coefficients after applying the conditions")
b(r+2:end,:) = b2(r+2:end,:); 
disp(b)
clf


figure(1);
x = linspace(0,1,200);
y = linspace(0,1,200);
[X,Y] = meshgrid(x,y);
Z = bpolyval(b1,t1,X,Y);
inT = inpolygon(X,Y,t1(:,1).',t1(:,2).');
X(~inT) = NaN; Y(~inT) = NaN; Z(~inT) = NaN;
surf(X,Y,Z, 'FaceColor','g', 'FaceAlpha',0.5, 'EdgeColor','none');
hold on
[X,Y] = meshgrid(x,y);
Z = bpolyval(b,t2,X,Y);
inT = inpolygon(X,Y,t2(:,1).',t2(:,2).');
X(~inT) = NaN; Y(~inT) = NaN; Z(~inT) = NaN;
surf(X,Y,Z, 'FaceColor','r','FaceAlpha',0.5, 'EdgeColor','none');
hold off



end

