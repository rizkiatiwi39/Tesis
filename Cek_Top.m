
clc;
clear;
close all;

% Input nilai TDS, Iscmax, dan Ipickup
Iscmax = input('Masukkan nilai Iscmax: ');
TDS = input('Masukkan nilai TDS: ');
Ipickup = input('Masukkan nilai Ipickup: ');

% Jika Iscmax / Ipickup > 20, atur menjadi 20
if Iscmax / Ipickup > 20
    Iscmax = 20 * Ipickup;
end

% Memilih jenis kurva
disp('Pilih jenis kurva:');
disp('1: LTI');
disp('2: SI');
disp('3: VI');
disp('4: EI');
disp('5: UI');
kurva = input('Masukkan pilihan (1-5): ');

% Mengatur nilai koefisien berdasarkan jenis kurva
switch kurva
    case 1
        k = 120;
        alpha = 1;
        beta = 13.33;
        disp('Kurva LTI dipilih.');
    case 2
        k = 0.14;
        alpha = 0.02;
        beta = 2.97;
        disp('Kurva SI dipilih.');
    case 3
        k = 13.5;
        alpha = 1;
        beta = 1.5;
        disp('Kurva VI dipilih.');
    case 4
        k = 80;
        alpha = 2;
        beta = 0.808;
        disp('Kurva EI dipilih.');
    case 5
        k = 315.2;
        alpha = 2.5;
        beta = 1;
        disp('Kurva UI dipilih.');
    otherwise
        error('Pilihan tidak valid. Harap pilih antara 1-5.');
end

% Menghitung nilai Top
Top = (k * TDS) / (beta * (((Iscmax / Ipickup)^alpha) - 1));

% Menampilkan hasil
fprintf('Nilai Top adalah: %.4f detik\n', Top);
