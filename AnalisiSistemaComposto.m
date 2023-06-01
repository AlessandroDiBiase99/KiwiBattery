%% PREPARAZIONE WORKSPACE
close all;
clearvars;
clear global;
clc;
addpath('Functions')

Precisione.U  = 5;
Precisione.U1 = 5;        
soglia=0.96;
log=2;
versione=1;
direzione="><";
indice_macchinario=["M1","M2"];%,"M3","M4","M5","M6","M7_1","M7_3","M8","M9","M10","M11_12_13"];
l_im=length(indice_macchinario);

%% CALCOLO INDICI DI PRESTAZIONE
if(direzione=="<>")
    % <<<<<<<<<<<<< -> >>>>>>>>>>>>
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
elseif(direzione=="><")
    %  >>>>>>>>>>>> -> <<<<<<<<<<<<<
    fprintf(">_____Macchinario %s%s>\n",indice_macchinario(1),repmat('_',1,12-length(char(indice_macchinario(1)))));
    IPx(1) = AnalizzaSistema(versione, indice_macchinario(1),Precisione,log,0, realmax);
    for i=2:l_im-1
        fprintf(">_____Macchinario %s%s>\n",indice_macchinario(i),repmat('_',1,12-length(char(indice_macchinario(i)))));
        IPx(i)= AnalizzaSistema(versione,  indice_macchinario(i),Precisione,log, IPx(i-1).TPU_OUT,realmax);
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
        end
    end
    fprintf("<_____Macchinario %s%s<\n",indice_macchinario(1),repmat('_',1,12-length(char(indice_macchinario(1)))));
    IPx(1) = AnalizzaSistema(versione, indice_macchinario(1),Precisione,log,0, IPx(2).TPU_IN);
end
clear Precisione

%% RISULTATI
Transizioni=[];
Posti=[];
EFF=[];
WIP=0;
MLT=0;
TPU=IPx(l_im).TPU_OUT;

for i=1:l_im
    Transizioni=[Transizioni; IPx(i).Transizioni];
    Posti=[Posti; IPx(i).Posti];
    EFF=[EFF;IPx(i).Macchinari];
    WIP=WIP+IPx(i).WIP;
    MLT=MLT+IPx(i).MLT;
end

%% SALVATAGGIO
if (direzione=="<>")
    direzione1="ia";
else
    direzione1="ai";
end
%% STAMPA RISULTATI
for i=1:l_im
nome=sprintf("Parti_v1/IndiciPrestazione_M%i.mat",i);
PrintResultForLatex(i, nome);
end
%% FUNCTION
function StampaRiga(verso,macchinario)
    fprintf("%s_____Macchinario %s%s%s\n",verso,macchinario,repmat('_',1,12-length(char(macchinario))));
end
