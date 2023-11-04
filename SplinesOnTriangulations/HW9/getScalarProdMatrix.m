function B = getScalarProdMatrix(d)
%GETSCALARPRODMATRIX Summary of this function goes here
%   Detailed explanation goes here
N = (d+1)*(d+2)/2; %matrix size
B = zeros(N);
for i=1:N
    [dp0, dp1, dp2] = getDegVec(i,d);
    coeff1 = factorial(d)/factorial(dp0)/factorial(dp1)/factorial(dp2);
    for j=1:N
        [dq0,dq1,dq2] = getDegVec(j,d);
        coeff2 = factorial(d)/factorial(dq0)/factorial(dq1)/factorial(dq2);
        coeff3 = factorial(2*d)/factorial(dp0+dq0)/factorial(dp1+dq1)/factorial(dp2+dq2);
        B(i,j) = coeff1*coeff2/coeff3/(2*d+1)/(d+1);
    end
end

end

