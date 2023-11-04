function e = getLinfError(tri,bs,F)
% Output the Linf error of our approximations over the 401x401  grid as in
% the homework
% tri - triangulation for the spline
% bs - bezier-bernstein coefficients for it
% F - the function to compare our approximation with

x = linspace(0,1,401);
y = linspace(0,1,401);
e=0;
for i=1:401
    for j=1:401
        e = max([e abs(F(x(i),y(j))-evaluateSpline(x(i),y(j),tri,bs))]);
    end
end
end

