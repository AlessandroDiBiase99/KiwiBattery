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

if ismember('1',macchinari)
    id_CaricamentoM1 = PN.T.Transizione=="CaricamentoM1";
    id_LavorazioneM1 = find(PN.T.Transizione=="M1Lavorazione");
    id_ScaricamentoM1 = PN.T.Transizione=="ScaricamentoM1";
    
    tp(id_CaricamentoM1)=tp(id_LavorazioneM1);
    tp(id_ScaricamentoM1)=tp(id_LavorazioneM1);
    clear id_CaricamentoM1 id_M1Lavorazione id_ScaricamentoM1
end
if ismember('2',macchinari)
    id_CaricamentoInfM2 = PN.T.Transizione=="CaricamentoInferioreM2";
    id_CaricamentoSupM2 = PN.T.Transizione=="CaricamentoSuperioreM2";
    id_LavorazioneM2 = find(PN.T.Transizione=="M2Lavorazione");
    id_ScaricamentoM2 = PN.T.Transizione=="IndietreggiamentoPistone1";
    
    tp(id_CaricamentoInfM2)=tp(id_LavorazioneM2);
    tp(id_CaricamentoSupM2)=tp(id_LavorazioneM2);
    tp(id_ScaricamentoM2)=tp(id_LavorazioneM2);
    clear id_CaricamentoInfM2 id_CaricamentoSupM2 id_M2Lavorazione id_ScaricamentoM2
end
if ismember('3',macchinari)
    id_CaricamentoM3 = PN.T.Transizione=="CaricamentoM3";
    id_LavorazioneM3 = find(PN.T.Transizione=="M3Lavorazione");
    id_ScaricamentoM3 = PN.T.Transizione=="ScaricamentoM3";
    
    tp(id_CaricamentoM3)=tp(id_LavorazioneM3);
    tp(id_ScaricamentoM3)=tp(id_LavorazioneM3);
    clear id_CaricamentoM3 id_M3Lavorazione id_ScaricamentoM3
end
if ismember('4',macchinari)
    id_CaricamentoInfM4 = PN.T.Transizione=="CaricamentoBatteriaM4";
    id_CaricamentoSupM4 = PN.T.Transizione=="CaricamentoIndicatoreM4";
    id_LavorazioneM4 = find(PN.T.Transizione=="M4Lavorazione");
    id_ScaricamentoM4 = PN.T.Transizione=="ScaricamentoM4";
    
    tp(id_CaricamentoInfM4)=tp(id_LavorazioneM4);
    tp(id_CaricamentoSupM4)=tp(id_LavorazioneM4);
    tp(id_ScaricamentoM4)=tp(id_LavorazioneM4);
    clear id_CaricamentoInfM4 id_CaricamentoSupM4 id_M4Lavorazione id_ScaricamentoM4
end
if ismember('5',macchinari)
    id_CaricamentoM5 = PN.T.Transizione=="CaricamentoM5";
    id_TP1OK = find(PN.T.Transizione=="TP1OK");
    id_TP1KO = find(PN.T.Transizione=="TP1KO");
    id_M5Test = find(PN.T.Transizione=="M5Test");
    id_ScaricamentoM5 = PN.T.Transizione=="ScaricamentoM5";
    id_ScartoBatterie = PN.T.Transizione=="ScartoBatteriaM5";
    
    tp(id_CaricamentoM5)=tp(id_M5Test);
    tp(id_TP1KO)=tp(id_M5Test)*PN.T.Peso(id_TP1KO)/(PN.T.Peso(id_TP1KO)+PN.T.Peso(id_TP1OK));
    tp(id_TP1OK)=tp(id_M5Test)*PN.T.Peso(id_TP1OK)/(PN.T.Peso(id_TP1KO)+PN.T.Peso(id_TP1OK));
    tp(id_ScaricamentoM5)=tp(id_TP1OK);
    tp(id_ScartoBatterie)=tp(id_TP1KO);
    clear id_TP1KO id_M5Test id_TP1OK
end
if ismember('6',macchinari)
    id_CaricamentoM6 = PN.T.Transizione=="CaricamentoNM6";
    id_ANM6I = PN.T.Transizione=="A_NM6I";
    id_ANM6O = PN.T.Transizione=="A_NM6O";
    id_APM6I1 = PN.T.Transizione=="APM6I_1";
    id_APM6I2 = PN.T.Transizione=="APM6I_2";
    id_APM6O1 = PN.T.Transizione=="APM6O_1";
    id_APM6O2 = PN.T.Transizione=="APM6O_2";
    id_M6_1 = find(PN.T.Transizione=="M6_1Lavorazione");
    id_M6_2 = find(PN.T.Transizione=="M6_2Lavorazione");
    id_ScaricamentoM6 = PN.T.Transizione=="ScaricamentoM6";

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
    id_M7Car = PN.T.Transizione=="CaricamentoM7";
    id_M7Lav = PN.T.Transizione=="FormazioneBatterie";
    id_M7Sca = PN.T.Transizione=="ScaricamentoM7";

    tp(id_M7Car)=tp(id_M7Lav);
    tp(id_M7Sca)=tp(id_M7Lav);
end

if ismember('8',macchinari)
    id_CaricamentoM8 = PN.T.Transizione=="CaricamentoM8";
    id_R1 = PN.T.Transizione=="R1";
    id_R2 = PN.T.Transizione=="R2";
    id_R3 = PN.T.Transizione=="R3";
    id_R4 = PN.T.Transizione=="R4";
    id_R5 = PN.T.Transizione=="R5";
    id_R6 = PN.T.Transizione=="R6";
    id_R7 = PN.T.Transizione=="R7";
    id_ScaricamentoM8 = PN.T.Transizione=="ScaricamentoM8";

    tp(id_CaricamentoM8)=tp(id_R1)+tp(id_R2)+tp(id_R3)+tp(id_R4)+tp(id_R5)+tp(id_R6)+tp(id_R7);
    tp(id_ScaricamentoM8)=tp(id_R1)+tp(id_R2)+tp(id_R3)+tp(id_R4)+tp(id_R5)+tp(id_R6)+tp(id_R7);
    clear id_ScaricamentoM8 id_R7 id_R6 id_R5 id_R4
end
if ismember('9',macchinari)
    id_CaricamentoM9 = PN.T.Transizione=="CaricamentoNM9";
    id_ANM9I = PN.T.Transizione=="A_NM9I";
    id_ANM9O = PN.T.Transizione=="A_NM9O";
    id_APM9I1 = PN.T.Transizione=="APM9I_1";
    id_APM9I2 = PN.T.Transizione=="APM9I_2";
    id_APM9O1 = PN.T.Transizione=="APM9O_1";
    id_APM9O2 = PN.T.Transizione=="APM9O_2";
    id_M9_1 = find(PN.T.Transizione=="M9_1Lavorazione");
    id_M9_2 = find(PN.T.Transizione=="M9_2Lavorazione");
    id_ScaricamentoM9 = PN.T.Transizione=="ScaricamentoM9";

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
    id_CarInfM10 = PN.T.Transizione=="CaricamentoInferioreM10";
    id_CarSupM10 = PN.T.Transizione=="CaricamentoSuperioreM10";
    id_ScaricamentoM10 = PN.T.Transizione=="IndietreggiamentoPistone2";
    id_M10Lavorazione = find(PN.T.Transizione=="M10Lavorazione");
    
    tp(id_CarInfM10)=tp(id_M10Lavorazione);
    tp(id_CarSupM10)=tp(id_M10Lavorazione);
    tp(id_ScaricamentoM10)=tp(id_M10Lavorazione);
    clear id_TP2KO id_M11Test id_TP2OK
end
if ismember('11',macchinari)
    id_CaricamentoM11 = PN.T.Transizione=="CaricamentoM11";
    id_TP2OK = find(PN.T.Transizione=="TP2OK");
    id_TP2KO = find(PN.T.Transizione=="TP2KO");
    id_M11Test = find(PN.T.Transizione=="M11Test");
    id_ScaricamentoM11 = PN.T.Transizione=="ScaricamentoM11";
    id_ScartoBatterie = PN.T.Transizione=="ScartoBatterieM11";
    
    tp(id_CaricamentoM11)=tp(id_M11Test);
    tp(id_TP2KO)=tp(id_M11Test)*PN.T.Peso(id_TP2KO)/(PN.T.Peso(id_TP2KO)+PN.T.Peso(id_TP2OK));
    tp(id_TP2OK)=tp(id_M11Test)*PN.T.Peso(id_TP2OK)/(PN.T.Peso(id_TP2KO)+PN.T.Peso(id_TP2OK));
    tp(id_ScaricamentoM11)=tp(id_TP2OK);
    tp(id_ScartoBatterie)=tp(id_TP2KO);
    clear id_TP1KO id_M5Test id_TP1OK
end
end

