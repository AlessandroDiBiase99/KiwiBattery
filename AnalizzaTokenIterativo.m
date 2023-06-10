%% PREPARAZIONE WORKSPACE__________________________________________________
clear all;
clc;
addpath("Functions\")

%% IMPOSTAZIONI____________________________________________________________
versione=10;
load("RateImposti_1_ai.mat");
rate_in=r_in;
macchinario_da_analizzare="2";
codici=["1","2","3","4","5","6","7_1","7_3","8","9","10","11_12_13"];
codice_macchinario=find(codici==macchinario_da_analizzare);
PN=load(sprintf('Parti_v%i/PN_M%s.mat',versione, codici(codice_macchinario)));

token.init=2;
token.ending=30;
token.delta=1;

Impostazioni.Precisione.U  = 5;
Impostazioni.Precisione.U1 = 5;
Impostazioni.log=1;
Impostazioni.RecuperoGrafo="Si";
soglia=0.98;
Analisi_indietro=false;
rate_out=r_out;
if ~isempty(r_out2) && length(r_out2)>=codice_macchinario && r_out2(codice_macchinario)>0 
rate_out=r_out2;
Analisi_indietro=true;
end


%rate_in=[255.5333, 268.3663, 134.4334, 267.9495, 267.9409, 200.9588, 200.9595, 3.1400, 100.4797, 100.4803, 200.9624, 100.4799];
%rate_out=[253.5367, 134.1820, 268.8662, 267.9480, 200.9588, 200.9595, 3.1400, 100.4797, 100.4806, 200.9627, 100.4811, 90.4316];



%% CALCOLO ITERATIVO_______________________________________________________
plot_tp=Calcolo_Iterativo_PN_Grafo(versione,PN,codici(codice_macchinario),codice_macchinario,token,rate_in(codice_macchinario),rate_out(codice_macchinario),Impostazioni);
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



