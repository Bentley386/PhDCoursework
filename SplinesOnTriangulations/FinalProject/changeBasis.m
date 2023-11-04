function b2 = changeBasis(t1,t2,b1)
% Description:
%  Calculate the Bernstein-Bezier coefficients of a polynomial with 
%  respect to the new barycentric frame.
%
% Input parameters:
%  t1       3x2 table describing the initial barycentric frame. 
%  t2       3x2 table describing the target barycentric frame
%  b1       4x4 table with Bernstein-Bezier coefficients, calculated in the
%           frame t1.
%
% Output parameter:
%  b2      4x4 table with Bernstein-Bezier coefficients, calculated in the
%          frame t2.

baryc = NaN(3,3); %barycentric coordinates for points in t2 in terms of t1
A = [t1.';
    1 1 1] ;
for i=1:3 %get the baryc coord for each vertex
    rhs = [t2(i,:).'; 1];
    baryc(i,:) = (A\rhs).';
end

b2 = NaN(4,4);
for d2 = 0:3
    for d1 = 0:3-d2
        d0 = 3-d1-d2;
        U = [repmat(baryc(1,:),d0,1); repmat(baryc(2,:),d1,1); repmat(baryc(3,:),d2,1)];
        b = decasteljau(b1,U);
        b2(d2+1,d1+1) = b;
    end
end
end

