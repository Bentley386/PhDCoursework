function b2 = changeBasis(t1,t2,b1)
% given a polynomial in Bernstein-bezier repr. give coefficients in new
% basis.
% t1 first basis (span)
% t2 second basis (span)
% b1 coefficients in t1.
% assuming d=3

baryc = zeros(3,3); %barycentric coordinates for points in t2 in terms of t1
A = [t1.';
    1 1 1] ;
for i=1:3
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

