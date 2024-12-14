
function fmin = Tip_2(x)
% x adalah TDS untuk setiap relay


% ID Relay
relayIND = [11 8
             8 5
             5 3
             3 4
             4 0];

% ISCmax primer dan backup
Ifault = [3012   3012
          3012   3012
          3023   5778
          9563   9563
          9563    0];

% Rasio CT
CTratio =  [800
            800
            1000
            1800
            2000];


% Rasio TAP
TAP = [1
       1
       0.97
       1
       0.97];

% Tipe Kurva
CurveType = [2 2
             2 2
             2 2
             2 2
             2 0];

% % Daftar Kurva:
% 1 = Standard Inverse
% 2 = Very Inverse
% 3 = Long Time Inverse
% 4 = Extremely Inverse
% 5 = Ultra Inverse

% Level Tegangan Rele
kV = [20 20
      20 20
      20 11
      11 11
      11  0];


%% Penggunaan arus dan pickup arus (primer)
ncases = size(Ifault,1);
Iused = Ifault;
Ipickup = CTratio .* TAP;

%% Deklarasi variabel `langgar` di awal fungsi
langgar = 0;

%% Waktu Operasi pada Masing-Masing Relay
waktu = zeros(ncases,2);
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            idx = find([11, 8, 5, 3, 4] == relayName);  % Index sesuai relay
            rasioI = Iused(i,j) / Ipickup(idx);
            
            % Batas rasio arus
            if rasioI > 20 
                rasioI = 20;
            end
            
            % Evaluasi kurva waktu operasi relay
            switch CurveType(i,j)
                case 1
                    dummy = 2.97 * (((rasioI).^0.02) - 1);
                    waktu(i,j) = 0.14 * x(idx) / dummy;
                case 2
                    dummy = 1.5 * (((rasioI).^1) - 1);
                    waktu(i,j) = 13.5 * x(idx) / dummy;
                case 3
                    dummy = 13.33 * (((rasioI).^1) - 1);
                    waktu(i,j) = 120 * x(idx) / dummy;
                case 4
                    dummy = 0.808 * (((rasioI).^2) - 1);
                    waktu(i,j) = 80 * x(idx) / dummy;
                case 5
                    dummy = 1 * (((rasioI).^2.5) - 1);
                    waktu(i,j) = 315.2 * x(idx) / dummy;
            end
        end
    end
end


%% Batasan waktu operasi relay
% for i = 1:ncases
%     for j = 1:2
%         relayName = relayIND(i,j);
%         if relayName ~= 0
% 
%             % Waktu operasi minimum
%             if waktu(i,j) < 0.1
%                 dummyP = 0.2 - waktu(i,j);
%                 langgar = langgar + (2000 * dummyP);
%             end
% 
%             % Waktu operasi maksimum
%             if waktu(i,j) > 1
%                 dummyP = waktu(i,j) - 1;
%                 langgar = langgar + (2000 * dummyP);
%             end
%         end
%     end
% end

for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            idx = find([11, 8, 5, 3, 4] == relayName);

            % Waktu operasi minimum
            if waktu(i,j) < 0.1
                dummyP = 0.1 - waktu(i,j);
                langgar = langgar + (2000 * dummyP);
            end

            % Waktu operasi maksimum
            if waktu(i,j) > 1
                dummyP = waktu(i,j) - 1;
                langgar = langgar + (2000 * dummyP);
            end
        end
    end
end

% %% Batasan Waktu Operasi Relay Tertentu
% % TOP relay 11 dan relay 8 harus sama-sama 0.3 detik
% idx_11 = find([11, 8, 5, 3, 4] == 11);
% idx_8 = find([11, 8, 5, 3, 4] == 8);
% 
% if abs(waktu(1,1) - 0.3) > 0
%     langgar = langgar + 2000 * abs(waktu(1,1) - 0.3); % Relay 11
% end
% if abs(waktu(2,1) - 0.3) > 0
%     langgar = langgar + 2000 * abs(waktu(2,1) - 0.3); % Relay 8
% end
% 
% % TOP relay 5 harus 0.5 detik
% idx_5 = find([11, 8, 5, 3, 4] == 5);
% if abs(waktu(3,1) - 0.5) > 0
%     langgar = langgar + 2000 * abs(waktu(3,1) - 0.5);
% end

% %% CTI (Coordination Time Interval)
% for i = 1:ncases
%     if relayIND(i,2) ~= 0
%         CTI = 0.2; % Default CTI
%         delta_waktu = waktu(i,2) - waktu(i,1);
%         if delta_waktu < CTI
%             dummyP = CTI - delta_waktu;
%             langgar = langgar + 2000 * dummyP;
%         end
%     end
% end


%% Input FLA primer trafo
% FLA_trafo = [0, 0, 0, 1575, 0];  % contoh nilai FLA primer trafo untuk setiap pasangan
% 
% % Kondisi inrush, 6 kali FLA sebagai batas inrush
% Inrush_factor = 6;
% % 
% % % Modifikasi Iused berdasarkan batasan inrush
% for i = 1:ncases
%     for j = 1:2
%         relayName = relayIND(i,j);
%         if relayName ~= 0
%             idx = find([11, 8, 5, 3, 4] == relayName);
% 
%             % Cek jika arus lebih besar dari inrush
%             if Iused(i,j) > Inrush_factor * FLA_trafo(idx)
%                 Iused(i,j) = Inrush_factor * FLA_trafo(idx);
%             end
%         end
%     end
% end

%% Pembatasan agar kurva relay tidak menyentuh inrush trafo
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            % Data arus dan waktu inrush trafo
            arus_inrush = [0, 0, 0, 9450, 0]; % Contoh data arus inrush trafo (multiple FLA)
            waktu_inrush = [0, 0, 0, 0.12, 0]; % Waktu operasi inrush (detik)
            
            % Hitung waktu operasi relay pada arus inrush
            for k = 1:length(arus_inrush)
                if Iused(i,j) == arus_inrush(k)
                    % Cek apakah waktu relay kurang dari waktu inrush
                    if waktu(i,j) <= waktu_inrush(k)
                        % Tambahkan penalti jika relay melanggar kurva inrush
                        dummyP = waktu_inrush(k) - waktu(i,j);
                        langgar = langgar + 1000 * dummyP; % Penalti besar
                    end
                end
            end
        end
    end
end


%% Batasan Starting Motor agar kurva relay tidak menyentuh kurva motor
% for i = 1:ncases
%     for j = 1:2
%         relayName = relayIND(i,j);
%         if relayName ~= 0
%             % Ambil arus dan waktu operasi motor pada titik tertentu
%             arus_motor = [0, 0, 0, 0, 0 ]; % Contoh data arus motor (ampere)
%             waktu_motor = [0, 0, 0, 0, 0]; % Waktu operasi motor pada arus di atas (detik)
% 
%             % Hitung waktu operasi relay pada arus yang sama
%             for k = 1:length(arus_motor)
%                 if Iused(i,j) == arus_motor(k)
%                     % Cek apakah waktu relay kurang dari waktu motor
%                     if waktu(i,j) <= waktu_motor(k)
%                         % Tambahkan penalti jika kurva relay menyentuh atau melanggar kurva motor
%                         dummyP = waktu_motor(k) - waktu(i,j);
%                         langgar = langgar + 1000 * dummyP; % Bobot penalti besar
%                     end
%                 end
%             end
%         end
%     end
% end

%% CTI (Coordination Time Interval) (Batasan CTI lengkap)
% CTI = 0.2; % Default CTI value
% for i = 1:ncases
%     for j = 1:2
%         if kV(i,1) == kV(i,2)
%             CTI = 0.2;  % CTI untuk relay dengan level tegangan yang sama
% 
%             % Periksa apakah CTI terpenuhi
%             if waktu(i,2) - waktu(i,1) < CTI && relayIND(i,2) ~= 0
%                 dummyP = CTI - (waktu(i,2) - waktu(i,1));
%                 langgar = langgar + (2000 * dummyP);
%             end
%         elseif kV(i,1) ~= kV(i,2)
%             % Untuk level tegangan berbeda
%             if Ifault(i,1) > Ifault(i,2)
%                 CTI = 0.2;  % Jika Ifault primer > Ifault backup, CTI = 0.2
%             else
%                 CTI = 0;  % Jika Ifault primer <= Ifault backup, CTI = 0
%             end
% 
%             % Periksa apakah CTI terpenuhi
%             if waktu(i,2) - waktu(i,1) < CTI && relayIND(i,2) ~= 0
%                 dummyP = CTI - (waktu(i,2) - waktu(i,1));
%                 langgar = langgar + (2000 * dummyP);
%             end
%         end
%     end
% end


for i = 1:ncases
    % Perhitungan CTI berdasarkan level tegangan
    if kV(i,1) == kV(i,2)
        % CTI untuk level tegangan yang sama
        CTI = 0.2;
    else
        % CTI untuk level tegangan yang berbeda
        CTI = 0.01;
    end

    % Periksa apakah CTI terpenuhi
    if relayIND(i,2) ~= 0  % Relay backup harus ada
        delta_waktu = waktu(i,2) - waktu(i,1); % Selisih waktu operasi relay
        if delta_waktu < CTI
            % Hitung penalti jika CTI dilanggar
            dummyP = CTI - delta_waktu;
            langgar = langgar + (2000 * dummyP);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Batasan nilai TDS dan TOP serta CTI relay 11 dan relay 8 pengaturan nya harus sama

idx_11 = find([11, 8, 5, 3, 4] == 11);
idx_8 = find([11, 8, 5, 3, 4] == 8);

% TDS relay 11 dan 15 harus sama
if x(idx_11) ~= x(idx_8)
    langgar = langgar + 2000 * abs(x(idx_11) - x(idx_8));
end

% TOP relay 11 dan 8 harus sama
if waktu(idx_11, 1) ~= waktu(idx_8, 1)
    langgar = langgar + 2000 * abs(waktu(idx_11, 1) - waktu(idx_8, 1));
end

% CTI antara relay 11 dan 8 harus sama dengan 0
if abs(waktu(idx_8, 1) - waktu(idx_11, 1)) > 0
    langgar = langgar + 2000 * abs(waktu(idx_8, 1) - waktu(idx_11, 1));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menghitung margin CTI
marginCTI = waktu(:,2) - waktu(:,1) - CTI;
marginCTI = max(marginCTI);  % Mendapatkan margin CTI terbesar

% Mendefinisikan JumlahRele berdasarkan jumlah baris di relayIND
JumlahRele = size(relayIND, 1);

% Setelah bagian perhitungan waktu dan penalti
top = sum(waktu(:,1));  % Hitung total waktu operasi

% Hitung sigmaOBJ
fmin = top + langgar;  % penghitungan nilai objektif

% Display Hasil


disp('================================================================================================================');
disp('                      Rele Primer                |                  Rele Backup                                 ');
disp('================================================================================================================');
disp('     | ID Relay |  TDS  |   Curve Type   |  TOP  |  ID Relay  |  TDS  |  Curve Type  |    TOP    |     CTI     |');
disp('----------------------------------------------------------------------------------------------------------------');
for m = 1:JumlahRele
    relayName1 = relayIND(m,1);
    fprintf('  %10s', num2str(relayName1));
    
    if relayName1 ~= 0
        idx1 = find([11, 8, 5, 3, 4] == relayName1);
        fprintf('  %9.3f', x(idx1));  % TDS

        % Menentukan jenis kurva berdasarkan nilai CurveType
        switch CurveType(m, 1)
            case 1
                kurva = 'SI';
            case 2
                kurva = 'VI';
            case 3
                kurva = 'LTI';
            case 4
                kurva = 'EI';
            case 5
                kurva = 'UI';
            otherwise
                kurva = '0';
        end
        fprintf('  %9s', kurva);  % Menampilkan jenis kurva sebagai string
        fprintf('  %12.3f |', waktu(m,1));  % TOP
    else
        fprintf('  %7s', ' ');  % Kosongkan jika tidak ada relay
        fprintf('  %7s', ' ');  % Kosongkan jenis kurva
        fprintf('  %12.3f |', 0);  % TOP
    end

    relayName2 = relayIND(m,2);
    fprintf('  %5s', num2str(relayName2));
    
    if relayName2 ~= 0
        idx2 = find([11, 8, 5, 3, 4] == relayName2);
        fprintf('  %10.3f', x(idx2));  % TDS

        % Menentukan jenis kurva berdasarkan nilai CurveType
        switch CurveType(m, 2)
            case 1
                kurva = 'SI';
            case 2
                kurva = 'VI';
            case 3
                kurva = 'LTI';
            case 4
                kurva = 'EI';
            case 5
                kurva = 'UI';
            otherwise
                kurva = '0';
        end
        fprintf('  %8s', kurva);  % Menampilkan jenis kurva sebagai string
        fprintf('  %13.3f   |', waktu(m,2));  % TOP
        fprintf('  %8.3f   |', waktu(m,2) - waktu(m,1));  % Margin CTI
    else
        fprintf('  %10s', '0');  % TDS
        fprintf('  %8s', ' ');  % Kosongkan jenis kurva
        fprintf('  %13.3f   |', 0);  % TOP
        fprintf('  %8.3f   |', 0);  % Margin CTI
    end
    fprintf('\n');
end

disp('================================================================================================================');

fprintf('Total Operating Time: %4.3f\n', top);
fprintf('Margin CTI : %4.3f\n', marginCTI);
% fprintf('Penalti    : %4.3f\n', langgar);
% fprintf('Min OF  : %4.3f\n', fmin);
end

