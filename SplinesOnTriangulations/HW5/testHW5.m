t1 = [0 1 ; 1 0; 0 0];
t2 = [0 1 ; 1 0; 1 1];
b1 = [3 4 5 8;
    8 9 1 NaN;
    1 9 NaN NaN;
    10 NaN NaN NaN];

b2 = [0, 13, -3, 3;
       3 9 1 NaN;
     3 1 NaN NaN;
     pi NaN NaN NaN]; %default P2 coefficients. Some of these will be changed appropriately.

% For an example of a cubic spline that is C^0 but not C^1, choose r=0
% For an example of a cubic spline that is C^1 but not C^2, choose r=1

% Explanation: 
% Running the algorithm for a given r gives us coefficients required to satisfy C^r.
% Running the algorithm for r=k+1 gives us the same coefficients as for r=k + some more.
% So to have C^k but not C^(k+1) it is enough to take the coefficients from
% r=k and make sure the remaining ones do not match the r=(k+1) coefficients. None
% of the rows of our default example (b2) match those conditions anyway (we
% have checked that) so it suffices to simply run the algorithm for a given
% r, to automatically get a C^r spline that is not C^{r+1}.

% For an example of a cubic spline that is C^2 but not C^\infty, choose r=2
% Explanation:
% A C^\infty spline would just be the same cubic polynomial on both of the
% triangles. After applying the r=2 conditions both polynomials have one
% remaining coefficient as their degree of freedom. As P2 has an irrational
% number (pi) as that coefficient, while all the other data are integer
% numbers, it's impossible for them to both be the same polynomial.
% (I guess due to our limited numerical precision our "pi" might be just
% a rational number)
r = 1;

printAndPlot(t1,t2,b1,b2,r)



