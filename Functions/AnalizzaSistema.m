function IndiciPrestazione = AnalizzaSistema(macchinari,Precisione,RATE_IN,RATE_OUT)
%% PARAMETRI ==============================================================
info_PN = load(['Dati/PN_',macchinari,'.mat']);
PN = info_PN.PN.Ridotta;
Macchinari         = info_PN.PN.Gruppi;
ImpostazioniIndici = info_PN.PN.ImpostazioniIndici;
PN.T.Rate = round(PN.T.Rate/10,1)*10;

clear info_PN;

info_Grafo = load(['Dati/Grafo_',macchinari,'.mat']);
Grafo=info_Grafo.Grafo;
clear info_Grafo;

switch string(macchinari)
    case "P1"
    %Il rate della transizione "OUTPUT" deve essere uguale al RATE_OUT
    PN.T.rate(PN.T.Transizione=="ScaricamentoM4")=RATE_OUT;
    case "P2"
    PN.T.rate(PN.T.Transizione=="ScaricamentoP1")=RATE_IN;
    PN.T.rate(PN.T.Transizione=="ScaricamentoM6")=RATE_OUT;
    case "P3"
    PN.T.rate(PN.T.Transizione=="ScaricamentoP2")=RATE_IN;
    PN.T.rate(PN.T.Transizione=="ScaricamentoM7")=RATE_OUT;
    case "P4"
    PN.T.rate(PN.T.Transizione=="ScaricamentoP3")=RATE_IN;
    PN.T.rate(PN.T.Transizione=="ScaricamentoM9")=RATE_OUT;
    case "P5"
    PN.T.rate(PN.T.Transizione=="ScaricamentoP4")=RATE_IN;
end



% Il numero di marcature
n.stati=size(Grafo,2);

%% CALCOLO MATRICE ADIACENZA ==============================================
% Inizializzazione matrice adiacenze per gli stati
A=cell(n.stati,n.stati);

% Per ogni marcatura A raggiunta verifico quali sono le marcature B
% raggiungibili, e aggiungo l'indice della transizione nella matrice in
% posizione (A,B)
for id1=1:n.stati
    for k=1:height(Grafo(id1).Raggiungibili)
        id2=Grafo(id1).Raggiungibili.Marcatura(k);
        A(id1,id2)={[A{id1,id2} Grafo(id1).Raggiungibili.Transizione(k)]};
    end
end

% Le variabili di appoggio possono ora essere eliminate
clear id1 k id2;

%% CALCOLO MATRICE U ======================================================
% Inizializzazione matrice delle probabilità
U=zeros(n.stati,n.stati);

% Da ogni marcatura, a ogni marcatura, considero tutte le transizioni
% presenti, calcolando la probabilità che si verifichino sulla base delle
% transizioni abilitate (immediate o temporizzate), dei pesi e dei rates.
for i=1:n.stati
    for j=1:n.stati
        % Se è presente una transizione che porta dallo stato i a j
        if ~isempty(A{i,j})
            % Le transizioni sono:
            a_i_j = A{i,j};
            % Se la prima transizione è immediata, allora tutte lo sono
            if PN.T.Maschera(a_i_j(1))==1
                for t=1:length(a_i_j)
                    % La probabilità è equa
                    u_temp(t)=1/height(Grafo(i).Raggiungibili);
                    % A meno che la transizione non abbia altre probabilità
                    % in conflitto con altre transizioni
                    if PN.T.Peso(a_i_j)>0
                        % Determino il numero di transizioni con 
                        % probabilità cambiata in caso di conflitto, e la
                        % somma delle probabilità presenti. Determino il
                        % numero di transizioni abilitate che appartengono
                        % alla tabella e calcolo il peso totale.
                        num=0;
                        peso_tot=0;
                        for h=1:height(Grafo(i).Raggiungibili)
                            if PN.T.Peso(Grafo(i).Raggiungibili.Transizione(h))>0
                                num=num+1;
                                peso_tot=peso_tot+PN.T.Peso(Grafo(i).Raggiungibili.Transizione(h));
                            end
                        end
                        % La probabilità della transizione è pari alla
                        % somma delle probabilità interessate, pesata con
                        % il rapporto tra il peso assegnato alla
                        % transizione e le altre transizioni in conflitto
                        % nella tabella q
                        probabilita_tot = num/height(Grafo(i).Raggiungibili);
                        peso = PN.T.Peso(a_i_j);
                        u_temp(t)=probabilita_tot*peso/peso_tot;
                    end
                end
                U(i,j)=sum(u_temp);
                clear u_temp
            % Se la prima transizione è temporizzata, allora tutte lo sono
            else
                % La probabilità è pari al rate della transizione diviso la
                % somma di tutti i rate delle transizioni abilitate
                for t=1:length(a_i_j)
                    rate=PN.T.Rate(a_i_j(t))*ServerAttivati(Grafo(i).Iniziale,PN.T.Server(a_i_j(t)),PN.Pre(:,a_i_j(t)));
                    rate_tot=0;
                    for h=1:height(Grafo(i).Raggiungibili)
                        if PN.T.Maschera(Grafo(i).Raggiungibili.Transizione(h))==0
                            id_t_temp=Grafo(i).Raggiungibili.Transizione(h);
                            rate_tot=rate_tot+PN.T.Rate(id_t_temp)*ServerAttivati(Grafo(i).Iniziale,PN.T.Server(id_t_temp),PN.Pre(:,id_t_temp));
                        end
                    end
                    u_temp(t)=rate/rate_tot;
                end
                U(i,j)=sum(u_temp);
                clear u_temp;
            end
        end
    end
    if all(U(i,:)==0)
        % Caso di deadlock
        U(i,i)=1;
    end
end
% Le variabili di appoggio possono ora essere eliminate
clear a_i_j i j t h num probabilita_tot peso peso_tot rate rate_tot id_t_temp;

% Controllo che ogni riga abbia sommatoria pari a 1. U deve essere
% stocastica
U=VerificaStocastica(U,Precisione.U);

%% TRASFORMAZIONE DI COORDINATE ===========================================
% Viene associata a ogni marcatura una variabile v, 1 se la marcatura è
% vanishing 0 altrimenti.
v=zeros(1,n.stati);
for i=1:n.stati
    if ~isempty(Grafo(i).Raggiungibili) && PN.T.Maschera(Grafo(i).Raggiungibili.Transizione(1))
        v(i)=1;
    end
end
% fprintf("Le marcature sono %i\n",n.stati);
% fprintf(" - %i stati sono vanishing;\n - %i stati sono tangible.\n\n",sum(v),length(v)-sum(v));

% Ordino il vettore degli stati mettendo prima quelli vanishing al fine di
% trovare la matrice di trasformazione di base
[v1,OrdineV_T]=sort(v,'descend');

% Riordino la matrice U
U_riordinata=zeros(size(U));
for i=1:size(U,1)
    for j=1:size(U,2)
        U_riordinata(i,j)=U(OrdineV_T(i),OrdineV_T(j));
    end
end

%% CALCOLO U' =============================================================
n.stati_v = sum(v1);
n.stati_t = n.stati - n.stati_v;
%    V T
% V |C D|
% T |E F|;
C = U_riordinata(            1:n.stati_v,            1:n.stati_v);
D = U_riordinata(            1:n.stati_v,n.stati_v+1:        end);
E = U_riordinata(n.stati_v+1:        end,            1:n.stati_v);
F = U_riordinata(n.stati_v+1:        end,n.stati_v+1:        end);

clear U_riordinata

% Ricerco possibili loop tra le marcature vanishing. Se non trovo alcun
% loop dopo aver al massimo iterato tutte le marcature vanishing allora la
% matrice G è già calcolata. Se è presente un loop, G viene calcolata con
% la inversione di matrice.
C_temp=eye(n.stati_v,n.stati_v);
G_temp=C_temp;
loop=true;
for k=1:n.stati_v+1
   C_temp = C_temp*C;
   if C_temp==zeros(n.stati_v,n.stati_v)
       loop=false;
       G=G_temp;
       break;
   end
   G_temp=G_temp+C^k;
end
if loop
    G=inv(eye(n.stati_v,n.stati_v)-C);
end

clear v v1 C_temp G_temp loop 

% La matrice delle probabilità ridotta è così calcolata
U1=F+E*G*D;

U1=VerificaStocastica(U1,Precisione.U1);

%% CALCOLO PROPRIETÀ =============================================
%__VALORI A REGIME_________________________________________________________
% Se il sistema è irriducibile e riccorrente positivo allora esiste la
% probabilità a regime
Y_sym = sym('y1_',[1 n.stati_t],'real');
equations= [Y_sym==Y_sym*U1 sum(Y_sym)==1];
Y_struct=solve(equations ,Y_sym);
if isstruct(Y_struct)
    Y=vpa(struct2cell(Y_struct));
    if isempty(Y)
        fprintf("!=== ERRORE ===!\nImpossibile determinare la soluzione Y.\n");
        return
    end
elseif length(Y_struct)==1
    Y=Y_struct;
else
    Y=[];
    fprintf("!=== ERRORE ===!\nImpossibile determinare la soluzione Y.\n");
    return
end
clear Y_sym Y_struct

%__TEMPI DI SOGGIORNO______________________________________________________
m=zeros(n.stati_t,1);
for i=1:n.stati_t
    lambda=0;
    for k=1:height(Grafo(OrdineV_T(n.stati_v+i)).Raggiungibili)
        idMarcatura=OrdineV_T(n.stati_v+i);
        id_t_temp=Grafo(idMarcatura).Raggiungibili.Transizione(k);
        lambda=lambda+PN.T.Rate(id_t_temp)*ServerAttivati(Grafo(idMarcatura).Iniziale,PN.T.Server(id_t_temp),PN.Pre(:,id_t_temp));
    end
    m(i,1)=1/lambda;
end

clear i lambda id_t_temp idMarcatura;

%__PROBABILITÀ A REGIME____________________________________________________
PI=zeros(length(Y),1);
for i=1:length(Y)
    PI(i,1)=(Y(i)*m(i))/sum(Y.*m);
end

clear i

%% INDICI DI PRESTAZIONE ==================================================
% fprintf("\n\n=========== INDICI DI PRESTAZIONE ============================================")
IndiciPrestazione.Transizioni = table(PN.T.Transizione,'VariableNames',"Transizione");
IndiciPrestazione.Posti       = table(PN.P            ,'VariableNames',"Posto");
%__THROUGHPUT______________________________________________________________
% Il throughput è il reciproco del tempo di produzione per unità di
% prodotto. La reward function r è ottenuta moltiplicando il rate della
% transizione temporizzata per il numero di server attivati. Il throughput
% della transizione k-esima è dato dalla somma delle reward function
% moltiplicate per le probabilità a regime.
tp=zeros(1,height(PN.T));
for k=1:height(PN.T)
r=zeros(n.stati_t,1);
    for i=1+n.stati_v:(n.stati)
        if ismember(k,Grafo(OrdineV_T(i)).Raggiungibili.Transizione)
            r(i-n.stati_v)=PN.T.Rate(k)*ServerAttivati(Grafo(OrdineV_T(i)).Iniziale,PN.T.Server(k),PN.Pre(:,k));
        end
    end
    tp(k)=sum(r.*PI);
end
tp=SistemaThroughput(tp,macchinari,PN);

IndiciPrestazione.TPU_OUT=tp(PN.T.Transizione==string(ImpostazioniIndici.T_Per_TPU));
switch string(macchinari)
    case "1,2,3,4"
        temp = "CaricamentoM1";
    case "5,6"
        temp = "CaricamentoM5";
    case "8,9,10"
        temp="CaricamentoM8";
    case "11,12,13"
        temp="CaricamentoM11";
end
IndiciPrestazione.TPU_IN=tp(PN.T.Transizione==temp);


IndiciPrestazione.Transizioni.TPU = tp.';
clear temp k i r tp

%__NUMERO MEDIO DI TOKEN___________________________________________________
% Per ogni posto k-esimo viene calcolato il numero medio di token associato
% al posto. Esso viene calcolato sommando il prodotto tra le probabilità a
% regime che il sistema si trovi in quella marcatura e il numero di token
% nel posto k-esimo
numero_medio_token=zeros(1,length(PN.P));
for k=1:length(PN.P)
    r=zeros(n.stati_t,1);
    for i=1+n.stati_v:(n.stati)
        r(i-n.stati_v)=Grafo(OrdineV_T(i)).Iniziale(k);
    end
    numero_medio_token(k)=sum(r.*PI);
end

IndiciPrestazione.Posti.NumeroMedioToken=numero_medio_token.';

clear k i numero_medio_token r

%__WIP_____________________________________________________________________
% Il Work in Process è dato dalla somma del numero medio di token
WIP=sum(IndiciPrestazione.Posti.NumeroMedioToken.*ImpostazioniIndici.Tabella_WIP.DaConsiderare);

IndiciPrestazione.WIP=WIP;
clear WIP

%__MLT_____________________________________________________________________
% Il Manufacturing Lead Time è stato calcolando facendo il rapporto tra il
% WIP e il throughput minimo (diverso da zero) del sistema
MLT=IndiciPrestazione.WIP/IndiciPrestazione.TPU_OUT;

IndiciPrestazione.MLT=duration(hours(MLT),'format','hh:mm:ss.SSSS');

clear i j tp_min MLT

%__TEMPO MEDIO ATTESA______________________________________________________
% Il tempo medio di attesa relativo al k-esimo posto è dato dal rapporto 
% tra il numero medio di token del posto e la somma dei throughput relativi
% alle transizioni che depositano token nel posto.
tempo_medio_attesa=zeros(1,length(PN.P));
 for k=1:length(PN.P)
     tp_posti=0;
     for j=1:height(PN.T)
         if PN.Post(k,j)>0
             tp_posti=tp_posti+IndiciPrestazione.Transizioni.TPU(j)*PN.Post(k,j);
         end
     end
     tempo_medio_attesa(k)=IndiciPrestazione.Posti.NumeroMedioToken(k)/tp_posti;
 end

IndiciPrestazione.Posti.TempoMedioAttesa=duration(hours(tempo_medio_attesa),'format','hh:mm:ss.SSSS').';

clear tp_posti k j i tempo_medio_attesa

%__EFFICENZA_______________________________________________________________
for i_macc = 1 : height(ImpostazioniIndici.Tabella_EFF)
    id_t=find(PN.T.Transizione==ImpostazioniIndici.Tabella_EFF.Transizione(i_macc));
    for i_marc=n.stati_v+1:n.stati
        server_in_lavorazione = ServerAttivati(Grafo(OrdineV_T(i_marc)).Iniziale,PN.T.Server(id_t),PN.Pre(:,id_t));
        eff_marc(i_marc-n.stati_v)=PI(i_marc-n.stati_v)*server_in_lavorazione/PN.T.Server(id_t);
    end
    eff_mac(i_macc,:)=table(ImpostazioniIndici.Tabella_EFF.Gruppo(i_macc),sum(eff_marc)*100,'VariableNames',["Macchinario","Efficenza"]);
    clear eff_marc;
end

eff_mac=rmmissing(eff_mac);
IndiciPrestazione.Macchinari=eff_mac;

clear eff_marc eff_mac i_macc i_marc i_eff trans_macc trans_temp posti_macc nome server_totali server_in_lavorazione t

%% SALVATAGGIO
save(['Dati\IndiciPrestazione_{',macchinari,'}.mat'],"IndiciPrestazione");

end

