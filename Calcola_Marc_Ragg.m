function [list,Ragg] = Calcola_Marc_Ragg(a,list,Ragg,I,maschera_trans,pre) 
    %%%Parametri in ingresso: 
    %a=vettore delle marcature iniziali 
    %list = valore attuale dell'elenco degli stati raggiunti (inizialmente 
    %è una stringa nulla) 
    %Ragg= valore attuale dell'elenco della struttura relativa agli stati 

    %%% Parametri in uscita 
    %list=elenco aggiornato delle marcature raggiunte 
    %Ragg=elenco aggiornato delle strutture relative alle marcature 
    %raggiunte

    [m, m2]=Crea_Struttura(a,I,maschera_trans,pre);%calcola la struttura della matrice 
    %m è la struttura con marcature e transizioni abilitate 
    %m2 contiene le marcature raggiunte dallo stato considerato (a)
    
    m1=m.out.value; %ricava gli stati uscenti dallo stato 
    [nm, mm]=size(m1); 
    for i=1:nm 
        if strmatch(m2(i,:),list)>0  %#ok<*MATCH2>
        else%se m2 non è nella lista delle marcature raggiungibili 
            list=[list;m2(i,:)];%aggiunge m2 alla lista 
            [m, l]=Crea_Struttura(m2(i,:),I,maschera_trans,pre);%#ok<*ASGLU> %richiama la funzione per
            %ogni stato uscente dalla marcatura 
            Ragg=[Ragg;m];%#ok<*AGROW> %aggiunge la struttura relativa a Ragg 
            [list,Ragg]=Calcola_Marc_Ragg(m1(i,:),list,Ragg,I,maschera_trans,pre);%si 
            %richiama ricorsivamente la funzione stessa per ogni nuovo 
            %stato fino a quando gli stati raggiunti sono tutti 
            %collezionati in list 
        end
    end
end
