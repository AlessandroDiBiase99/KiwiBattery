%% PREPPARAZIONE WORKSPACE ================================================
clear;
clc;
format short;

%% PARAMETRI ==============================================================
% Percorso del file excel contenente le matrici e foglio di lavoro
File.Path  = 'MatriciCalcolate.xlsx';
File.Sheet = '7_T_S';

% Nomi delle transizioni temporizzate
NomiTransizioniTemporizzate = ["M1Lavorazione" "M2Lavorazione" ...
    "M3Lavorazione" "M4Lavorazione" "M5Test" "M6_1Lavorazione"...
    "M6_2Lavorazione" "ScaricamentoM7" "R1" "R2" "R3" "R4" "R5" "R6" "R7"...
    "M9_1Lavorazione" "M9_2Lavorazione" "M10Lavorazione" "M11Test"...
    "Pulizia" "Etichettatura"];

% Probabilit‡ delle transizioni
q = table("",0,'VariableNames',["Transizioni" "Probabilit‡"]);
q(1,:)=table("TP1 OK",0.7);
q(2,:)=table("TP1 KO",0.3);
q(3,:)=table("TP2 OK",0.7);
q(4,:)=table("TP2 KO",0.3);

% Rates delle transizioni
u = [];
% % Rates
% u0=10;  %rate t0 
% u1=9;  %rate t1 
% u3=16; %rate- 
% u4=16; %rate 
% u5=24; %rate 
% u8=14; %rate 
% u9=50; % rate 
% u10=20; %rate 

Transizioni=["ScaricamentoM7","CaricamentoM8","ScaricamentoM8","R1", "R2", "R3", "R4", "R5", "R6", "R7"];
Posti=["Capacit‡N7", "BatterieCariche su N7", "M8_Cella0P", "M8_Cella1", "M8_Cella2", "M8_Cella3", "M8_Cella0V"];

%% CARICAMENTO DATI =======================================================
PN1 = ImportaDati(File.Path,File.Sheet);

for i=1:length(Transizioni)
    idxT(i)=find(strcmp(PN1.T,Transizioni(i)));
end
for i=1:length(Posti)
    idxP(i)=find(strcmp(PN1.P,Posti(i)));
end
PN.M0 = PN1.M0(idxP);
PN.H = PN1.H(idxP,idxT);
PN.C = PN1.C(idxP,idxT);
PN.Pre = PN1.Pre(idxP,idxT);
PN.Post = PN1.Post(idxP,idxT);
PN.T=PN1.T(idxT);
PN.P=PN1.P(idxP);

fprintf("La rete di petri Ë composta da %i posti e %i transizioni.\n",size(PN.P,1),size(PN.T,1))
% Transizioni immediate: 1
% Transizioni temporizzate: 0
TransizioniImmediate = ones(size(PN.T));
for nome=NomiTransizioniTemporizzate
    TransizioniImmediate(PN.T==nome)=0;
    clear nome;
end
fprintf(" - %i transizioni sono immediate;\n - %i transizioni temporizzate.\n",sum(TransizioniImmediate==1),sum(TransizioniImmediate==0))

%% CALCOLO GRAFO RAGGIUNGIBILIT¡ ==========================================
% Inizializzazione lista marcature
list=[];
% Inizializzazione lista
Ragg=struct('Iniziale',[],'Raggiungibili',table());


[list,Grafo]=CalcolaGrafo(PN.M0,PN.M0,Ragg,PN.C,TransizioniImmediate,PN.Pre,PN.H);
VisualizzaGrafo1(Grafo,PN.T);
return;
% Genera la lista degli stati raggiungibili dalla marcatura iniziale M0
[list,Ragg]=Calcola_Marc_Ragg(PN.M0,list,Ragg,PN.C,TransizioniImmediate,PN.Pre,PN.H);

% Il numero degli stati raggiunti Ë pari al numero di righe della lista
% delle strutture dati Ragg
[ns, k]=size(Ragg); 

A=zeros(ns,ns);%inizializzazione matrice adiacenze per gli stati
% v=zeros(ns,1);%Inizializzazione vettore degli stati vanishing

for i=1:ns
    % Il numero di transizioni abilitate
    n_t_abilitate=length(Ragg(i).T_fin);
    % L'indice della colonna relativa alla marcatura iniziale nella lista 
    [~,id1]=ismember(Ragg(i).M_ini',list',"rows");
    % Per ogni transizione abilitata
    for k=1:n_t_abilitate
        % L'indice della colonna relativa alla marcatura finale nella lista
        [~,id2]=ismember(Ragg(i).M_fin(:,k)',list',"rows");
        A(id1,id2)=Ragg(i).T_fin(:,k);
    end
end

% Siamo arrivati a sistemare il file fino qui
return
%% Calcolo Matrice U ======================================================
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
                
            case 3 %la transizione T2 Ë immediata
              
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
                
            case 7 % la transizione T6 Ë immediata
               for h=1:ns
                    if A(i,h)== 3 
                        U(i,j)=0;
                        break
                    else
                        U(i,j)=q6; %la probabilità ? data da q1
                    end
                end
         
            case 8 % la transizione T7 Ë immediata
                 for h=1:ns
                    if A(i,h)== 3 
                        U(i,j)=0;
                        break
                    else
                        U(i,j)=q7; %la probabilità ? data da q1
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
            v(i)=1;% se allo stato i-esimo Ë abilitata almeno una transizione immediata tale stato Ë vanishing
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