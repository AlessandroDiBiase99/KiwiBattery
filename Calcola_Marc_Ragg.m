function [list,Ragg] = Calcola_Marc_Ragg(M_ini,list,Ragg,C,maschera_trans,Pre,H)
% Calcola_Marc_Ragg è una funzione che calcola tutte le marcature
% raggiungibile dalla marcatura iniziale indicata. La funzione calcola
% inizialemte le transizioni abilitate, e le conseguenti marcature. Qualora
% siano calcolate nuove marcature queste vengono analizzate richiamando
% ciclicamente la funzione.
%
% Input:
%    - M_ini: marcatura attuale
%    - list: lista di stati già raggiunti
%    - Ragg: lista di dati degli stati già raggiunti
%    - C: matrice di combinazione (Post-Pre)
%    - maschera_trans: maschera per distinguere le transizioni immediate e
%      temporizzate
%    - Pre: matrice Pre
%    - H: matrice degli archi inibitori
% Output:
%    - list: lista di stati raggiunti
%    - Ragg: dati relativi agli stati raggiunti
%
% Authors:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Calcola la struttura della matrice
risultato = Crea_Struttura(M_ini,C,maschera_trans,Pre,H);

% Ricava gli stati uscenti dallo stato
for i=1:size(risultato.M_fin,2)
    if size(list,1)==0 || ~any(ismember(list',risultato.M_fin(:,i)',"rows"))
        % Se la marcatura non è nella lista delle marcature raggiungibili,
        % la aggiunge alla lista e espande la ricerca sulla marcatura.
        list = [list risultato.M_fin(:,i)];
        Ragg = [Ragg;risultato];
        [list,Ragg] = Calcola_Marc_Ragg(risultato.M_fin(:,i),list,Ragg,C,maschera_trans,Pre,H);
    end
end
end
