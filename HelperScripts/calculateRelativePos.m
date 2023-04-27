% calculateRelativePos - frame of reference calculation

syms psi1 psi2 x1 y1 x2 y2

T01 = [cos(psi1) -sin(psi1) x1; sin(psi1) cos(psi1) y1; 0 0 1];
T02 = [cos(psi2) -sin(psi2) x2; sin(psi2) cos(psi2) y2; 0 0 1];

T12 = T01\T02;
T12 = simplify(T12)
T21 = T12^-1;
T21 = simplify(T21)

R02 = T02(1:2,1:2);
o21 = T21(1:2,3);
% foo=R02 *o21;
% simplify(foo)

