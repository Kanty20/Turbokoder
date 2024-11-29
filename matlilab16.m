clc; clear all;

%% MACIERZE GENERACYJNE %%

% Pamietaj zeby wartosci byly w zapisie osemkowym
g0 = 177; % 1111111      
g1 = 131; % 1011001     
g2 = 123; % 1010011     
g3 = 105; % 1000101     

generator_matrices = [g0 g1 g2 g3];
trellis = poly2trellis(7, generator_matrices);

%% WARTOŚĆ DO ZAKODOWANIA %%

% Ustal ilość bitów do zakodowania
amount = 16;

% Wprowadź dane wejściowe (16-bitowa wiadomość binarna)
messageToEncode = '1000011101010100'; % Przykładowa wiadomość 16-bitowa

% Zamiana na wektor logiczny
messageToEncode = logical(messageToEncode - '0'); % Zamienia string binarny na wektor logiczny

%% KODOWANIE %%

display(messageToEncode, 'Wiadomosc przed zakodowaniem');

% Kodowanie wiadomości
encodedMessage = convenc(messageToEncode, trellis);

% Ograniczenie wyjścia do 64 bitów
encodedMessage = encodedMessage(1:64);

% Wyświetlenie zakodowanej wiadomości
display(encodedMessage, 'Wiadomosc po zakodowaniu');

% Zapis zakodowanej wiadomości do pliku
fileID = fopen('encoded_message_64bit.txt', 'w');
binaryString = strrep(num2str(encodedMessage), ' ', '');
fprintf(fileID, '%s', binaryString);
fclose(fileID);
disp('Zakodowana wiadomość została zapisana do pliku encoded_message_64bit.txt.');

%% DEKODOWANIE %%

len = length(messageToEncode);
decodedMessage = vitdec(encodedMessage, trellis, len, 'trunc', 'hard');

% Wyświetlenie zdekodowanej wiadomości
display(decodedMessage, 'Wiadomosc po zdekodowaniu BINARNIE');
display(binaryVectorToHex(decodedMessage), 'Wiadomosc po zdekodowaniu HEX');
