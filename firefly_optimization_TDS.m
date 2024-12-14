

function [best, fmin] = firefly_optimization_TDS(n, MaxGeneration)

    % Parameter Firefly
    n = 25; 
    MaxGeneration = 500;
    alpha = 0.2;      % Faktor acak
    gamma = 1.0;      % Koefisien penyerapan
    delta = 0.97;     % Pengurangan randomness

    % Rentang nilai TDS (disesuaikan)
    TDS_min = 0.1;
    TDS_max = 0.5;
    dim = 8; % Jumlah relay (relay 57, 17, 14, 12, 15, 04, 02, 01)

    % Inisialisasi posisi awal firefly
    xn = TDS_min + (TDS_max - TDS_min) * rand(n, dim);
    Lightn = zeros(n, 1);

    % Array untuk menyimpan nilai terbaik di setiap iterasi
    convergence_curve = zeros(1, MaxGeneration);
    
    % Iterasi
    for gen = 1:MaxGeneration
        % Evaluasi setiap firefly menggunakan fungsi objektif
        for i = 1:n
            Lightn(i) = Tip_2(xn(i, :));
        end

        % Ranking berdasarkan intensitas cahaya (fitness)
        [Lightn, Index] = sort(Lightn);
        xn = xn(Index, :);

        % Simpan solusi terbaik sejauh ini
        best = xn(1, :);
        fmin = Lightn(1);

        % Simpan fitness terbaik ke dalam kurva konvergensi
        convergence_curve(gen) = fmin;

        % Pindahkan fireflies berdasarkan intensitas cahaya
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

        % Pastikan firefly tetap dalam batasan TDS
        xn = max(TDS_min, min(TDS_max, xn));

        % Kurangi randomness
        alpha = alpha * delta;
    end

    % Plot kurva konvergensi
    figure;
    plot(1:MaxGeneration, convergence_curve, '-b', 'LineWidth', 2);
    xlabel('Iterasi');
    ylabel('Fungsi Objektif');
    title('Kurva Konvergensi FA');
    grid on;
end
