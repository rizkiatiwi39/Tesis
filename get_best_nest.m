
function [fmin, best, nest, fitness] = get_best_nest(nest, newnest, fitness)
% Evaluasi semua solusi baru
for j = 1:size(nest, 1)
    fnew = Tip_1(newnest(j, :)); %di ganti berdasarkan tipikal mana yg di pake 
    if fnew <= fitness(j)
        fitness(j) = fnew;
        nest(j, :) = newnest(j, :);
    end
end
% Menemukan solusi terbaik
[fmin, K] = min(fitness);
best = nest(K, :);
