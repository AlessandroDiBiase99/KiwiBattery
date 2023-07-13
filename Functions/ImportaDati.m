function PN = ImportaDati(file,foglio)
% ImportaDati è una funzione che estrapola dal foglio 'sheet' del 'file'
% excel indicato le matrici che descrivono la reti di petri. Il file deve
% essere conforme allo standard rispettato dalla generazione automatica di
% PIPE 4.3: tabelle contigue, nomi delle tabelle di default, riordinamento
% generato di default. Qualora l'ordine dei posti o delle transizioni sia 
% stato modificato e non rispetta l'ordinamento standard viene generato un 
% messaggio sulla command window che avvisa l'utente riguardo la
% problematica.
%
% INPUT:
%    - file: 
%      il path del file excel da cui estrapolare le matrici.
%    - foglio:
%      il nome del foglio di lavoro sul quale sono presenti le matrici 
%      desiderate.
% OUTPUT:
%    - PN: 
%      struct contenente i vettori T e P, che contengono i nomi delle
%      transizioni e dei posti nell'ordine indicato dalle matrici; le
%      matrici Pre, Post, C (combinazione) e H (inibizione); il vettore M0
%      che indica la marcatura iniziale.
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Leggo la prima colonna del foglio excel indicato
T=readtable(file,'sheet',foglio,'DataRange','A:A');

% Individuo le rige che separano le diverse matrici
riga1 = find(string(T.PetriNetIncidenceAndMarking)=='Forwards incidence matrix I+');
riga2 = find(string(T.PetriNetIncidenceAndMarking)=='Backwards incidence matrix I-');
riga3 = find(string(T.PetriNetIncidenceAndMarking)=='Combined incidence matrix I');
riga4 = find(string(T.PetriNetIncidenceAndMarking)=='Inhibition matrix H');
riga5 = find(string(T.PetriNetIncidenceAndMarking)=='Marking');
riga6 = find(string(T.PetriNetIncidenceAndMarking)=='Enabled transitions');

% Importo le tabelle delle singole matrici
Post        = readtable(file,'sheet',foglio,'DataRange',[num2str(riga1+1),':',num2str(riga2-1)]);
Post        = SistemaTabella(Post);
PN.Post     = table2array(Post(:,2:end));

Pre         = readtable(file,'sheet',foglio,'DataRange',[num2str(riga2+1),':',num2str(riga3-1)]);
Pre         = SistemaTabella(Pre);
PN.Pre      = table2array(Pre(:,2:end));

Combinazione= readtable(file,'sheet',foglio,'DataRange',[num2str(riga3+1),':',num2str(riga4-1)]);
Combinazione= SistemaTabella(Combinazione);
PN.C        = table2array(Combinazione(:,2:end));

Inibizione  = readtable(file,'sheet',foglio,'DataRange',[num2str(riga4+1),':',num2str(riga5-1)]);
Inibizione  = SistemaTabella(Inibizione);
PN.H        = table2array(Inibizione(:,2:end));

M0          = readtable(file,'sheet',foglio,'DataRange',[num2str(riga5+1),':',num2str(riga6-1)]);
M0          = SistemaTabella(M0);
PN.M0       = table2array(M0(1,2:end))';

% Elimino i messaggi di warning:
clc;

% Salvo l'ordine dei posti e delle transizioni
PN.T = string(Post(1,2:end).Properties.VariableNames)';
PN.P = string(Post.Var1);

% Verifico che l'ordine dei posti e delle transizioni sia lo stesso per
% tutte le matrici
TPost         = string(Post.Properties.VariableNames);
TPre          = string(Pre.Properties.VariableNames);
TCombinazione = string(Combinazione.Properties.VariableNames);
TInibizione   = string(Inibizione.Properties.VariableNames);
if ~all(TPost==TPre & TPost==TCombinazione & TPost==TInibizione)
    fprintf('|===== Attenzione! ==========================|\n| Le transizioni non hanno lo stesso ordine! |\n|____________________________________________|\n');
end
PPost         = standardizza(string(Post.Var1));
PPre          = standardizza(string(Pre.Var1));
PCombinazione = standardizza(string(Combinazione.Var1));
PInibizione   = standardizza(string(Inibizione.Var1));
PM0           = standardizza(string(M0(:,2:end).Properties.VariableNames))';
if ~all(PPost==PPre & PPost==PCombinazione & PPost==PInibizione & PPost==PM0)
    fprintf('|===== Attenzione! ==========================|\n| I posti non hanno lo stesso ordine!        |\n|____________________________________________|\n');
end
end

%% FUNZIONI________________________________________________________________
function tabella1 = SistemaTabella(tabella)
tabella1 = tabella(2:end,:);
tabella1=rmmissing(tabella1,2);
end

function stringa1 = standardizza(stringa)
stringa1 = upper(stringa);
stringa1 = strrep(stringa1," ","");
stringa1 = strrep(stringa1,"À","_");
end