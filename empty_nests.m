
function new_nest = empty_nests(nest, Lb, Ub, pa)

% Mengganti beberapa sarang dengan solusi baru secara acak
n = size(nest, 1);
K = rand(size(nest)) > pa;
stepsize = rand * (nest(randperm(n), :) - nest(randperm(n), :));
new_nest = nest + stepsize .* K;

% Terapkan batas
for j = 1:n
    s = new_nest(j, :);
    new_nest(j, :) = simplebounds(s, Lb, Ub);
end
