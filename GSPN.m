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

% Probabilità delle transizioni
q = table("",0,'VariableNames',["Transizione" "Probabilita"]);
q(1,:)=table("TP1 OK",0.7);
q(2,:)=table("TP1 KO",0.3);
q(3,:)=table("TP2 OK",0.7);
q(4,:)=table("TP2 KO",0.3);

% Rates delle transizioni
u = table("",0,'VariableNames',["Transizione" "Rate"]);
u(1,:)=table("M1Lavorazione",10);
u(2,:)=table("M2Lavorazione",10);
u(3,:)=table("M3Lavorazione",10);
u(4,:)=table("M4Lavorazione",10);
u(5,:)=table("M5Test",10);
u(6,:)=table("M6_1Lavorazione",10);
u(7,:)=table("M6_2Lavorazione",10);
u(8,:)=table("ScaricamentoM7",10);
u(9,:)=table("R1",10);
u(10,:)=table("R2",10);
u(11,:)=table("R3",10);
u(12,:)=table("R4",10);
u(13,:)=table("R5",10);
u(14,:)=table("R6",10);
u(15,:)=table("R7",10);
u(16,:)=table("M9_1Lavorazione",10);
u(17,:)=table("M9_2Lavorazione",10);
u(18,:)=table("M10Lavorazione",10);
u(19,:)=table("M11Test",10);
u(20,:)=table("Pulizia",10);
u(21,:)=table("Etichettatura",10);

Transizioni=["ScaricamentoM7","CaricamentoM8","ScaricamentoM8","R1", "R2", "R3", "R4", "R5", "R6", "R7"];
Posti=["CapacitàN7", "BatterieCariche su N7", "M8_Cella0P", "M8_Cella1", "M8_Cella2", "M8_Cella3", "M8_Cella0V"];

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
clear i idxT idxP;

fprintf("La rete di petri è composta da %i posti e %i transizioni.\n",size(PN.P,1),size(PN.T,1))
% Transizioni immediate: 1
% Transizioni temporizzate: 0
TransizioniImmediate = ones(size(PN.T));
for nome=NomiTransizioniTemporizzate
    TransizioniImmediate(PN.T==nome)=0;
    clear nome;
end
fprintf(" - %i transizioni sono immediate;\n - %i transizioni temporizzate.\n",sum(TransizioniImmediate==1),sum(TransizioniImmediate==0))

%% CALCOLO GRAFO RAGGIUNGIBILITÁ ==========================================
init=struct('Iniziale',[],'Raggiungibili',table());

% Genera la lista degli stati raggiungibili dalla marcatura iniziale M0
[list,Grafo]=CalcolaGrafo(PN.M0,PN.M0,init,PN.C,TransizioniImmediate,PN.Pre,PN.H);
clear init;
% Visualizzo in una figura il grafo di raggiungibilità
VisualizzaGrafo(Grafo,PN.T);

% Il numero degli stati raggiunti è pari al numero di righe del Grafo
[~,num_stati]=size(Grafo); 

% Inizializzazione matrice adiacenze per gli stati
A=zeros(num_stati,num_stati);

for id1=1:num_stati
    for k=1:height(Grafo(id1).Raggiungibili)
        id2=Grafo(id1).Raggiungibili.Marcatura(k);
        A(id1,id2)=Grafo(id1).Raggiungibili.Transizione(k);
    end
end
clear id1 k id2;

%% CALCOLO MATRICE U ======================================================
U=zeros(num_stati,num_stati);

%costruzione della matrice U
for i=1:num_stati
    for j=1:num_stati
        % Se è presente una transizione che porta dallo stato i a j
        if A(i,j)>0
            % Se è una transizione immediata
            if TransizioniImmediate(A(i,j))==1
                % La probabilità è equa
                U(i,j)=1/height(Grafo(i).Raggiungibili);

                % A meno che la transizione non abbia altre probabilità in
                % conflitto con altre transizioni
                if ismember(q.Transizione,PN.T(A(i,j)))
                    % Determino il numero di transizioni con probabilità
                    % cambiata in caso di conflitto, e la somma delle
                    % probabilità presenti. Determino il numero di
                    % transizioni abilitate che appartengono alla tabella e
                    % calcolo il peso totale.
                    num=0;
                    peso_tot=0;
                    for h=1:height(Grafo(i).Raggiungibili)
                        if ismember(q.Transizione,PN.T(Grafo(i).Raggiungibili.Transizione(h)))
                            num=num+1;
                            peso_tot=peso_tot+q.Probabilita(q.Transizione==PN.T(Grafo(i).Raggiungibili.Transizione(h)));
                        end
                    end
                    % La probabilità della transizione è pari alla somma
                    % delle probabilità interessate, pesata con il rapporto
                    % tra il peso assegnato alla transizione e le altre
                    % transizioni in conflitto nella tabella q
                    probabilita_tot = num/height(Grafo(i).Raggiungibili);
                    peso = q.Probabilita(q.Transizione==PN.T(A(i,j)));
                    U(i,j)=probabilita_tot*peso/peso_tot;
                end
            % Se è una transizione temporizzata
            else
                % La probabilità è pari al rate della transizione diviso la
                % somma di tutti i rate delle transizioni abilitate
                rate=u.Rate(u.Transizione==PN.T(A(i,j)));
                rate_tot=0;
                for h=1:height(Grafo(i).Raggiungibili)
                    if any(ismember(u.Transizione,PN.T(Grafo(i).Raggiungibili.Transizione(h))))
                        rate_tot=rate_tot+u.Rate(u.Transizione==PN.T(Grafo(i).Raggiungibili.Transizione(h)));
                    end
                end
                U(i,j)=rate/rate_tot;
            end
        end
    end
end
clear i j h num probabilita_tot peso peso_tot rate rate_tot;

% Controllo che ogni riga abbia sommatoria pari a 1. U deve essere
% stocastica
for i=1:num_stati
    sum=0;
    for j=1:num_stati
        sum=sum+U(i,j);
    end
    if sum~=1
        fprintf("!=== ERRORE ===!\nLa riga %i non ha sommatoria pari a 1.\n",i);
    end
end
clear i j sum;

%% TRASFORMAZIONE DI COORDINATE ===========================================
for i=1:num_stati
    if ~isempty(Grafo(i).Raggiungibili.Transizione) && TransizioniImmediate(Grafo(i).Raggiungibili.Transizione(1))
        v(i)=1;
    end
end
% Ricavo gli indici degli stati tangible 
Index=find(v==1); 
% Inizializzo la matrice di cambio di base
T=zeros(num_stati,num_stati);
% Ordino il vettore degli stati mettendo prima quelli vanishing al fine di trovare la matrice di trasformazione di base
[v1,In]=sort(v,'descend');
% Ricavo la matrice di trasformazione di base
for i=1:num_stati
    T(i,In(i))=1;
end
clear i

%% CALCOLO U' =============================================================
temp=U*T;
num_stati_vanishing=sum(v1);
%    V T
% V |C D|
% T |E F|;
C = temp(1:num_stati_vanishing,1:num_stati_vanishing);
D = temp(1:num_stati_vanishing,num_stati_vanishing+1:end);
E = temp(num_stati_vanishing+1:end,1:num_stati_vanishing);
F = temp(num_stati_vanishing+1:end,num_stati_vanishing+1:end);

% trovare loop
C_temp=eye(num_stati_vanishing,num_stati_vanishing);
G_temp=C_temp;
loop=true;
for k=1:num_stati_vanishing
   C_temp = C_temp*C;
   if C_temp==zeros(num_stati_vanishing,num_stati_vanishing)
       loop=false;
       fprintf("Non è presente alcun loop all'interno del sistema. Il" + ...
           "calcolo di G viene effettuatto attraverso la sommatoria.\n");
       G=G_temp;
       break;
   end
   G_temp=G_temp+C^k;
end
if loop
    fprintf("È presente un loop all'interno del sistema. Il calcolo di" + ...
        " G viene effettuato attraverso l'inversione di matrice\n");
    G=inv(eye(num_stati_vanishing,num_stati_vanishing)-C);
end

U1=F+E*G*D;

%% CALCOLO TEMPI DI SOGGIORNO =============================================
% Verifico che il sistema sia irriducibile
U_temp=eye(num_stati);
connesso_a_M0=zeros(num_stati,1);
for i=1:num_stati
    U_temp=U_temp*U;
    connesso_a_M0(U_temp(:,1)~=0)=1;
end
if sum(connesso_a_M0)==num_stati
    fprintf("Il sistema è irriducibile.\n");
end

% Da perfezionare: devo evitare di calcolare gli arrivi in passi successivi
f_i=zeros(num_stati,1);
f_ok=false(num_stati,1);
U_temp=eye(num_stati);
while ~all(f_ok)
    U_temp=U_temp*U;
    for j=1:num_stati
        if ~f_ok(j)
            f_i(j)=f_i(j)+U_temp(j,j);
            if f_i(j)>=1
                f_ok(j)=true;
            end
        end
    end
end
if all(f_i==1)
    fprintf("Tutti gli stati del sistema sono ricorrenti.\n");
else
    fprintf("Non tutti gli stati del sistema sono ricorrenti.\n");
end

% Se il sistema è irriducibile e riccorrente positivo allora esiste la
% probabilità a regime
Y1 = sym('y1_',[1 num_stati-num_stati_vanishing],'real');
equations= Y1==Y1*U1; 

clear eq
for i=1:num_stati-num_stati_vanishing
eq(i,1) = Y1(i)==Y1*U1(:,i);
end
eq(31,1)= Y1(1)>0;
eq(32,1)= Y1(3)>0;

Y2=solve(eq)