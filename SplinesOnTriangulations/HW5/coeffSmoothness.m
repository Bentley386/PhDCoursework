function b2 = coeffSmoothness(t1,t2,r, b)
% For a polynomial on coordinates t1, give appropriate coefficients
% for the polynomial on t2, such that the spline is C^r
% t1 - coordinates of first polynomial 3x2 table
% t2 - coordinates of second polynomial 3x2 table
% r an integer between 0 and d-1
% b (d+1)x(d+1) table of coefficients of first polynomial in
% b2 are the required coefficients second polynomial must have
d = size(b,1)-1;
b2 = NaN(d+1);
E = eye(3);
right = linsolve([t1.' ; 1 1 1], [t2(3,:).' ; 1]).' %t2(3,:) in t1 coords
for delta2 = 0:r
    for delta1 = 0:r-delta2
        delta0 = r-delta1-delta2;
        for d1 = 0:d-r
            d0 = d-r-d1;
            U = [repmat(E(1,:),delta0,1);
                repmat(E(2,:), delta1,1);
                repmat(right, delta2,1);
                repmat(E(1,:),d0,1);
                repmat(E(2,:),d1,1)];
            ele = decasteljau(b,U);
            b2(delta2+1,delta1+d1+1) = ele;
        end
    end
end

end

