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
versione    = 1;

% Il numero di risultato ottenuto da prendere in considerazione per i rate:
idRisultato = 2;

% Il codice del gruppo da analizzare:
gruppo_da_analizzare = "M2";

% Scegliere il token iniziale da considerare (init), il token da 
% raggiungere (ending), e la variazione di token ad ogni passo (delta): 
token.init   =  2;
token.ending = 32;
token.delta  = 30;

% La precisione con la quale arrotonare le matrici U e U'
Impostazioni.Precisione.U  = 5;
Impostazioni.Precisione.U1 = 5;

% Specificare se recuperare i grafi calcolati, salvati in
% Parti_v<versione>_M<gruppo_da_analizzare>, o calcolarli nuovamente
Impostazioni.RecuperoGrafo = "Si";

% La soglia al di sotto della quale confermiamo la presenza di un collo di
% bottiglia, dunque risulta necessario eseguire un ricalcolo all'indietro
soglia = 0.985;

% Scegliere il diverso livello di log:
% 0          -> mostrare tutti i messaggi
% 1          -> mostrare solo i messaggi principali
% altrimenti -> mostrare solo i messaggi di errore 
Impostazioni.log = 1;

% Scegliere la cartella di destinazione:
% >  0       -> usare la cartella indicata per salvare i nuovi file
%               (sovrascrive se già presenti)
% <= 0       -> creare una nuova cartella in modo automatico
nuova_versione = -1;

% Scegliere la cartella di destinazione dei risultati:
% >  0       -> usare la cartella indicata per salvare i nuovi risultati
%               (sovrascrive se già presenti)
% <= 0       -> creare una nuova cartella in modo automatico
id_nuovi_risultati = -1;

%% CARICAMENTO DATI________________________________________________________

% Controllo dell'esistenza del risultato
if isempty(dir(sprintf("Parti_v%i_R%i",versione,idRisultato)))
    fprintf("__-!-!-ERRORE-!-!-%s\n| Non esiste alcuna verisione con indice %i che presenta il risultato con indice %i.\n|%s\n",repmat('_',66,1),versione,idRisultato,repmat('_',83,1));
    return;
elseif length(dir(sprintf("Parti_v%i_R%i",2,1)))> 1
    fprintf("__-!-!-ERRORE-!-!-%s\n| Esistono più verisioni con indice %i ed indice di risultato %i.\n|%s\n",repmat('_',66,1),versione,idRisultato,repmat('_',83,1));
    return;
end

% Carico i rate imposti alle transizioni di giunzione
load(sprintf("Parti_v%i_R%i/RateImposti.mat",versione,idRisultato));
rate_in=r_in;

% Carico le configurazioni dell'analisi per estrapolare gli indici dei
% macchinari
fid = fopen(sprintf("Parti_v%i_R%i/ConfigurazioniAnalisi.txt",versione,idRisultato),'r');
A=textscan(fid,'%s','delimiter',sprintf('\f'));
B=A{:};
C=B{2};
D=split(C,","|"["|"]");
id_gruppi=strtrim(string(D(2:end-1)));
clear A C D;

if ~ismember(gruppo_da_analizzare,id_gruppi)
    fprintf("__-!-!-ERRORE-!-!-%s\n| L'indice del gruppo ricercato non è corretto. Gli indici dei gruppi presenti sono: %s.\n|%s\n",repmat('_',66,1),array2string(id_gruppi),repmat('_',83,1));
    return;
end

id_gruppo_analizzare=find(id_gruppi==gruppo_da_analizzare);
PN=load(sprintf('Parti_v%i/PN_%s.mat',versione, id_gruppi(id_gruppo_analizzare)));

% Stampo un messaggio per l'utente
fprintf("__CONFIGURAZIONI USATE%s\n",repmat('_',34,1));
for riga=1:size(B,1)
    fprintf("| "+B{riga}+"\n");
end
fprintf("|%s\n",repmat('_',55,1));
fprintf("| GRUPPO SOTTO STUDIO: %s\n",id_gruppi(id_gruppo_analizzare));
fprintf("|%s\n",repmat('_',55,1));

%% CALCOLO ITERATIVO_______________________________________________________
Analisi_indietro=false;
rate_out=r_out;
if ~isempty(r_out2) && length(r_out2)>=id_gruppo_analizzare && r_out2(id_gruppo_analizzare)>0 
    rate_out=r_out2;
    Analisi_indietro=true;
end

plot_tp = Calcolo_Iterativo_PN_Grafo(versione,PN,id_gruppi(id_gruppo_analizzare),id_gruppo_analizzare,token,rate_in(id_gruppo_analizzare),rate_out(id_gruppo_analizzare),Impostazioni);

if Analisi_indietro
    cerca=find(plot_tp(:,2)/rate_out(id_gruppo_analizzare)>=soglia,1,'first');
else
    cerca=find(plot_tp(:,1)/rate_in(id_gruppo_analizzare)>=soglia,1,'first');
end

trova_token=0;
Nome_indice=sprintf("IndiciPrestazione_%s_%i.mat",id_gruppi(id_gruppo_analizzare),cerca);

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
    plot(trova_token, plot_tp(cerca,2)/rate_out(id_gruppo_analizzare)*100,'*','Color','b','HandleVisibility','off')
end
plot(token.init:token.delta:token.ending, plot_tp(:,1)/rate_in(id_gruppo_analizzare)*100, token.init:token.delta:token.ending, plot_tp(:,2)/rate_out(id_gruppo_analizzare)*100,'Color','r')
yline(soglia*100,'-.')

%% GESTISCO I MIGLIORI RISULTATI, SALVANDOLI SU UNA CARTELLA PARTI_v9
% Se ho trovato il token ottimo allora creo una cartella e inserisco i file
% PN e GRAFO
if trova_token==0
    fprintf('Attenzione, non è stata trovata la migliore configurazione di token per la capacità del nastro')
else
    % Se deve essere creata la cartella, cerco il prossimo numero per 
    % identificare la nuova versione. 
    if nuova_versione<=0
        d = dir("Parti_v*");
        numeri_usati = zeros(length(d),1);
        for i=1:length(d)
            temp1 = split(d(i).name,'_');
            temp2 = temp1{2};
            numeri_usati(i) = str2double(temp2(2:end));
        end
        nuova_versione=max(numeri_usati)+1;

        d = dir(sprintf("Parti_v%i_R*",nuova_versione));
        id_nuovi_risultati=length(d)+1;
        if id_nuovi_risultati<=0
            id_nuovi_risultati=1;
        end
    end
    if id_nuovi_risultati<=0
        d = dir(sprintf("Parti_v%i_R*",nuova_versione));
        id_nuovi_risultati=length(d)+1;
        if id_nuovi_risultati<=0
            id_nuovi_risultati=1;
        end
    end
    
    % Creo la cartella Parti_v<> per la nuova versione
    [~,~,~]=mkdir(sprintf('Parti_v%i',nuova_versione));
    [~,~,~]=mkdir(sprintf('Parti_v%i_R%i',nuova_versione,id_nuovi_risultati));

    PN_migliore=load(sprintf("Parti_v%1$i_%2$s/PN_%2$s_%3$i", versione, id_gruppi(id_gruppo_analizzare), trova_token) );
    Grafo_migliore=load(sprintf("Parti_v%1$i_%2$s/Grafo_%2$s_%3$i", versione, id_gruppi(id_gruppo_analizzare), trova_token));
    Indice_migliore=load(sprintf("Parti_v%1$i_%2$s/IndiciPrestazione_%2$s_%3$i", versione, id_gruppi(id_gruppo_analizzare), trova_token));

    save(sprintf("Parti_v%i/PN_%s",nuova_versione, id_gruppi(id_gruppo_analizzare)),"PN_migliore");
    save(sprintf("Parti_v%i/Grafo_%s",nuova_versione, id_gruppi(id_gruppo_analizzare)),"Grafo_migliore");
    save(sprintf("Parti_v%i_R%i/IP_%s",nuova_versione, id_nuovi_risultati, id_gruppi(id_gruppo_analizzare)),"Indice_migliore");
    
    fprintf("Risultati del macchinario %s salvati in Parti_v%i\n", id_gruppi(id_gruppo_analizzare),nuova_versione);

    righe=[];
    if ~isempty(dir(sprintf("Parti_v%i/ConfigurazioneCartellaGenerata.txt",nuova_versione)))
        fid = fopen(sprintf("Parti_v%i/ConfigurazioneCartellaGenerata.txt",nuova_versione),'r');
        A=textscan(fid,'%s','delimiter',sprintf('\f'));
        fclose(fid);
        righe=A{:};
    end
    fid = fopen(sprintf("Parti_v%i/ConfigurazioneCartellaGenerata.txt",nuova_versione),'w');
    fprintf(fid,"Cartella modificata dallo script AnalizzaTokenIterativo.m. I file ritoccati sono:\n");
    for i=2:length(righe)
        fprintf(fid,righe(i)+"\n");
    end
    fprintf(fid,id_gruppi(id_gruppo_analizzare)+"\n");
    fclose(fid);
end



