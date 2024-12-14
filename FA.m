
rng('default'); % Mengembalikan generator ke mode modern
rng(42, 'twister'); % Menyetel ulang seed dengan metode modern 'twister'

% Parameter Firefly
n_fireflies = 25;      % Jumlah fireflies
max_iter = 500;        % Jumlah iterasi maksimumz

% Jalankan algoritma
[best_TDS, best_cost] = firefly_optimization_TDS(n_fireflies, max_iter);

% Tampilkan hasil
disp(['Nilai Minimum Objective Function FA: ', num2str(best_cost)]);

