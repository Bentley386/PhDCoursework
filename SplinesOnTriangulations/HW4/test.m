% barycentric coords

E = [0 0; 1 0; 0 1]; %standardno ogrodje

T = [-1/2 1; 2 -3/2; 1 3]; %ogrodje t

A = [2 1/2 1/4; 1 1/3 2/3; -3 2 1]; %vrednosti, odvodi

% koeficienti polinoma nad standardnim trikotnikom
B_E = homework4(E,A)

% koeficienti polinoma nad T
B_T = homework4(T,A)
