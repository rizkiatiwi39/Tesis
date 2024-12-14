clc, clear, close all

ISCMAX = input('Masukkan nilai ISCMAX : ');

% Tap = input('Masukkan nilai Tap :');
% CT = input('Masukkan nilai CT :');

% % Masukan nilai Ip
% Ip = Tap * CT;

Ip = input('Masukkan nilai Ip :');

% Batasan nilai IS_max / Ip untuk primer
if ISCMAX / Ip > 20
    ISCMAX = 20 * Ip;
end

% Mengatur nilai berdasarkan pilihan pengguna
% LTI
k_LTI = 120;
alpha_LTI = 1;
beta_LTI = 13.33;
% SI
k_SI = 0.14;
alpha_SI = 0.02;
beta_SI = 2.97;
% VI
k_VI = 13.5;
alpha_VI = 1;
beta_VI = 1.5;
% EI
k_EI = 80;
alpha_EI = 2;
beta_EI = 0.808;
% UI
k_UI = 315.2;
alpha_UI = 2.5;
beta_UI = 1;

% Meminta pengguna memasukkan nilai top
top = input('Masukkan nilai target Top : ');

% Menghitung nilai TDS menggunakan rumus 'Primer' dan menerapkan batasan
TDS_LTI = (top * ((((ISCMAX / Ip) - 1) ^ alpha_LTI) * beta_LTI) / k_LTI);
TDS_SI = (top * ((((ISCMAX / Ip) - 1) ^ alpha_SI) * beta_SI) / k_SI);
TDS_VI = (top * ((((ISCMAX / Ip) - 1) ^ alpha_VI) * beta_VI) / k_VI);
TDS_EI = (top * ((((ISCMAX / Ip) - 1) ^ alpha_EI) * beta_EI) / k_EI);
TDS_UI = (top * ((((ISCMAX / Ip) - 1) ^ alpha_UI) * beta_UI) / k_UI);

% Menampilkan nilai TDS dengan 4 angka di belakang koma
fprintf('Nilai TDS LTI adalah: %.4f\n', TDS_LTI);
fprintf('Nilai TDS SI adalah: %.4f\n', TDS_SI);
fprintf('Nilai TDS VI adalah: %.4f\n', TDS_VI);
fprintf('Nilai TDS EI adalah: %.4f\n', TDS_EI);
fprintf('Nilai TDS UI adalah: %.4f\n', TDS_UI);
