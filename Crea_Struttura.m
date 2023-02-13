function risultato = Crea_Struttura(M_ini,C,maschera_trans,Pre,H)
% Crea_Struttura è una funzione che calcola le marcature raggiunte da una
% marcatura iniziale indicata.
%
% Input:
%    - M_ini: il vettore della marcatura iniziale del passo
%    - C: la matrice di combinazione pari a Post-Pre
% Output:
%    - risultato: struct contenente la marcatura iniziale, le transizioni
%                 abilitate e le marcature raggiunte.
% Authors:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% numero dei posti e delle transizioni
[~,nt]=size(Pre);

% Inizializzo il vettore delle transizioni abilitate in M_ini
T_abilitate = zeros(1,nt);

% Verifico quali sono le transizioni abilitate, ovvero che hanno
% sufficienti token in ingresso e nessun arco inibitore attivo
for i=1:nt
    if all((M_ini-Pre(:,i))>=0) && ~any(M_ini>=H(:,i) & H(:,i)>0)
        T_abilitate(i)=1;
    end
end

% Verifico il numero di transizioni abilitate presenti
T_imm_abilitate = T_abilitate(maschera_trans==1);
if sum(T_imm_abilitate)>0
    T_abilitate(maschera_trans==0)=0;
end

% Inizializzo i risultati
M_fin=[];
T_fin=[];
k=1;

% Per ogni transizione abilitata calcolo le marcature a seguito dello
% scatto della transizione stessa.
for i=1:nt
    if T_abilitate(i)==1
        M_fin(:,k)=M_ini+C(:,i);
        T_fin(k)=i;
        k=k+1;
    end
end

% Imposto il risultato da consegnare in output
risultato.M_ini = M_ini;
risultato.T_abilitate = T_abilitate;
risultato.M_fin = M_fin;
risultato.T_fin = T_fin;
end

