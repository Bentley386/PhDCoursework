function res = barycentricMap(t,p)
% gives the coordinates in the standard barycentric frame
% t the "source" barimetric frame (3x2 matrix)
% p the point we would like to map (2x1)
% res the barycentric coordinates of p (3x1)
A = [t.';
    1 1 1];

res = A\[p;1];
end

