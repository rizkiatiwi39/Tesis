clc;
clear;

rng(42); % Mengunci hasil acak agar kurva konvergensi konsisten

% Parameter Algoritma
n = 25;                % Jumlah populasi/sarang
MaxGeneration = 500;   % Iterasi maksimum
dim = 8;               % Jumlah variabel (relay TDS)
TDS_min = 0.1;         % Batas bawah TDS
TDS_max = 0.5;         % Batas atas TDS

% ----------------------
% FIRELY ALGORITHM (FA)
% ----------------------
alpha = 0.2;          % Faktor acak
gamma = 1.0;          % Koefisien penyerapan
delta = 0.97;         % Pengurangan randomness
xn = TDS_min + (TDS_max - TDS_min) * rand(n, dim);
Lightn = zeros(n, 1);
fa_curve = zeros(1, MaxGeneration);

for gen = 1:MaxGeneration
    for i = 1:n
        Lightn(i) = Tip_1(xn(i, :));
    end

    [Lightn, Index] = sort(Lightn);
    xn = xn(Index, :);
    best_fa = xn(1, :);
    fmin_fa = Lightn(1);
    fa_curve(gen) = fmin_fa;

    for i = 1:n
        for j = 1:n
            if Lightn(i) > Lightn(j)
                r = norm(xn(i, :) - xn(j, :));
                beta = exp(-gamma * r^2);
                xn(i, :) = xn(i, :) .* (1 - beta) + ...
                           xn(j, :) .* beta + ...
                           alpha .* (rand(1, dim) - 0.5);
            end
        end
    end

    xn = max(TDS_min, min(TDS_max, xn));
    alpha = alpha * delta;
end

% ----------------------
% CUCKOO SEARCH (CSA)
% ----------------------
pa = 0.25;             % Discovery rate
Lb = TDS_min * ones(1, dim);
Ub = TDS_max * ones(1, dim);
nest = Lb + (Ub - Lb) .* rand(n, dim);
fitness = 10^10 * ones(n, 1);
[fmin_csa, best_csa, nest, fitness] = get_best_nest(nest, nest, fitness);
csa_curve = zeros(1, MaxGeneration);

for iter = 1:MaxGeneration
    new_nest = get_cuckoos(nest, best_csa, Lb, Ub);
    [fnew, ~, nest, fitness] = get_best_nest(nest, new_nest, fitness);
    new_nest = empty_nests(nest, Lb, Ub, pa);
    [fnew, best, nest, fitness] = get_best_nest(nest, new_nest, fitness);

    csa_curve(iter) = fmin_csa;

    if fnew < fmin_csa
        fmin_csa = fnew;
        best_csa = best;
    end
end

% ----------------------
% PLOT KURVA KONVERGENSI
% ----------------------
figure;
plot(1:MaxGeneration, fa_curve, '-b', 'LineWidth', 2); hold on;
plot(1:MaxGeneration, csa_curve, '-r', 'LineWidth', 2); hold off;
xlabel('Iterasi');
ylabel('Nilai Fungsi Objektif');
title('Kurva Konvergensi FA dan CSA');
legend('Firefly Algorithm (FA)', 'Cuckoo Search Algorithm (CSA)');
grid on;

% ----------------------
% TAMPILKAN HASIL AKHIR
% ----------------------
disp(['Nilai Minimum Objective Function FA: ', num2str(fmin_fa)]);
disp(['Nilai Minimum Objective Function CSA: ', num2str(fmin_csa)]);

