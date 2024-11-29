clear all;
% m = 6+1;
% g = [177 131 123 105] %osemkowo
% 
% trellis = poly2trellis(m,g)
% codec = convenc([0 1 1 0 1 0 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1 0 1 0 1 1 1 1 1 1 0 1 0 1 1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1 1 0 1 0 1 0 0 0 1 1 1 1 0 1], trellis);
% vitdec(codec,trellis,2,"trunc",'hard')
% 
% column_index1 = 1;  % Zmienna określająca, którą kolumnę wybieramy (1 dla pierwszej, 2 dla drugiej)
% column_index2 = 2;  
% selected_column1 = trellis.outputs(:, column_index1);
% selected_column2 = trellis.outputs(:, column_index2);
% 
% % disp('Kolumna 1 i 2:');
% % for i = 1:length(selected_column1)
% %     fprintf('"%s", "%s", "%s", "%s", "%s", \n', dec2bin(selected_column1(i), 4), dec2bin(selected_column2(i), 4));
% % end
%
% %jak popsuje sie do konca to patrz na zdjecie

% ctrl + r zak
% ctrl + t odk

%%

% m = 6 + 1;
% g = [177 131 123 105];  % osemkowo
% 
% % Definicja trellisu
% trellis = poly2trellis(m, g);
% 
% % Zakodowanie przykładowego ciągu
% input_bits = [0 1 1 0 1 0 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1 0 1 0 1 1 1 1 1 1 0 1 0 1 1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1 1 0 1 0 1 0 0 0 1 1 1 1 0 1];
% codec = convenc(input_bits, trellis);
% 
% % Dekodowanie zakodowanego ciągu
% decoded_bits = vitdec(codec, trellis, 2, "trunc", 'hard');
% 
% % Wybranie kolumn do wyświetlenia
% column_index1 = 1;  % Pierwsza kolumna
% column_index2 = 2;  % Druga kolumna
% selected_column1 = trellis.outputs(:, column_index1);
% selected_column2 = trellis.outputs(:, column_index2);
% 
% % Wyświetlenie wyniku dekodowania
% disp('Zakodowany ciąg:');
% disp(codec);
% 
% disp('Zdekodowany ciąg:');
% disp(decoded_bits);

% (Opcjonalnie) Wyświetlenie kolumn trellisu
% disp('Kolumna 1 i 2:');
% for i = 1:length(selected_column1)
%     fprintf('"%s", "%s"\n', dec2bin(selected_column1(i), 4), dec2bin(selected_column2(i), 4));
% end

%%

m = 6 + 1;
g = [177 131 123 105];  % osemkowo

% Definicja trellisu
trellis = poly2trellis(m, g);

% Zakodowanie przykładowego ciągu
input_bits = [0 1 1 1 1 0 0 1 1 0 0 1 0 0 1 0];
codec = convenc(input_bits, trellis);

% Ustalanie długości okna dla dekodera (traceback) na 16
traceback = 16;

% Dekodowanie zakodowanego ciągu
decoded_bits = vitdec(codec, trellis, traceback, "trunc", 'hard');

% Wyświetlenie wyniku dekodowania
disp('Koduje ciąg:');
disp(codec);

disp('Zdekodowany ciąg:');
disp(decoded_bits);

% plik do zapisu
fileID = fopen('matlab_porownanie_64bto16b.txt', 'w');

% Zapisanie wartości codec do pliku jako ciąg liczb
fprintf(fileID, '%d ', codec);

% Zamknięcie pliku
fclose(fileID);

disp('Zakodowany ciąg został zapisany do pliku matlab_porownanie_64bto16b.txt');
