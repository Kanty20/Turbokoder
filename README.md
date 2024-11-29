# Dzialajacy-dekoder

Jest to działający dekoder z pozostałymi plikami. Obecnie kod jest na etapie że sam koder i dekoder działa, teraz należy wszystko połączyć do central.
Dekoder jest dla 64 bitów, w przypadku gdyby chcieć mieć 4800 bitów ilość outputsów będzie taka sama.
Dodatkowo przesyłam skrypt z matlaba żeby pamiętać jak się robiło dekoder i koder. Jedynie co trzeba sobie dopisać do swojego kompa odpowiednie ścieżki plików. 

## Co tu jest (VHDL):
- central - main plik
- test - testbench 
- UART_TX - TX 
- UART_RX - RX
- odfiltrowanie przycisku - na przycisk zostają wysłane zakodowane wiadomości
- koder 
- dekoder

## Co tu jest (Matlab):
- matilab - najbardziej ogólny i dokładny plik,
- matilab16 - skupiony konkretnie na 16 bitow, koduje i dekoduje na 64 bity
- dekoder - w sumie nawet nie pamietam

## Co tu jest:
- dodałam jeszcze literature od prof. Kabacika- dwie rozprawy doktorskie
- czołowy plik- L09-viterbi, z którego korzystano do wypełnienia tego zadania. W przypadku dekodera korzystano z wersji 'hard', a nie 'soft'
