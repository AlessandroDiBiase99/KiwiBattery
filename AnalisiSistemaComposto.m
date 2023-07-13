%% ======================= ANALIZZASISTEMACOMPOSTO ========================  
%==============AUTHORS==============%
%   Alessandro Di Biase             %
%   Federico Catalini               %
%   Luca Caponi                     %
%===================================%
% Questo script permette di analizzare rete di petri scomposte in
% sotto-gruppi. L'analisi risulta automatizzata, si deve configurare
% correttamente l'ambiente predisponendo in una cartella
% Parti_v<numerointero> i files PN_<indice> e Grafo_<indice>. Le due 
% tipologie di file possono essere facilmente realizzati grazie 
% all'applicativo GestoreAnalisiPN. In questo script specificare solo le 
% impostazioni, saranno generati all'interno della cartella i files 
% IP_<indice> con i risultati di ogni sotto-gruppo.

%% PREPARAZIONE WORKSPACE__________________________________________________
close all;                          
clearvars;                       
clc;
addpath('Functions');

%% IMPOSTAZIONI____________________________________________________________
% La cartella Parti_v<versione> da considerare:
versione=1;

% La precisione con la quale arrotonare le matrici U e U'
Precisione.U  = 5;
Precisione.U1 = 5;

% La soglia al di sotto della quale confermiamo la presenza di un collo di
% bottiglia, dunque risulta necessario eseguire un ricalcolo all'indietro
soglia=0.985;

% Scegliere il diverso livello di log:
% 0          -> mostrare tutti i messaggi
% 1          -> mostrare solo i messaggi principali
% altrimenti -> mostrare solo i messaggi di errore 
log=0;

% La modalità di analisi del sistema:
% <> analizza dall'ultimo sistema al primo, e verifica la necessità di
%    ricalcolo dal primo all'ultimo. Indietro -> avanti. 
% >< analizza dal primo sistema all'ultimo, e verifica la necessità di
%    ricalcolo dall'ultimo al primo. Avanti -> indietro.
direzione="><";

% Il vettore che contiene i diversi file da analizzare, elencati dal primo
% all'ultimo
indice_macchinario=["M1","M2","M3","M4","M5","M6","M7_1","M7_2","M7_3","M8","M9","M10","M11_12_13"];

%% CALCOLO INDICI DI PRESTAZIONE___________________________________________
% Inizializzo i parametri utili per l'esecuzione
l_im=length(indice_macchinario);
r_out2=[];

if(direzione=="<>") % <<<<<<<<<<<<< -> >>>>>>>>>>>>________________________
    fprintf("<_____Macchinario %s%s<\n",indice_macchinario(l_im),repmat('_',1,12-length(char(indice_macchinario(l_im)))));
    IPx(l_im)= AnalizzaSistema(versione,  indice_macchinario(l_im), Precisione,log, realmax,0);
    for i=l_im-1:-1:2
        fprintf("<_____Macchinario %s%s<\n",indice_macchinario(i),repmat('_',1,12-length(char(indice_macchinario(i)))));
        IPx(i) = AnalizzaSistema(versione, indice_macchinario(i),Precisione,log,realmax, IPx(i+1).TPU_IN);
    end
    fprintf("<_____Macchinario %s%s<\n",indice_macchinario(1),repmat('_',1,12-length(char(indice_macchinario(1)))));
    IPx(1) = AnalizzaSistema(versione, indice_macchinario(1),Precisione,log,0, IPx(2).TPU_IN);

    for i=1:l_im
        fprintf("%f -> Macchinario %s ->%f\n",IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
    end

    for i=2:l_im-1
        fprintf(">_____Macchinario %s%s>\n",indice_macchinario(i),repmat('_',1,12-length(char(indice_macchinario(i)))));
        IPx(i)= AnalizzaSistema(versione,  indice_macchinario(i),Precisione,log, IPx(i-1).TPU_OUT,IPx(i+1).TPU_IN);
    end
    fprintf(">_____Macchinario %s%s>\n",indice_macchinario(l_im),repmat('_',1,12-length(char(indice_macchinario(l_im)))));
    IPx(l_im)= AnalizzaSistema(versione,  indice_macchinario(l_im),Precisione,log, IPx(l_im-1).TPU_OUT,0);

    for i=1:l_im
        fprintf("%f -> Macchinario %s ->%f\n",IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
    end

elseif(direzione=="><") % >>>>>>>>>>>> -> <<<<<<<<<<<<<____________________
    fprintf(">_____Macchinario %s%s>\n",indice_macchinario(1),repmat('_',1,12-length(char(indice_macchinario(1)))));
    IPx(1) = AnalizzaSistema(versione, indice_macchinario(1),Precisione,log,0, realmax);
    r_out(1)=realmax;
    r_in(1)=0;

    for i=2:l_im-1
        fprintf(">_____Macchinario %s%s>\n",indice_macchinario(i),repmat('_',1,12-length(char(indice_macchinario(i)))));
        IPx(i)= AnalizzaSistema(versione,  indice_macchinario(i),Precisione,log, IPx(i-1).TPU_OUT,realmax);
        r_out(i)=realmax;
        r_in(i)=IPx(i-1).TPU_OUT;
    end

    fprintf(">_____Macchinario %s%s>\n",indice_macchinario(l_im),repmat('_',1,12-length(char(indice_macchinario(l_im)))));
    IPx(l_im)= AnalizzaSistema(versione,  indice_macchinario(l_im),Precisione,log, IPx(l_im-1).TPU_OUT,0);

    for i=1:l_im
        fprintf("%f -> Macchinario %s ->%f\n",IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
    end

    for i=l_im-1:-1:2
        if IPx(i+1).TPU_IN < soglia*IPx(i).TPU_OUT
        fprintf("<_____Macchinario %s%s<\n",indice_macchinario(i),repmat('_',1,12-length(char(indice_macchinario(i)))));
        IPx(i) = AnalizzaSistema(versione, indice_macchinario(i),Precisione,log,IPx(i-1).TPU_OUT, IPx(i+1).TPU_IN);
        r_out2(i)=IPx(i+1).TPU_IN;
        end
    end
    if IPx(2).TPU_IN < soglia*IPx(1).TPU_OUT
    fprintf("<_____Macchinario %s%s<\n",indice_macchinario(1),repmat('_',1,12-length(char(indice_macchinario(1)))));
    IPx(1) = AnalizzaSistema(versione, indice_macchinario(1),Precisione,log,0, IPx(2).TPU_IN);
    r_out2(1)=IPx(2).TPU_IN;
    end
end

%% SALVATAGGIO_____________________________________________________________
if (direzione=="<>")
    direzione1= "prima indietro, poi avanti";
else
    direzione1= "prima avanti, poi indietro";
end
d = dir(sprintf("Parti_v%i_R*",versione));
n = length(d)+1;
mkdir(sprintf("Parti_v%i_R%i",versione,n));

% Stampa del file di supporto per rintracciare l'origine dei dati
fid = fopen(sprintf("Parti_v%i_R%i/ConfigurazioniAnalisi.txt",versione,n),'w');
fprintf(fid,"Versione analizzata: %i\n",versione);
fprintf(fid,"Elementi presenti: %s\n",array2string(indice_macchinario));
fprintf(fid,"Direzione di analisi: %s (%s)\n",direzione,direzione1);
fprintf(fid,"Precisione arrotondamento U: %i\n",Precisione.U);
fprintf(fid,"Precisione arrotondamento U': %i\n",Precisione.U1);
fprintf(fid,"Soglia: %.4f\n",soglia);
fprintf(fid,"Log: %i\n",log);
fclose(fid);

% Stampa dei 
Transizioni_=[];
Posti_=[];
EFF_=[];
WIP_=0;
MLT_=0;
for i=1:l_im
    Transizioni=IPx(i).Transizioni;
    Posti=IPx(i).Posti;
    TPU_IN=IPx(i).TPU_IN;
    TPU_OUT=IPx(i).TPU_OUT;
    WIP=IPx(i).WIP;
    MLT=IPx(i).MLT;
    EFF=IPx(i).EFF;
    Transizioni_=[Transizioni_; Transizioni];
    Posti_=[Posti_; Posti];
    EFF_=[EFF_; EFF];
    WIP_=WIP_ + WIP;
    MLT_=MLT_ + MLT;
    save(sprintf("Parti_v%i_R%i/IP_%s.mat",versione,n,indice_macchinario(i)),"Transizioni","Posti","TPU_IN","TPU_OUT","WIP","MLT","EFF");
end
Transizioni = Transizioni_;
Posti = Posti_;
EFF = EFF_;
WIP = WIP_;
MLT = MLT_;
clear Transizioni_ Posti_  EFF_ WIP_ MLT_;

TPU=IPx(l_im).TPU_OUT;

save(sprintf("Parti_v%i_R%i/RisultatiAnalisiCompleta.mat",versione,n),'EFF','Transizioni','Posti','WIP','TPU','MLT');
save(sprintf("Parti_v%i_R%i/RateImposti.mat",versione,n),'r_in','r_out','r_out2');

%% STAMPA RISULTATI________________________________________________________
for i=1:l_im
%Per stampare i risultati senza separare i macchinari
%nome=sprintf("RisultatiAnalisi_1_ai.mat");

%Per stampare i risultati separati per macchinario
nome=sprintf("Parti_v1/IP_%s.mat",indice_macchinario(i));
PrintResultForLatex(i, nome);
end

%% FUNCTION________________________________________________________________
function StampaRiga(verso,macchinario)
    fprintf("%s_____Macchinario %s%s%s\n",verso,macchinario,repmat('_',1,12-length(char(macchinario))));
end
