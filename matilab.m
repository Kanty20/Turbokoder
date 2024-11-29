clc; clear all;

%% MACIERZE GENERACYJNE %%

%Pamietaj zeby wartosci byly w zapisie Osemkowym, ponizej masz przyklady
%sa one 7 bitowe, bo constraintLength w poly2trellis jest rowne 7

g0 = 177; %1111111      
g1 = 131; %1011001     
g2 = 123; %1010011     
g3 = 105; %1000101     

generator_matrices = [g0 g1 g2 g3];
trellis = poly2trellis(7, generator_matrices);

%% WARTOSC DO ZAKODOWANIA %%

%wprowadz ile bitow chcesz zakodowac
amount = 1200;

%%%%%%%%%%%% WPROWADZ BINARNIE %%%%%%%%%%%%

% messageToEncode = '';
% 
% messageToEncode = decimalToBinaryVector(bin2dec(messageToEncode), amount);
% messageToEncode = logical(messageToEncode);

%%%%%%%%%%%% LUB HEX %%%%%%%%%%%%%%%%%

% messageToEncode = '736A';
% 
% messageToEncode = hexToBinaryVector(messageToEncode, amount);

%%%%%%%%%%%% LUB STRING %%%%%%%%%%%%%%%%%

messageToEncode = '1 1 1 0 1 0 1 0 1 0';
%messageToEncode = 'Vivamus tincidunt porta urna at commodo. Donec ut nisl iaculis, condimentum arcu et, ullamcorper augue. Aliquam vitae arcu laoreet, aliquet tellus eu.';
 
 messageToEncode = sprintf("%x", messageToEncode);
 messageToEncode = hexToBinaryVector(messageToEncode, amount);

%% KODOWANIE %%
 
display(messageToEncode, 'Wiadomosc przed zakodowaniem');

encodedMessage = convenc(messageToEncode,trellis);
display(encodedMessage, 'Wiadomosc po zakodowaniu');

% Otwórz plik .txt do zapisu
fileID = fopen('C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\encoded_message.txt', 'w');  % 'w' oznacza tryb zapisu

% Zamień binarny wektor na tekstową reprezentację (ciąg znaków)
binaryString = num2str(encodedMessage);

% Usuwanie spacje
binaryString = strrep(binaryString, ' ', '');

% Zapisz binarny ciąg do pliku
fprintf(fileID, '%s', binaryString);

% Zamknij plik
fclose(fileID);

% Wyświetl informację o zapisaniu pliku
disp('Wiadomość binarna została zapisana do pliku binary_message.txt');

%% DEKODOWANIE %%

len = length(messageToEncode);
decodedMessage = vitdec(encodedMessage,trellis,len,'trunc','hard');

display(decodedMessage, 'Wiadomosc po zdekodowaniu BINARNIE');
display(binaryVectorToHex(decodedMessage), 'Wiadomosc po zdekodowaniu HEX');



%Na ascii juz mi sie nie chce klepac w matlabie, tu masz link do
%dekodowania HEX na ascii
%https://www.rapidtables.com/convert/number/hex-to-ascii.html