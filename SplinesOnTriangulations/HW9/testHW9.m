d = 3;
N = (d+1)*(d+2)/2;

t = rand(3,2)*10;
Pd = (rand(1,N)-0.5)*100;
Qd = (rand(1,N)-0.5)*100;

u = linspace(0,1,200);
v = linspace(0,1,200);
[U,V] = meshgrid(u,v);
X = (1-U-V)*t(1,1) + U*t(2,1) + V*t(3,1);
Y = (1-U-V)*t(1,2) + U*t(2,2) + V*t(3,2);

figure;
plot(polyshape(t(:,1)',t(:,2)'));
hold on;

Z = polyVal(Pd,d,U,V);
contour(X,Y,Z,50);
colorbar;
title("Polynomial 1");

figure;
plot(polyshape(t(:,1)',t(:,2)'));
hold on;
Z = polyVal(Qd,d,U,V);
contour(X,Y,Z,50);
colorbar;
title("Polynomial 2");

fprintf("Scalar product, calculated by the given formula is...\n");
scalarProduct(t,Pd,Qd,d)

fprintf("Scalar product given by numerical integration is...\n");

% Integration is done in standard simplex
% Baryc coordinates are given by 
% p1x p2x p3x    tau0      x
% p1y p2y p3y    tau1      y
%  1  1    1     tau2      1

% or:
% x = tau0 p1x + tau1 p2x + (1-tau0-tau1) p3x
% y = tau0 p1y + tau1 p2y + (1-tau0-tau1) p3y
% 
% Jacobian is
%   p1x-p3x   p2x-p3x
%   p1y-p3y   p2y-p3y

% The determinant is exactly the cross product that appears in triangle
% area calculation

ymax = @(x) 1-x;
integrand = @(x,y) polyVal(Pd,d,x,y).*polyVal(Qd,d,x,y);
integ = integral2(integrand, 0, 1, 0, ymax)*2*triangleArea(t(1,:),t(2,:),t(3,:)) 


function res = polyVal(coeff1,d,x1,x2)
    % coeff1 - coeff of poly, flattened
    % d - poly degree
    % x1 - first baryc coord
    % x2 - 2nd baryc coord

    B = zeros(d+1);
    total=1;
    for i=1:d+1
        length = d+2-i; %how many nonzero elements in this row
        B(i,1:length) = coeff1(total:total+length-1);
        total = total + length;
    end

    m = size(x1,1);
    n = size(x2,2);
    res = zeros(m,n);
    for i=1:m
        for j=1:n
            xx = x1(i,j);
            yy = x2(i,j);
            if xx+yy > 1
                res(i,j) = 0;
            else
                bar = [xx, yy, 1-xx-yy];
                res(i,j) = decasteljau(B,repmat(bar,d,1));
            end
        end
    end
end

