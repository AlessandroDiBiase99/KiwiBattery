function [m0, m1] = Crea_Struttura(m,C,maschera_trans,pre) 
    %Tale funzione viene utilizzata per calcolare le marcature raggiunte da
    %uno stato creando una un elemento avente la seguente struttura:
    
    %m0.value=marcature dello stato 
    %m0.abi=transizioni abilitate 
    %m0.out.num=numero di posti raggiungibili ad un passo dallo stato 
    %m0.out.value=stati raggiungibili dallo stato m0

    %%% Parametri in ingresso: 
    %m stato iniziale 
    %I matrice di incidenza 
    %pre matrice pre 

    %%% Parametri in uscita: 
    %m0 struttura suddetta 
    %m1 marcature raggiunte dallo stato m0 

    test=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19]';
    
    m0.value=m; %inserisco la marcatura iniziale nelle possibili marcature 
    %dello stato
    [np,nt]=size(pre);%acquisisco il numero dei posti ed il numero delle 
    %transizioni dalla matrice pre inserita

    m0v=zeros(np,np);%Inizializzo la matrice che contiene i risultati delle
    %differenze tra la marcatura considerata e le varie colonne della pre
    m0Abi=zeros(1,nt);%Inizializzo il vettore delle transizioni abilitate 
    %a m0 
%    set(m0Abi,'RecursionLimit',10000)
 
    for i=1:1:nt 
        f=find((m0.value'-pre(:,i))>=0);%controlla se l'eventuale scatto 
        %della transizione i-esima porta ad una marcatura negativa 
            if isequal(f,test)%se la transizione i-esima è abilitata 
                m0Abi(i)=1;%la marcatura è abilitata 
                m0v(i,:)=m0.value'-pre(:,i); 
            end
    end
    
    m0.out.num=sum(m0Abi);%numero transizioni abilitate 
    a=find(m0Abi>0);%verifica quali sono le transizioni abilitate

    t=zeros(nt,nt);%Inizializzazione matrice relative alle transizioni 
    for i=1:1:m0.out.num%per ogni transizione abilitata 
        t(a(i),i)=m0Abi(a(i));%assegna il valore alla posizione nella 
        %matrice delle transizioni (sarà una matrice di 0 e di 1)
    end
    
    %Nella matrice t2 avrò solo matrici immediate 
    t2=t;%Inizializzazione matrice delle transizioni solo immediate. 
    temp=find(maschera_trans==0);%trova in che colonna sono le transizioni 
    %temporizzate 
    [~, ntemp]=size(temp); 
    for i=1:ntemp 
        t2(temp(i),:)=zeros(1,nt);%ogni transizione temporizzata viene 
        %eliminata dalla matrice t2 
    end

    a2=zeros(1,nt);%inizializzazione di a2 in cui avrò tutte le transizioni
    %abilitate
    j=1;%inizializzazione contatore transizioni abilitate 
    if sum(m0Abi)>=1%se ci sono transizioni abilitate 
        for i=1:1:m0.out.num 
            if sum(sum(t2))~=0 %se c'è almeno una transizione immediata 
                %abilitata 
                if isequal(t2(:,i),zeros(nt,1))==0%se la transizione è 
                    %immediata 
                    m0.out.value(j,:)=m0.value+(C*t(:,i))';%la fa scattare 
                    j=j+1;%incremento il numero delle transizioni abilitate 
                    a2(i)=a(i);%la transizione iesima abilitata
                end
            else %se ci sono solo transizioni temporizzate 
                m0.out.value(j,:)=m0.value+(C*t(:,i))';%la transizione 
                %iesima viene fatta scattare 
                j=j+1;%incremento il numero delle transizioni abilitate 
                a2(i)=a(i); 
            end
        end
    end  
    
    m0.abi=a2; %assegno i valori alla struttura 
    m0.abi2=a;
    m0.out.num=j-1; 
    m1=m0.out.value;
    
end

