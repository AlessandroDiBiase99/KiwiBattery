function p_tp= Calcolo_Iterativo_PN_Grafo(versione,PN,nome,codice,token, RATE_IN, RATE_OUT, Impostazioni)
% Calcolo_Iterativo_PN_Grafo è una funzione per calcolare il grafo di
% raggiungibilità e consecutivamente gli indici di prestazione variando il
% numero di token sul buffer.
%
% INPUT:
%    - versione: 
%      la versione da analizzare
%    - PN:
%      la struttura dati contenente tutte le informazioni della rete di
%      Petri.
%    - nome: 
%      il nome del gruppo
%    - codice:
%      il codice del buffer da modificare
%    - token:
%      struttura che descrive il token iniziale, quello finale, e
%      l'incremento ad ogni di token ad ogni iterazioni.
%    - RATE_IN:
%      il rate da imporre alla transizione di ingresso.
%    - RATE_OUT:
%      il rate da imporre alla transizione di uscita.
%    - Impostazioni:
%      impostazioni contenenti le precisioni per l'arrotondamento della
%      matrice U e U1, il livello di log, la possibilità di recuperare il
%      grafo se già calcolato.
% OUTPUT:
%    - p_tp:
%      array con i valori di throughput della transizione di ingresso e di
%      uscita
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

Precisione=Impostazioni.Precisione;
log=Impostazioni.log;
RecuperoGrafo=Impostazioni.RecuperoGrafo;

indice_macchinario=[];

if log <=1
    fprintf("\nA) Calcolo iterativo delle PN e Grafo con capacità del nastro N%i_2 da %i a %i (delta=%i).\n",codice-1,token.init,token.ending,token.delta);
end

for token_attuale=token.init:token.delta:token.ending
    % Elaborazione e salvataggio PN
    PN.PN.Ridotta.M0(PN.PN.Ridotta.P==sprintf("N%i_2_Capacità",codice-1))=token_attuale;
    %PN.PN.Ridotta.M0(PN.PN.Ridotta.P==sprintf("N%i_1_Capacità",codice))=4;
    [~,~,~]=mkdir(sprintf('Parti_v%i_%s',versione, nome));
    PN_salvato=sprintf('Parti_v%1$i_%2$s/PN_%2$s_%3$i.mat',versione, nome, token_attuale);
    save(PN_salvato, 'PN')

    % Elaborazione e salvataggio Grafo
    if RecuperoGrafo=="No" || ~exist(sprintf("Parti_v%1$i_%2$s/Grafo_%2$s_%3$i.mat",versione,nome,token_attuale),'file')
        list=PN.PN.Ridotta.M0;
        list_todo=PN.PN.Ridotta.M0;

        while size(list_todo,2)>0
            % Se presente, prendo la prima colonna della lista di marcatura da
            % studiare
            M_ini=list_todo(:,1);
            % Inizializzo il vettore delle transizioni abilitate in M_ini
            T_abilitate = zeros(1,size(PN.PN.Ridotta.Pre,2));

            % Verifico quali sono le transizioni abilitate, ovvero che hanno
            % sufficienti token in ingresso e nessun arco inibitore attivo
            for i=1:size(PN.PN.Ridotta.Pre,2)
                if all((M_ini-PN.PN.Ridotta.Pre(:,i))>=0) && ~any(M_ini>=PN.PN.Ridotta.H(:,i) & PN.PN.Ridotta.H(:,i)>0)
                    T_abilitate(i)=1;
                end
            end

            % Verifico il numero di transizioni immediate abilitate
            T_imm_abilitate = T_abilitate(PN.PN.Ridotta.T.Maschera==1);
            if sum(T_imm_abilitate)>0
                T_abilitate(PN.PN.Ridotta.T.Maschera==0)=0;
            end

            % Inizializzo indice
            k=1;

            Marcatura.Iniziale=M_ini;
            Marcatura.Raggiungibili=table();

            % Per ogni transizione abilitata calcolo le marcature a seguito dello
            % scatto della transizione stessa.
            for i=1:size(PN.PN.Ridotta.Pre,2)
                if T_abilitate(i)==1
                    M_fin = M_ini+PN.PN.Ridotta.C(:,i);
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

            if size(list_todo,2)>=2
                list_todo=list_todo(:,2:end);
            else
                list_todo=[];
            end

        end
        %PN.Grafo=Grafo;
        Grafo_salvato=sprintf('Parti_v%1$i_%2$s/Grafo_%2$s_%3$i.mat',versione, nome, token_attuale);
        save(Grafo_salvato, 'Grafo')

        if log==0
            fprintf("   -> Lo script ha salvato il Grafo di %s_%i.\n", nome,token_attuale);
        end
    else
        if log==0
            fprintf("   -> Grafo di %s_%i già presente, non è stato ricalcolato.\n",nome,token_attuale);
        end
    end
    indice_macchinario=[indice_macchinario; string(sprintf('%s_%i',nome, token_attuale))];
end

%% CALCOLO INDICI DI PRESTAZIONE
if log <=1
    fprintf("\nB) Calcolo degli indici di prestazione");
end

l_im=length(indice_macchinario);

for i=1:l_im
    IPx(i)= AnalizzaTokenSingoloMacchinario(versione, nome, token.init+token.delta*(i-1), Precisione,log, RATE_IN,RATE_OUT);
    if log==0
        fprintf("Macchinario %s->\n",indice_macchinario(i));
    end
    p_tp(i,:)=[IPx(i).TPU_IN , IPx(i).TPU_OUT];
end

if log==0
    for i=1:l_im
        fprintf("%f -> Macchinario %s ->%f\n "      ,IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
    end
end

end
