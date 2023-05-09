%% PREPARAZIONE WORKSPACE
close all;
clearvars;
clear global;
clc;
addpath('Functions');

TAB = 27;
Precisione.U  = 65;
Precisione.U1 = 65;

%% CALCOLO INDICI DI PRESTAZIONE
fprintf("Gruppo 1 ->\n");
IP1 = AnalizzaSistema_2( '1,2,3,4',Precisione,0);
fprintf("-> Gruppo 2 ->\n");
IP2 = AnalizzaSistema_2(     '5,6',Precisione,IP1.TPU_OUT);
fprintf("-> Gruppo 3 ->\n");
IP3 = AnalizzaSistema_2(  '8,9,10',Precisione,IP2.TPU_OUT);
fprintf("-> Gruppo 4\n");
IP4 = AnalizzaSistema_2('11,12,13',Precisione,IP3.TPU_OUT);

fprintf("%f -> 1,2,3,4 ->%f\n " ,IP1.TPU_IN,IP1.TPU_OUT);
fprintf("%f -> 5,6 ->%f\n "     ,IP2.TPU_IN,IP2.TPU_OUT);
fprintf("%f -> 8,9,10 ->%f\n "  ,IP3.TPU_IN,IP3.TPU_OUT);
fprintf("%f -> 11,12,13 ->%f\n\n ",IP4.TPU_IN,IP4.TPU_OUT);

% if IP4.TPU_IN < IP3.TPU_OUT 
%     fprintf("<- Gruppo 3 <-\n");
%     IP3 = AnalizzaSistema_2(  '8,9,10',Precisione);
% end
% if IP3.TPU_IN < IP2.TPU_OUT
%     fprintf("<- Gruppo 2 <-\n");
%     IP2 = AnalizzaSistema_2(     '5,6',Precisione);
% end
% if IP2.TPU_IN < IP1.TPU_OUT
%     fprintf("Gruppo 1 <-\n");
%     IP1 = AnalizzaSistema_2( '1,2,3,4',Precisione);
% end

clear Precisione

%% RISULTATI
% Mancano i nastri trasportatori di collegamento e M7
Transizioni=[IP1.Transizioni; IP2.Transizioni; IP3.Transizioni; IP4.Transizioni];

Posti=[IP1.Posti; IP2.Posti; IP3.Posti; IP4.Posti];

WIP=IP1.WIP+IP2.WIP+IP3.WIP+IP4.WIP;

MLT=IP2.MLT+IP2.MLT+IP3.MLT+IP4.MLT;

TPU=IP4.TPU_OUT;

EFF=[IP1.Macchinari;IP2.Macchinari; IP3.Macchinari;IP4.Macchinari];

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