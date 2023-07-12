function tp = SistemaThroughput(tp,macchinari,PN)
% SistemaThroughput è una funzione che completa i valori di throughput per
% le transizioni immediate, nota la conoscenza dei legami presenti nella
% GSPN.
% **INPUT**
%   tp
%    il vettore dei throughput con i valori relativi alle sole transizioni 
%    temporizzate
%   macchinari
%    i macchinari presenti all'interno del vettore tp
%   PN
%    la rete di petri per individuare gli indici delle transizioni
% **OUTPUT**
%   tp
%    il vettore dei throughput con tutti i valori completati
%
% Authors:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

if ismember('1',macchinari)
    id_CaricamentoM1 = PN.T.Transizione=="M1_Caricamento";
    id_LavorazioneM1 = PN.T.Transizione=="M1_Assembla";
    id_ScaricamentoM1 = PN.T.Transizione=="M1_Scaricamento";
    
    tp(id_CaricamentoM1)=tp(id_LavorazioneM1);
    tp(id_ScaricamentoM1)=tp(id_LavorazioneM1);
    clear id_CaricamentoM1 id_M1Lavorazione id_ScaricamentoM1
end
if ismember('2',macchinari)
    id_CaricamentoInfM2 = PN.T.Transizione=="M2_CaricamentoInf";
    id_CaricamentoSupM2 = PN.T.Transizione=="M2_CaricamentoSup";
    id_LavorazioneM2 = find(PN.T.Transizione=="M2_Assembla");
    id_ScaricamentoM2 = PN.T.Transizione=="M2_Scaricamento";
    
    tp(id_CaricamentoInfM2)=tp(id_LavorazioneM2);
    tp(id_CaricamentoSupM2)=tp(id_LavorazioneM2);
    tp(id_ScaricamentoM2)=tp(id_LavorazioneM2);
    clear id_CaricamentoInfM2 id_CaricamentoSupM2 id_M2Lavorazione id_ScaricamentoM2
end
if ismember('3',macchinari)
    id_CaricamentoM3 = PN.T.Transizione=="M3_Caricamento";
    id_LavorazioneM3 = PN.T.Transizione=="M3_Scalda";
    id_ScaricamentoM3 = PN.T.Transizione=="M3_Scaricamento";
    
    tp(id_CaricamentoM3)=tp(id_LavorazioneM3);
    tp(id_ScaricamentoM3)=tp(id_LavorazioneM3);
    clear id_CaricamentoM3 id_M3Lavorazione id_ScaricamentoM3
end
if ismember('4',macchinari)
    id_CaricamentoInfM4 = PN.T.Transizione=="M4_CaricamentoBatteria";
    id_CaricamentoSupM4 = PN.T.Transizione=="M4_CaricamentoIndicatore";
    id_LavorazioneM4 = find(PN.T.Transizione=="M4_Assembla");
    id_ScaricamentoM4 = PN.T.Transizione=="M4_Scaricamento";
    
    tp(id_CaricamentoInfM4)=tp(id_LavorazioneM4);
    tp(id_CaricamentoSupM4)=tp(id_LavorazioneM4);
    tp(id_ScaricamentoM4)=tp(id_LavorazioneM4);
    clear id_CaricamentoInfM4 id_CaricamentoSupM4 id_M4Lavorazione id_ScaricamentoM4
end
if ismember('5',macchinari)
    id_CaricamentoM5 = PN.T.Transizione=="M5_Caricamento";
    id_TP1OK = find(PN.T.Transizione=="M5_TPOK");
    id_TP1KO = find(PN.T.Transizione=="M5_TPKO");
    id_M5Test = find(PN.T.Transizione=="M5_Test");
    id_ScaricamentoM5 = PN.T.Transizione=="M5_Scaricamento";
    id_ScartoBatterie = PN.T.Transizione=="M5_ScartoBatteria";
    
    tp(id_CaricamentoM5)=tp(id_M5Test);
    tp(id_TP1KO)=tp(id_M5Test)*PN.T.Peso(id_TP1KO)/(PN.T.Peso(id_TP1KO)+PN.T.Peso(id_TP1OK));
    tp(id_TP1OK)=tp(id_M5Test)*PN.T.Peso(id_TP1OK)/(PN.T.Peso(id_TP1KO)+PN.T.Peso(id_TP1OK));
    tp(id_ScaricamentoM5)=tp(id_TP1OK);
    tp(id_ScartoBatterie)=tp(id_TP1KO);
    clear id_TP1KO id_M5Test id_TP1OK
end
if ismember('6',macchinari)
    id_CaricamentoM6 = PN.T.Transizione=="M6_Caricamento";
    id_ANM6I = PN.T.Transizione=="M6_AvanzaNastroInput";
    id_ANM6O = PN.T.Transizione=="M6_AvanzaNastroOutput";
    id_APM6I1 = PN.T.Transizione=="M6_1_AvanzaPistoneInput";
    id_APM6I2 = PN.T.Transizione=="M6_2_AvanzaPistoneInput";
    id_APM6O1 = PN.T.Transizione=="M6_1_AvanzaPistoneOutput";
    id_APM6O2 = PN.T.Transizione=="M6_2_AvanzaPistoneOutput";
    id_M6_1 = find(PN.T.Transizione=="M6_1_Riempie");
    id_M6_2 = find(PN.T.Transizione=="M6_2_Riempie");
    id_ScaricamentoM6 = PN.T.Transizione=="M6_Scaricamento";

    tp(id_APM6I1)=tp(id_M6_1);
    tp(id_APM6I2)=tp(id_M6_2);
    tp(id_APM6O1)=tp(id_M6_1);
    tp(id_APM6O2)=tp(id_M6_2);
    tp(id_ANM6I)=tp(id_M6_2);
    tp(id_ANM6O)=tp(id_M6_1);
    tp(id_CaricamentoM6)=tp(id_M6_1)+tp(id_M6_2);
    tp(id_ScaricamentoM6)=tp(id_M6_1)+tp(id_M6_2);
end
if ismember('7',macchinari)
    id_M7Car = PN.T.Transizione=="M7_Caricamento";
    id_M7Lav = PN.T.Transizione=="M7_Formazione_Batterie";
    id_M7Sca = PN.T.Transizione=="M7_Scaricamento";

    tp(id_M7Car)=tp(id_M7Lav);
    tp(id_M7Sca)=tp(id_M7Lav);
end
if ismember('8',macchinari)
    id_CaricamentoM8 = PN.T.Transizione=="M8_Caricamento";
    id_R1 = PN.T.Transizione=="M8_R1";
    id_R2 = PN.T.Transizione=="M8_R2";
    id_R3 = PN.T.Transizione=="M8_R3";
    id_R4 = PN.T.Transizione=="M8_R4";
    id_R5 = PN.T.Transizione=="M8_R5";
    id_R6 = PN.T.Transizione=="M8_R6";
    id_R7 = PN.T.Transizione=="M8_R7";
    id_ScaricamentoM8 = PN.T.Transizione=="M8_Scaricamento";

    tp(id_CaricamentoM8)=tp(id_R1)+tp(id_R2)+tp(id_R3)+tp(id_R4)+tp(id_R5)+tp(id_R6)+tp(id_R7);
    tp(id_ScaricamentoM8)=tp(id_R1)+tp(id_R2)+tp(id_R3)+tp(id_R4)+tp(id_R5)+tp(id_R6)+tp(id_R7);
    clear id_ScaricamentoM8 id_R7 id_R6 id_R5 id_R4
end
if ismember('9',macchinari)
    id_CaricamentoM9 = PN.T.Transizione=="M9_Caricamento";
    id_ANM9I = PN.T.Transizione=="M9_AvanzaNastroInput";
    id_ANM9O = PN.T.Transizione=="M9_AvanzaNastroOutput";
    id_APM9I1 = PN.T.Transizione=="M9_1_AvanzaPistoneInput";
    id_APM9I2 = PN.T.Transizione=="M9_2_AvanzaPistoneInput";
    id_APM9O1 = PN.T.Transizione=="M9_1_AvanzaPistoneOutput";
    id_APM9O2 = PN.T.Transizione=="M9_2_AvanzaPistoneOutput";
    id_M9_1 = find(PN.T.Transizione=="M9_1_Rinnova");
    id_M9_2 = find(PN.T.Transizione=="M9_2_Rinnova");
    id_ScaricamentoM9 = PN.T.Transizione=="M9_Scaricamento";

    tp(id_APM9I1)=tp(id_M9_1);
    tp(id_APM9I2)=tp(id_M9_2);
    tp(id_APM9O1)=tp(id_M9_1);
    tp(id_APM9O2)=tp(id_M9_2);
    tp(id_ANM9I)=tp(id_M9_2);
    tp(id_ANM9O)=tp(id_M9_2);
    tp(id_CaricamentoM9)=tp(id_M9_1)+tp(id_M9_2);
    tp(id_ScaricamentoM9)=tp(id_M9_1)+tp(id_M9_2);
end
if ismember('10',macchinari)
    id_CarInfM10 = PN.T.Transizione=="M10_CaricamentoBase";
    id_CarSupM10 = PN.T.Transizione=="M10_CaricamentoSecondaCopertura";
    id_ScaricamentoM10 = PN.T.Transizione=="M10_Scaricamento";
    id_M10Lavorazione = find(PN.T.Transizione=="M10_Assembla");
    
    tp(id_CarInfM10)=tp(id_M10Lavorazione);
    tp(id_CarSupM10)=tp(id_M10Lavorazione);
    tp(id_ScaricamentoM10)=tp(id_M10Lavorazione);
    clear id_TP2KO id_M11Test id_TP2OK
end
if ismember('11',macchinari)
    id_CaricamentoM11 = PN.T.Transizione=="M11_Caricamento";
    id_TP2OK = find(PN.T.Transizione=="M11_OK");
    id_TP2KO = find(PN.T.Transizione=="M11_KO");
    id_M11Test = find(PN.T.Transizione=="M11_Test");
    id_ScaricamentoM11 = PN.T.Transizione=="M11_Scaricamento";
    id_ScartoBatterie = PN.T.Transizione=="M11_ScartoBatterie";
    
    tp(id_CaricamentoM11)=tp(id_M11Test);
    tp(id_TP2KO)=tp(id_M11Test)*PN.T.Peso(id_TP2KO)/(PN.T.Peso(id_TP2KO)+PN.T.Peso(id_TP2OK));
    tp(id_TP2OK)=tp(id_M11Test)*PN.T.Peso(id_TP2OK)/(PN.T.Peso(id_TP2KO)+PN.T.Peso(id_TP2OK));
    tp(id_ScaricamentoM11)=tp(id_TP2OK);
    tp(id_ScartoBatterie)=tp(id_TP2KO);
    clear id_TP1KO id_M5Test id_TP1OK
end
end

