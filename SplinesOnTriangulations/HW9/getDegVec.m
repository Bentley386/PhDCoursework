function [d0, d1, d2] = getDegVec(ind, d)
% For a given degree d and index in the flattened array ind, give vektor
d0 = d;
d1 = 0;
d2 = 0;
i = 1;
while i~=ind
    d1 = d1+1;
    if d1+d2>d
        d1 = 0;
        d2 = d2+1;
    end
    d0 = d-d1-d2;
    i = i+1;
end
end

