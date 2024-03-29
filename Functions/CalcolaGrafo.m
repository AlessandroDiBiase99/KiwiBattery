function [list,Grafo] = CalcolaGrafo(list_todo,list,Grafo,C,maschera_trans,Pre,H)
% CalcolaGrafo è una funzione che calcola tutte le marcature
% raggiungibili dalla marcatura iniziale indicata. La funzione calcola
% inizialemte le transizioni abilitate, e le conseguenti marcature. Qualora
% siano calcolate nuove marcature queste vengono analizzate richiamando
% ciclicamente la funzione.
%
% INPUT:
%    - M_ini:
%      marcatura attuale
%    - list:
%      lista di stati già raggiunti
%    - Ragg:
%      lista di dati degli stati già raggiunti
%    - C:
%      matrice di combinazione (Post-Pre)
%    - maschera_trans:
%      maschera per distinguere le transizioni immediate e temporizzate
%    - Pre: 
%      matrice Pre
%    - H: 
%      matrice degli archi inibitori
% OUTPUT:
%    - list:
%      lista di stati raggiunti
%    - Ragg:
%      dati relativi agli stati raggiunti
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

if size(list_todo,2)>0
    % Se presente, prendo la prima colonna della lista di marcatura da
    % studiare
    M_ini=list_todo(:,1);
    % Inizializzo il vettore delle transizioni abilitate in M_ini
    T_abilitate = zeros(1,size(Pre,2));

    % Verifico quali sono le transizioni abilitate, ovvero che hanno
    % sufficienti token in ingresso e nessun arco inibitore attivo
    for i=1:size(Pre,2)
        if all((M_ini-Pre(:,i))>=0) && ~any(M_ini>=H(:,i) & H(:,i)>0)
            T_abilitate(i)=1;
        end
    end

    % Verifico il numero di transizioni immediate abilitate
    T_imm_abilitate = T_abilitate(maschera_trans==1);
    if sum(T_imm_abilitate)>0
        T_abilitate(maschera_trans==0)=0;
    end

    % Inizializzo indice
    k=1;

    Marcatura.Iniziale=M_ini;
    Marcatura.Raggiungibili=table();

    % Per ogni transizione abilitata calcolo le marcature a seguito dello
    % scatto della transizione stessa.
    for i=1:size(Pre,2)
        if T_abilitate(i)==1
            M_fin = M_ini+C(:,i);
            if size(list,1)==0 || ~any(ismember(list',M_fin',"rows"))
                list = [list M_fin];
                list_todo = [list_todo M_fin];
            end
            idMarcatura=find(ismember(list',M_fin',"rows"));
            Marcatura.Raggiungibili(k,:)=table(i,idMarcatura);
            k=k+1;
        end
    end
    if height(Marcatura.Raggiungibili)>0
        Marcatura.Raggiungibili.Properties.VariableNames=[{'Transizione'} {'Marcatura'}];
    end
    Grafo(ismember(list',M_ini',"rows"))=Marcatura;

    % Tolgo la marcatura dalla lista di quelle che sono ancora da esplorare
    if size(list_todo,2)>=2
        list_todo=list_todo(:,2:end);
    else
        list_todo=[];
    end

    % Chiamo iterativamente CalcolaGrafo per studiare le nuove marcature
    [list,Grafo] = CalcolaGrafo(list_todo,list,Grafo,C,maschera_trans,Pre,H);
end

end