%% PREPARAZIONE WORKSPACE
close all;
clearvars;
clear global;
clc;
addpath('Functions')

TAB = 27;
Precisione.U  = 80;
Precisione.U1 = 80;
digits(70);
soglia=0.9;

%% CALCOLO INDICI DI PRESTAZIONE
fprintf("Gruppo 1 ->\n");
IP1 = AnalizzaSistema('P1',Precisione,       +inf,+inf);
fprintf("-> Gruppo 2 ->\n");
IP2 = AnalizzaSistema('P2',Precisione,IP1.TPU_OUT,+inf);
fprintf("-> Gruppo 3 ->\n");
IP3 = AnalizzaSistema('P3',Precisione,IP2.TPU_OUT,+inf);
fprintf("-> Gruppo 4\n");
IP4 = AnalizzaSistema('P4',Precisione,IP3.TPU_OUT,+inf);
fprintf("-> Gruppo 5\n");
IP4 = AnalizzaSistema('P5',Precisione,IP4.TPU_OUT,+inf);

fprintf("%f -> 1,2,3,4 ->%f\n " ,IP1.TPU_IN,IP1.TPU_OUT);
fprintf("%f -> 5,6 ->%f\n "     ,IP2.TPU_IN,IP2.TPU_OUT);
fprintf("%f -> 7 ->%f\n "       ,IP3.TPU_IN,IP3.TPU_OUT);
fprintf("%f -> 8,9 ->%f\n "     ,IP4.TPU_IN,IP4.TPU_OUT);
fprintf("%f -> 10,11,12,13 ->%f\n\n ",IP5.TPU_IN,IP5.TPU_OUT);

if IP5.TPU_IN < soglia*IP4.TPU_OUT 
    fprintf("<- Gruppo 4 <-\n");
    IP4 = AnalizzaSistema('P4',Precisione,1000, IP5.TPU_IN);
end

if IP4.TPU_IN < soglia*IP3.TPU_OUT 
    fprintf("<- Gruppo 3 <-\n");
    IP3 = AnalizzaSistema('P3',Precisione,1000, IP4.TPU_IN);
end
if IP3.TPU_IN < soglia*IP2.TPU_OUT
    fprintf("<- Gruppo 2 <-\n");
    IP2 = AnalizzaSistema('P2',Precisione,1000, IP3.TPU_IN);
end
if IP2.TPU_IN < soglia*IP1.TPU_OUT
    fprintf("Gruppo 1 <-\n");
    IP1 = AnalizzaSistema('P1',Precisione,1000, IP2.TPU_IN);
end
stampa="Il rapporto tra througput in ingresso al macchinario 5 e throughput in output al macchinario 4 è uguale a:";
disp(stampa, IP5.TPU_IN/IP4.TPU.OUT*100);
stampa="Il rapporto tra througput in ingresso al macchinario 4 e throughput in output al macchinario 3 è uguale a:";
disp(stampa, IP4.TPU_IN/IP3.TPU.OUT*100);
stampa="Il rapporto tra througput in ingresso al macchinario 3 e throughput in output al macchinario 2 è uguale a:";
disp(stampa, IP3.TPU_IN/IP2.TPU.OUT*100);
stampa="Il rapporto tra througput in ingresso al macchinario 2 e throughput in output al macchinario 1 è uguale a:";
disp(stampa, IP2.TPU_IN/IP1.TPU.OUT*100);
clear Precisione

%% RISULTATI
% Mancano i nastri trasportatori di collegamento e M7
Transizioni=[IP1.Transizioni; IP2.Transizioni; IP3.Transizioni; IP4.Transizioni];

Posti=[IP1.Posti; IP2.Posti; IP3.Posti; IP4.Posti];

WIP=IP1.WIP+IP2.WIP+IP3.WIP+IP4.WIP;

MLT=IP1.MLT+IP2.MLT+IP3.MLT+IP4.MLT;

TPU=IP4.TPU_OUT;

EFF=[IP1.Macchinari;IP2.Macchinari;IP3.Macchinari;IP4.Macchinari];

%% RAGGRUPPAMENTI
Dati=load('Dati\PN_Configurazione2.mat','PN');
Macchinari=Dati.PN.Gruppi(~cellfun(@isempty,Dati.PN.Gruppi.Transizioni),:);
Nastri=Dati.PN.Gruppi(cellfun(@isempty,Dati.PN.Gruppi.Transizioni),:);
for i=1:height(Macchinari)
    t=Macchinari.Transizioni{i};
    if i<10
        s="0";
    else
        s="";
    end
    for j=1:length(t)
        Transizioni.Gruppo(Transizioni.Transizione==t(j))=sprintf("%s%i_M",s,i); 
    end
    p=Macchinari.Posti{i};
    for j=1:length(p)
       Posti.Gruppo(Posti.Posto==p(j))=sprintf("%s%i_M",s,i); 
    end
end
for i=1:height(Nastri)
    p=Nastri.Posti{i};
    if i<10
        s="0";
    else
        s="";
    end
    for j=1:length(p)
       Posti.Gruppo(Posti.Posto==p(j))=sprintf("%s%i_N",s,i); 
    end
end
Transizioni=sortrows(Transizioni,"Gruppo");
Posti=sortrows(Posti,"Gruppo");
Transizioni=[Transizioni(:,end) Transizioni(:,1:end-1)];
Posti=[Posti(:,end) Posti(:,1:end-1)];

%% SALVATAGGIO
save("RisultatiAnalisi.mat",'EFF','Transizioni','Posti','WIP','TPU','MLT');