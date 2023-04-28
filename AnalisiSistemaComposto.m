%% PREPARAZIONE WORKSPACE
close all;
clearvars;
clear global;
clc;
addpath('Functions')

TAB = 27;
Precisione.U  = 65;
Precisione.U1 = 65;

%% CALCOLO INDICI DI PRESTAZIONE
fprintf("Gruppo 1 ->\n");
IP1 = AnalizzaSistema( '1,2,3,4',Precisione,       +inf);
fprintf("-> Gruppo 2 ->\n");
IP2 = AnalizzaSistema(     '5,6',Precisione,IP1.TPU_OUT);
fprintf("-> Gruppo 3 ->\n");
IP3 = AnalizzaSistema(  '8,9,10',Precisione,IP2.TPU_OUT);
fprintf("-> Gruppo 4\n");
IP4 = AnalizzaSistema('11,12,13',Precisione,IP3.TPU_OUT);

fprintf("%f -> 1,2,3,4 ->%f\n " ,IP1.TPU_IN,IP1.TPU_OUT);
fprintf("%f -> 5,6 ->%f\n "     ,IP2.TPU_IN,IP2.TPU_OUT);
fprintf("%f -> 8,9,10 ->%f\n "  ,IP3.TPU_IN,IP3.TPU_OUT);
fprintf("%f -> 11,12,13 ->%f\n ",IP4.TPU_IN,IP4.TPU_OUT);

if IP4.TPU_IN < IP3.TPU_OUT 
    fprintf("<- Gruppo 3 <-\n");
    IP3 = AnalizzaSistema(  '8,9,10',Precisione, IP4.TPU_IN);
end
if IP3.TPU_IN < IP2.TPU_OUT
    fprintf("<- Gruppo 2 <-\n");
    IP2 = AnalizzaSistema(     '5,6',Precisione, IP3.TPU_IN/0.7);
end
if IP2.TPU_IN < IP1.TPU_OUT
    fprintf("Gruppo 1 <-\n");
    IP1 = AnalizzaSistema( '1,2,3,4',Precisione, IP2.TPU_IN);
end

clear Precisione

%% RISULTATI
% Mancano i nastri trasportatori di collegamento e M7
Transizioni=[IP1.Transizioni; IP2.Transizioni; IP3.Transizioni; IP4.Transizioni];
Posti=[IP1.Posti; IP2.Posti; IP3.Posti; IP4.Posti];
WIP=IP1.WIP+IP2.WIP+IP3.WIP+IP4.WIP;
MLT=IP1.MLT+IP2.MLT+IP3.MLT+IP4.MLT;
TPU=IP4.TPU_OUT;
EFF=[IP1.Macchinari;IP2.Macchinari;IP3.Macchinari;IP4.Macchinari];
