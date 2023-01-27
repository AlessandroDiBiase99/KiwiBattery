
%% Programma principale %%
clear;
clc;
format short;
%%Inizializzazione

list=[];%inizializzazione lista marcature
Ragg=[];%inizializzazione lista

%--------------------------------------------------------------------
%L'ORDINE CON CUI ANALIZZO POSTI E TRANSIZIONI E' DATO DALLA MATRICE I
%OTTENUTA CON PIPE (VEDI FILE I.png)
%--------------------------------------------------------------------


m_ini=[1 0	0	0	0	0	6	3	3	0	0	0	1	3	0	0	1]; % marcatura iniziale di pipe


%ordine transizioni: t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10
maschera_trans=[0 0 0 0 0 1 1 1 1 1 1 1 0]; % maschera transizioni immediate di 
% pipe (1 immediate, 0 temporizzate)

    
matrici_pre_I %script con matrici Pre e Incidenza


% 19 posti e 11 transizioni

%probabilità
q7=0.7; %prob t7   t7 (tOK) e t6 (tFAIL) in conflitto (test)
q6=1-q7; %prob t6
q2=1;

%rates
u0=10;  %rate t0 
u1=9;  %rate t1 
u3=16; %rate- 
u4=16; %rate 
u5=24; %rate 
u8=14; %rate 
u9=50; % rate 
u10=20; %rate 

[list,Ragg]=Calcola_Marc_Ragg(m_ini,list,Ragg,I,maschera_trans,pre); %genera la lista 
%degli stati raggiungibili a partire dalla marcatura iniziale m0
[ns, k]=size(Ragg); %il numero degli stati è dato dalle righe della lista 
%delle marcature raggiungibili

mr=zeros(ns,19);
n_multiple=1; 


for i=1:ns
    mr(i,:)=Ragg(i).value; %lista delle marcature raggiungibili ordinata 
    %come l'uscita della funzione Calcola_Marc_Ragg
end

A=zeros(ns,ns);%inizializzazione matrice adiacenze per gli stati
v=zeros(ns,1);%Inizializzazione vettore degli stati vanishing


for i=1:ns
    [a, b]=size(Ragg(i).abi);%numero transizioni attivate
    [aa, bb]=size(Ragg(i).out.value);%numero stati uscenti
    abiIndex=find(Ragg(i).abi); %Ho tutti gli indici delle transizioni 
    %abilitate
    for k=1:aa;%per ogni stato uscente
        for j=1:ns
            if strmatch(Ragg(i).out.value(k,:),Ragg(j).value)%controlla 
                %la posizione nella lista nel k-esimo stato uscente dallo 
                %stato i-esimo se è presente nella Ragg
                A(i,j)=Ragg(i).abi(abiIndex(k));%Assegna alla matrice il 
                %numero della transizione che collega i due stati
            end
        end
    end
end


%%
%Calcolo Matrice U
U=zeros(ns,ns);

for i=1:ns%costruzione della matrice U
    for j=1:ns
        switch A(i,j)%si analizza ogni elemento della matrice A
            
            %si scorrono le varie transizioni (secondo l'ordine della I di
            %Pipe) e si calcola l'elemento U(i,j) corrispondente dividendo
            %il rate della transizione considerata, per la somma delle
            %transizioni uscenti da quel posto (per il calcolo del
            %denominatore si usa la funzione apposita)
            case 1 %la transizione T0, ha rate u0
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u0/den;
                else
                    U(i,j)=0;
                end 
                
            case 2 %la transizione T1, ha rate u1
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u1/den;
                else
                    U(i,j)=0;
                end 
                
            case 3 %la transizione T2 è immediata
              
                U(i,j)=q2;     
              
            case 4 %la transizione 'caricamento' ha rate u3
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u3*min([Ragg(i).value(8),Ragg(i).value(10),n_multiple])/den;
                else
                    U(i,j)=0;
                end   
                
            case 5 % la transizione 'lavorazione' ha rate u4
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                     U(i,j)=u4*min([Ragg(i).value(9),Ragg(i).value(12),n_multiple])/den;
                else
                    U(i,j)=0;
                end   
                
            case 6 %la transizione 'test' ha rate u5
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u5*min([Ragg(i).value(11),Ragg(i).value(13),n_multiple])/den;
                else
                    U(i,j)=0;
                end  
                
            case 7 % la transizione T6 è immediata
               for h=1:ns
                    if A(i,h)== 3 
                        U(i,j)=0;
                        break
                    else
                        U(i,j)=q6; %la probabilitˆ ? data da q1
                    end
                end
         
            case 8 % la transizione T7 è immediata
                 for h=1:ns
                    if A(i,h)== 3 
                        U(i,j)=0;
                        break
                    else
                        U(i,j)=q7; %la probabilitˆ ? data da q1
                    end
                end
                
            case 9 %la transizione T8, ha rate u8
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u8/den;
                else
                    U(i,j)=0;
                end  
                
            case 10 %la transizione T9, ha rate u9
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u9/den;
                else
                    U(i,j)=0;
                end  
        
             case 11 %la transizione T10, ha rate u10
                den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple);
                if den~=0
                    U(i,j)=u10*min([Ragg(i).value(7),Ragg(i).value(18)])/den;
                else
                    U(i,j)=0;
                end 
        end
    end
end

%%somma per righe della U (devono essere pari a 1)
% sum=0;
% for i=1:1:ns
%     zum(i)=sum;
%     sum=0;
%     for j=1:1:ns
%         sum=sum+U(i,j);
%     end
% end
% zums=sym(zum)


%%TRASFORMAZIONE DI COORDINATE
for i=1:ns
    [aa, nabi]=size(Ragg(i).abi);
    for k=1:nabi
        if Ragg(i).abi(k)==7||Ragg(i).abi(k)==8 || Ragg(i).abi(k)== 3
            v(i)=1;% se allo stato i-esimo è abilitata almeno una transizione immediata tale stato è vanishing
        end
    end
end
Index=find(v==1); % utilizzato per ricavare i soli stati tangible 
T=zeros(ns,ns);%inizializzazione matrice di cambio di base
[v1,In]=sort(v,'descend');%ordina il vettore degli stati mettendo prima quelli vanishing al fine di trovare la matrice di trasformazione di base
for i=1:ns
    T(i,In(i))=1;%Routine per ricavare la matrice di trasformazione di base
end


%% CALCOLO U'


%%
% %CALCOLO TEMPI DI SOGGIORNO
% 