%% PREPARAZIONE WORKSPACE
close all;
clearvars;
clear global;
clc;
addpath('Functions')

TAB = 27;
Precisione.U  = 20;
Precisione.U1 = 20;

soglia=0.9;
log=1;
versione=5;
indice_macchinario=["M1","M2","M3","M4","M5","M6","M7_1","M7_2","M7_3","M8","M9","M10","M11_12_13"];
l_im=length(indice_macchinario);


%% CALCOLO INDICI DI PRESTAZIONE
IPx(1)= AnalizzaSistema(versione,  indice_macchinario(1), Precisione,log, realmax,realmax);

for i=2:l_im
    IPx(i)= AnalizzaSistema(versione,  indice_macchinario(i),Precisione,log, IPx(i-1).TPU_OUT,realmax);
    fprintf("Macchinario %s->\n",indice_macchinario(i));
end

for i=1:l_im
    fprintf("%f -> Macchinario %s ->%f\n "      ,IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
end

for i=0:l_im-2
if IPx(l_im-i).TPU_IN < soglia*IPx(l_im-(i+1)).TPU_OUT
    fprintf("<- Macchinario %s <-\n",indice_macchinario(l_im-i));
    IPx(l_im-(i+1)) = AnalizzaSistema(versione, indice_macchinario(l_im-(i+1)),Precisione,realmax, IPx(l_im-i).TPU_IN);
    fprintf("Il rapporto tra througput in ingresso al macchinario %s e throughput in output al macchinario %s è uguale a: %f %%",indice_macchinario(l_im-i),indice_macchinario(l_im-(i+1)), (IPx(l_im-i).TPU_IN/IPx(l_im-(i+1)).TPU_OUT)*100);
end
end


for i=1:l_im
    fprintf("%f -> Macchinario %s ->%f\n "      ,IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
end
clear Precisione

%% RISULTATI
WIP=sum(IPx(:).WIP);
MLT=sum(IPx(:).MLT);
TPU=IPx(l_im).TPU_OUT;

for i=1:l_im
    Transizioni(i)=IPx(i).Transizioni;
    Posti(i)=IPx(i).Posti;
    EFF(i)=IPx(i).Macchinari;
end


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