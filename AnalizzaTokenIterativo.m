%% ======================== ANALIZZATOKENITERATIVO ========================  
%==============AUTHORS==============%
%   Alessandro Di Biase             %
%   Federico Catalini               %
%   Luca Caponi                     %
%===================================%
% Questo script permette di analizzare le capacità dei buffer migliori per
% reti di petri scomposte in sotto-gruppi. L'analisi risulta automatizzata,
% si deve configurare correttamente l'ambiente predisponendo in una 
% cartella Parti_v<numerointero> i files PN_<indice> e Grafo_<indice>. 
% Le due tipologie di file possono essere facilmente realizzati grazie 
% all'applicativo GestoreAnalisiPN. Prima di lanciare lo script bisogna 
% eseguire AnalisiSistemaComposto, che genera i risultati necessari per la 
% seguente analisi. In questo script specificare solo le impostazioni, 
% sarà generata una cartella con i file PN e Grafo relativi alla migliore
% prestazione.
%% PREPARAZIONE WORKSPACE__________________________________________________
close all;                          
clearvars;                       
clc;
addpath('Functions');

%% IMPOSTAZIONI____________________________________________________________
% La cartella Parti_v<versione> da considerare:
versione=1;

% Il numero di risultato ottenuto da prendere in considerazione per i rate:
nrisultato=1;

% La precisione con la quale arrotonare le matrici U e U'
Impostazioni.Precisione.U  = 5;
Impostazioni.Precisione.U1 = 5;

% Specificare se recuperare i grafi calcolati o analizzarli nuovamente
Impostazioni.RecuperoGrafo="Si";

% La soglia al di sotto della quale confermiamo la presenza di un collo di
% bottiglia, dunque risulta necessario eseguire un ricalcolo all'indietro
soglia=0.985;

% Scegliere il diverso livello di log:
% 0          -> mostrare tutti i messaggi
% 1          -> mostrare solo i messaggi principali
% altrimenti -> mostrare solo i messaggi di errore 
Impostazioni.log=0;

% Il vettore che contiene i diversi file da analizzare, elencati dal primo
% all'ultimo
indice_macchinario=["M1","M2","M3","M4","M5","M6","M7_1","M7_2","M7_3","M8","M9","M10","M11_12_13"];

load(sprintf("Parti_v%i_R%i/RateImposti.mat",versione,nrisultato));
rate_in=r_in;
macchinario_da_analizzare="M2";
codici=["1","2","3","4","5","6","7_1","7_3","8","9","10","11_12_13"];
codice_macchinario=find(indice_macchinario==macchinario_da_analizzare);
PN=load(sprintf('Parti_v%i/PN_%s.mat',versione, indice_macchinario(codice_macchinario)));

token.init=2;
token.ending=30;
token.delta=1;

%% CALCOLO ITERATIVO_______________________________________________________
Analisi_indietro=false;
rate_out=r_out;
if ~isempty(r_out2) && length(r_out2)>=codice_macchinario && r_out2(codice_macchinario)>0 
    rate_out=r_out2;
    Analisi_indietro=true;
end

plot_tp=Calcolo_Iterativo_PN_Grafo(versione,PN,indice_macchinario(codice_macchinario),codice_macchinario,token,rate_in(codice_macchinario),rate_out(codice_macchinario),Impostazioni);

if Analisi_indietro
    cerca=find(plot_tp(:,2)/rate_out(codice_macchinario)>=soglia,1,'first');
else
    cerca=find(plot_tp(:,1)/rate_in(codice_macchinario)>=soglia,1,'first');
end

trova_token=0;
Nome_indice=sprintf("IndiciPrestazione_M%s_%i.mat",codici(codice_macchinario),cerca);

%% PLOT
figure
plot(token.init:token.delta:token.ending, plot_tp(:,1), token.init:token.delta:token.ending, plot_tp(:,2));
legend("Throughput input","Throughput output");
grid minor;
figure
if ~isempty(cerca)
    trova_token=(cerca-1)*token.delta+token.init;
    a=[trova_token, token.ending];
    b=[soglia*100,soglia*100];
    area(a,b,100,'FaceColor','green','FaceAlpha',0.3,'LineStyle','none','HandleVisibility','off')
    hold on
    xline(trova_token,'-.')
    plot(trova_token, plot_tp(cerca,2)/rate_out(codice_macchinario)*100,'*','Color','b','HandleVisibility','off')
end
plot(token.init:token.delta:token.ending, plot_tp(:,1)/rate_in(codice_macchinario)*100, token.init:token.delta:token.ending, plot_tp(:,2)/rate_out(codice_macchinario)*100,'Color','r')
yline(soglia*100,'-.')


%% GESTISCO I MIGLIORI RISULTATI, SALVANDOLI SU UNA CARTELLA PARTI_v9
%Definisco una nuova variabile NuovaVersione, inizializzata a 9
nuova_versione=11;
%Con questo comando, se non esistente, mi creo la cartella Parti_v9
[~,~,~]=mkdir(sprintf('Parti_v%i',nuova_versione));
%Se esiste il valore trova_token allora
%Carico la migliore versione dei grafi e delle PN all'interno della nuova
%cartella, altrimenti restituisco un messaggio di warning
if trova_token==0
    fprintf('Attenzione, non è stata trovata la migliore configurazione di token per la capacità del nastro')
else
PN_migliore=load(sprintf("Parti_v%1$i_M%2$s/PN_M%2$s_%3$i", versione, codici(codice_macchinario), trova_token) );
Grafo_migliore=load(sprintf("Parti_v%1$i_M%2$s/Grafo_M%2$s_%3$i", versione, codici(codice_macchinario), trova_token));
Indice_migliore=load(sprintf("Parti_v%1$i_M%2$s/IndiciPrestazione_M%2$s_%3$i", versione, codici(codice_macchinario), trova_token));

save(sprintf("Parti_v%i/PN_M%s",nuova_versione, codici(codice_macchinario)),"PN_migliore");
save(sprintf("Parti_v%i/Grafo_M%s",nuova_versione, codici(codice_macchinario)),"Grafo_migliore");
save(sprintf("Parti_v%i/IndiciPrestazione_M%s",nuova_versione, codici(codice_macchinario)),"Indice_migliore");
fprintf("Risultati del macchinario M%s salvati in Parti_v%i \n", codici(codice_macchinario),nuova_versione);
if Analisi_indietro
   fprintf("I risultati caricati sono stati ottenuti attraverso un'analisi all'indietro");
else
   fprintf("I risultati caricati sono stati ottenuti SENZA un'analisi all'indietro"); 
end
end



