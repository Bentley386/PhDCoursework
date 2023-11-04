b = [3 2 8 7;
    0 9 4 0;
    1 3 0 0;
    6 0 0 0];

fprintf("The Coefficient matrix is as in the instructions:\n")
disp(b)
fprintf("==================================================")
fprintf(" Now to calculate blossom values: ")
fprintf("==================================================\n")

for d0 = 0:3
    for d1 = 0:3
        d2 = 3-d0-d1;
        if d2 < 0
            break;
        end
        fprintf("Blossom at (eps0 : %i, eps1 : %i, eps2 : %i) is:",d0,d1,d2)
        
        tau = [repmat([1 0 0],d0,1);
            repmat([0 1 0],d1,1);
            repmat([0 0 1],d2,1)];

        disp(deCasteljau(3,b,tau))
    end
end

fprintf("==================================================")
fprintf(" And blossom values for tau arguments ")
fprintf("==================================================\n")

for d0 = 0:3
    for d1 = 0:3
        d2 = 3-d0-d1;
        if d2 < 0
            break;
        end
        fprintf("Blossom at (tau0 : %i, tau1 : %i, tau2 : %i) is:",d0,d1,d2)
        
        tau = [repmat([1.5 -0.25 -0.25],d0,1); %tau0 = (-0.25,-0.25)
            repmat([-0.25 1.25 0],d1,1); %tau1 = (1.25,0)
            repmat([-0.5 0.5 1],d2,1)]; %tau2 = (0.5,1)

        disp(deCasteljau(3,b,tau))
    end
end



fprintf("==================================================")
fprintf(" Polynomial value at (1/3,1/3) is: ")
fprintf("==================================================\n")
tau = repmat([1/3 1/3 1/3],3,1);
disp(deCasteljau(3,b,tau))
