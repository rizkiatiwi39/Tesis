% cuckoo_search_relay.m
% Mengoptimasi TDS dan TOP dengan Cuckoo Search
clc;
clear;

rng(42) %--> untuk menkunci kurva konvergensi untuk tetap sama


% Parameter Cuckoo Search
n = 25;             % Jumlah sarang (nests)
pa = 0.25;          % Discovery rate of alien eggs/solutions
N_IterTotal =500;  % Total iterasi
nd = 5;                 % Jumlah TDS yang dicari 
Lb = 0.1 * ones(1, nd);  % Batas bawah TDS   
Ub = 0.5 * ones(1, nd);  % Batas atas TDS

% Inisialisasi solusi awal secara acak
nest = Lb + (Ub - Lb) .* rand(n, nd);

% Evaluasi fitness awal
fitness = 10^10 * ones(n, 1);
[fmin, bestnest, nest, fitness] = get_best_nest(nest, nest, fitness);

% Evaluasi hasil akhir
% [final_fmin] = Tip_1(bestnest);
[final_fmin] = Tip_2(bestnest); 

% Iterasi algoritma Cuckoo Search
for iter = 1:N_IterTotal
    % Menghasilkan solusi baru
    new_nest = get_cuckoos(nest, bestnest, Lb, Ub);
    [fnew, ~, nest, fitness] = get_best_nest(nest, new_nest, fitness);

    % Proses discovery dan randomization
    new_nest = empty_nests(nest, Lb, Ub, pa);
    [fnew, best, nest, fitness] = get_best_nest(nest, new_nest, fitness);

    % Catat nilai fungsi objektif terbaik pada iterasi ini
     convergenceCurve(iter) = fmin;

    % Memperbarui solusi terbaik
    if fnew < fmin
        fmin = fnew;
        bestnest = best;
    end
    % Menyimpan hasil iterasi ke dalam array hasil
    result{iter, 2} = fmin;
    
end


% Plot kurva konvergensi setelah selesai
figure;
plot(convergenceCurve, 'LineWidth', 2);
title('Kurva Konvergensi CSA');
xlabel('Iterasi');
ylabel('Nilai Objective Function');
grid on;

disp(['Nilai Minimum Objective Function CSA : ', num2str(fmin)]);


%% Menampilkan waktu total iterasi
% tic; % Mulai pencatatan waktu
% elapsedTime = toc; % Akhiri pencatatan waktu 
% disp(['Lama iterasi: ', num2str(elapsedTime), ' detik']);



