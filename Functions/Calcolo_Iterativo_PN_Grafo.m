function p_tp= Calcolo_Iterativo_PN_Grafo(versione,PN,codice,token, RATE_IN, RATE_OUT, Precisione, log)

indice_macchinario=[];

for token_attuale=token.init:token.delta:token.ending
    % Elaborazione e salvataggio PN
    PN.PN.Ridotta.M0(PN.PN.Ridotta.P==sprintf("N%i_2_Capacità",codice-1))=token_attuale;
    [~,~,~]=mkdir(sprintf('Parti_v%i_M%i',versione, codice));
    PN_salvato=sprintf('Parti_v%1$i_M%2$i/PN_M%2$i_%3$i.mat',versione, codice, token_attuale);
    save(PN_salvato, 'PN')

    % Elaborazione e salvataggio Grafo    
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
    PN.Grafo=Grafo;
    Grafo_salvato=sprintf('Parti_v%1$i_M%2$i/Grafo_M%2$i_%3$i.mat',versione, codice, token_attuale);
    save(Grafo_salvato, 'Grafo')

    indice_macchinario=[indice_macchinario; string(sprintf('M%i_%i',codice, token_attuale))];
    fprintf("Lo script ha salvato il Grafo con %i token \n", token_attuale);
end

%% CALCOLO INDICI DI PRESTAZIONE
l_im=length(indice_macchinario);

for i=1:l_im
    IPx(i)= AnalizzaTokenSingoloMacchinario(versione, codice,token.init+token.delta*(i-1), Precisione,log, RATE_IN,RATE_OUT);
    fprintf("Macchinario %s->\n",indice_macchinario(i));
end

for i=1:l_im
    fprintf("%f -> Macchinario %s ->%f\n "      ,IPx(i).TPU_IN,indice_macchinario(i), IPx(i).TPU_OUT);
    p_tp(i,:)=[IPx(i).TPU_IN , IPx(i).TPU_OUT];
end


end
