
function fmin = Tip_1(x)


% x adalah TDS untuk setiap relay

% Relay dari beban (57) ke sumber (01)
relayIND = [57 17
            17 14
            14 12
            12 15
            15 04
            04 02
            02 01
            01 0];

% ISCmax primer dan backup
Ifault = [8728  8728
          9782  2801
          12626 11965
          12009 12009
          12009 12009
          13852 7085
          7092  946
          951   0];

% % % Rasio CT (berdasarkan pengaturan CT)
CTratio =  [300
            1000
            300
            800
            800
            800
            1000
            200];

TAP =   [0.80
         1.02
         1.07
         1.06
         1.06
         1.06
         0.80
         0.52];


% Tipe Kurva
CurveType = [4 4
             4 2
             2 2
             2 2
             2 2
             2 4
             4 4
             4 0];
% % Daftar Kurva:
% 1 = Standard Inverse
% 2 = Very Inverse
% 3 = Long Time Inverse
% 4 = Extremely Inverse
% 5 = Ultra Inverse


% Level Tegangan Rele
kV = [5.727 5.727
      5.727 20
      20    20
      20    20
      20    20
      20    20
      20    150
      150   0];


%% Penggunaan arus dan pickup arus (primer)
ncases = size(Ifault,1);
Iused = Ifault;
Ipickup = CTratio .* TAP;

%% Waktu Operasi pada Masing-Masing Relay
waktu = zeros(ncases,2);
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            idx = find([57, 17, 14, 12, 15, 04, 02, 01] == relayName);
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


%% Deklarasi variabel `langgar`
langgar = 0;

%% Batasan waktu operasi relay
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            idx = find([57, 17, 14, 12, 15, 04, 02, 01] == relayName);

            % Waktu operasi minimum
            if waktu(i,j) < 0.1
                dummyP = 0.1 - waktu(i,j);
                langgar = langgar + (2000 * dummyP);
            end

            % Waktu operasi maksimum
            if waktu(i,j) > 1
                dummyP = waktu(i,j) - 0.1;
                langgar = langgar + (2000 * dummyP);
            end
        end
    end
end


%% Pembatasan agar kurva relay tidak menyentuh inrush trafo
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            % Data arus dan waktu inrush trafo
                          %57, 17, 14, 12, 15, 04, 02, 01
            arus_inrush = [0, 0, 1732.2, 0, 0, 0, 0, 557.4]; % Contoh data arus inrush trafo (multiple FLA)
            waktu_inrush = [0, 0, 0.124, 0, 0, 0, 0, 0.124]; % Waktu operasi inrush (detik)

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
for i = 1:ncases
    for j = 1:2
        relayName = relayIND(i,j);
        if relayName ~= 0
            % Ambil arus dan waktu operasi motor pada titik tertentu
            arus_motor = [560, 0, 0, 0, 0, 0, 0, 0]; % Contoh data arus motor (ampere)
            waktu_motor = [6, 0, 0, 0, 0, 0, 0, 0]; % Waktu operasi motor pada arus di atas (detik)
            
            % Hitung waktu operasi relay pada arus yang sama
            for k = 1:length(arus_motor)
                if Iused(i,j) == arus_motor(k)
                    % Cek apakah waktu relay kurang dari waktu motor
                    if waktu(i,j) <= waktu_motor(k)
                        % Tambahkan penalti jika kurva relay menyentuh atau melanggar kurva motor
                        dummyP = waktu_motor(k) - waktu(i,j);
                        langgar = langgar + 1000 * dummyP; % Bobot penalti besar
                    end
                end
            end
        end
    end
end


%% CTI (Coordination Time Interval) (Batasan CTI lengkap)

% for i = 1:ncases
%     % Perhitungan CTI berdasarkan level tegangan
%     if kV(i,1) == kV(i,2)
%         % CTI untuk level tegangan yang sama
%         CTI = 0.2;
%     else
%         % CTI untuk level tegangan yang berbeda
%         CTI = 0.01;
%     end
%     % Periksa apakah CTI terpenuhi
%     if relayIND(i,2) ~= 0 % Relay backup harus ada
%         delta_waktu = waktu(i,2) - waktu(i,1); % Selisih waktu operasi relay
%         if delta_waktu < CTI
%             % Hitung penalti jika CTI dilanggar
%             dummyP = CTI - delta_waktu;
%             langgar = langgar + (2000 * dummyP);
%         end
%     end
% end

for i = 1:ncases
    % Perhitungan CTI berdasarkan level tegangan
    if kV(i, 1) == kV(i, 2)
        % CTI untuk level tegangan yang sama
        CTI = 0.2;
    else
        % CTI untuk level tegangan yang berbeda
        CTI = 0.01;
    end

    % Periksa apakah CTI terpenuhi
    if relayIND(i, 2) ~= 0  % Relay backup harus ada
        delta_waktu = waktu(i, 2) - waktu(i, 1); % Selisih waktu operasi relay

        if delta_waktu < CTI
            % Hitung penalti jika delta_waktu kurang dari CTI
            dummyP = CTI - delta_waktu;
            langgar = langgar + (2000 * dummyP);
        % elseif delta_waktu > CTI
        %     % Hitung penalti jika delta_waktu lebih dari CTI
        %     dummyP = delta_waktu - CTI;
        %     langgar = langgar + (2000 * dummyP);
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Batasan nilai TDS dan TOP serta CTI relay 12 dan relay 15 pengaturan nya harus sama

%% Batasan pengaturan relay 15, relay 04, dan relay 12
idx_12 = find([57, 17, 14, 12, 15, 04, 02, 01] == 12);
idx_15 = find([57, 17, 14, 12, 15, 04, 02, 01] == 15);
idx_04 = find([57, 17, 14, 12, 15, 04, 02, 01] == 04);

% TDS relay 15 dan relay 04 harus sama dengan relay 12
if x(idx_15) ~= x(idx_12)
    langgar = langgar + 2000 * abs(x(idx_15) - x(idx_12));
end
if x(idx_04) ~= x(idx_12)
    langgar = langgar + 2000 * abs(x(idx_04) - x(idx_12));
end

% TOP relay 15 dan relay 04 harus sama dengan relay 12
if waktu(idx_15, 1) ~= waktu(idx_12, 1)
    langgar = langgar + 2000 * abs(waktu(idx_15, 1) - waktu(idx_12, 1));
end
if waktu(idx_04, 1) ~= waktu(idx_12, 1)
    langgar = langgar + 2000 * abs(waktu(idx_04, 1) - waktu(idx_12, 1));
end

% CTI antara relay 12, relay 15, dan relay 04 harus sama dengan 0
if abs(waktu(idx_15, 1) - waktu(idx_12, 1)) > 0.01
    langgar = langgar + 2000 * abs(waktu(idx_15, 1) - waktu(idx_12, 1));
end
if abs(waktu(idx_04, 1) - waktu(idx_12, 1)) > 0.01
    langgar = langgar + 2000 * abs(waktu(idx_04, 1) - waktu(idx_12, 1));
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


%% Display Hasil

disp('================================================================================================================');
disp('                      Rele Primer                |                  Rele Backup                          ');
disp('================================================================================================================');
disp('     | ID Relay |  TDS  |   Curve Type   |  TOP  |  ID Relay  |  TDS  |  Curve Type  |    TOP    |     CTI     |');
disp('----------------------------------------------------------------------------------------------------------------');
for m = 1:JumlahRele
    relayName1 = relayIND(m,1);
    fprintf('  %10s', num2str(relayName1));

    if relayName1 ~= 0
        idx1 = find([57, 17, 14, 12, 15, 04, 02, 01] == relayName1);
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
        idx2 = find([57, 17, 14, 12, 15, 04, 02, 01] == relayName2);
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
% fprintf('fmin  : %4.3f\n', fmin);
end

