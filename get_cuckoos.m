
function nest = get_cuckoos(nest, best, Lb, Ub)
% Menghasilkan solusi baru menggunakan Levy flights
n = size(nest, 1);
beta = 3/2;
sigma = (gamma(1 + beta) * sin(pi * beta / 2) /(gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);

for j = 1:n
    s = nest(j, :);
    u = randn(size(s)) * sigma;
    v = randn(size(s));
    step = u ./ abs(v).^(1 / beta);
    stepsize = 0.01 * step .* (s - best);
    s = s + stepsize .* randn(size(s));
    nest(j, :) = simplebounds(s, Lb, Ub);
end