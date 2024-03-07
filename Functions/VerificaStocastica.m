function M = VerificaStocastica(M,Precisione)
% VerificaStocastica è una funzione che verifica che la matrice passata
% come parametro risulti effettivamente stocastica. Si controlla dunque che
% tutte le righe abbiano sommatoria pari a 1, in caso negativo si provvede
% a sistemare i valori della matrice al fine di rendere la sommatoria pari
% a 1. Gli arrotondamenti sono effettuati in base alla Precisione passata
% come parametro.
%
% INPUT:
%    - M:
%      la matrice che deve essere verificata.
%    - Precisione:
%      il numero di cifre significative da considerare con i calcoli.
% OUTPUT:
%    - M:
%      la matrice corretta.
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Arrotondo all precisione specificata
M = round(M,Precisione);

% Creo la struttura dati per avere una stampa più pulita
Ricalcolo_M = table(-1,{-1},'VariableNames',["SUM" "Riga"]);
Errore_M     = [];
RicalcolaNaN = [];

% Per ogni riga verifico che la sommatoria corrisponda a 1. Se così non
% fosse si somma la differenza alla prima cella non nulla e si inserisce il
% numero di riga nella tabella, associato al valore ottenuto. Bisogna fare
% un riconoscimento dei NaN perche per MATLAB NaN ~= NaN
for i=1:size(M,1)
    sum_= sum(M(i,:));
    if sum_~=1
        primo_non_vuoto=find(M(i,:)~=0,1);%& M(i,:)>sum(M(i,:))-1,1);
        M(i,primo_non_vuoto)=0;
        M(i,primo_non_vuoto)=1-sum(M(i,:));
        id=find(sum_==Ricalcolo_M.SUM);
        if isnan(sum_)
            RicalcolaNaN=[RicalcolaNaN   i];
        elseif isempty(id)
            Ricalcolo_M(end+1,:)=table(sum_,{i});
        else
            Ricalcolo_M.Riga(id)={[Ricalcolo_M.Riga{id} i]};
        end
    end
    % Se l'errore persiste si segnala
    if sum(M(i,:))~=1
        Errore_M=[Errore_M i];
    end
end
% Stampo i messaggi all'utente per avvisarlo delle incorrettezze risolte, o
% degli errori che persistono
if height(Ricalcolo_M)>1
    fprintf("   ____!=== ATTENZIONE ===!_____________\n   | Eseguite le correzioni automatiche dell'arrotondamento:\n");
    Ricalcolo_M=Ricalcolo_M(2:end,:);
    if ~isempty(RicalcolaNaN)
         fprintf("   | Sommatoria ottenuta: NaN sulle righe: %s\n",array2string(RicalcolaNaN));
    end
    for i=1:height(Ricalcolo_M)
        fprintf("   | Sommatoria ottenuta: %1$.*2$f sulle righe: %3$s\n",Ricalcolo_M.SUM(i),Precisione,array2string(Ricalcolo_M.Riga{i}));
    end
    fprintf("   |____________________________________\n\n");
end
if ~isempty(Errore_M)
    fprintf("   ____!===   ERRORE   ===!_____________\n   | La precisione specificata è troppo elevata. Si suggerisce di abbassarla. Righe:%s\n   |____________________________________\n\n",array2string(Errore_M));
end
end

