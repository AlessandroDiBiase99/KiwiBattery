function IndiciPrestazione = AnalizzaSistema(versione,macchinari,Precisione,log,RATE_IN,RATE_OUT)
% AnalizzaSistema è una funzione che calcola gli indici di prestazione dei
% dati salvati nei specifici file nella cartella Parti_v1, rispettando i
% parametri passati alla chiamata della funzione.
% **INPUT**
%   macchinari
%    codice di riconoscimento dei macchinari da lavorare, con i quali sono
%    anche indicati i file PN e Grafo
%   Precisione
%    struct con due campi: U e U1. Il primo campo serve per stabilire le
%    cifre significative per il calcolo di U, il secondo per il calcolo di
%    U1.
%   log: 
%    - 0          mostrare tutti i messaggi
%    - 1          mostrare solo i passaggi principali
%    - altrimenti mostrare solo i messaggi di errore
%   RATE_IN
%    il rate di input del sistema che deve essere rispettato
%   RATE_OUT
%    il rate di output del sistema che deve essere rispettato
% **OUTPUT**
%   IndiciPrestazione
%    - THROUGHPUT
%    - MLT
%    - WIP
%    - POSTI
%    - TRANSIZIONI

%% PARAMETRI ==============================================================
if log<=1
    fprintf("\n1) Caricamento PN e Grafo di %s.\n",macchinari)
end

if log==0
    fprintf("   -> Carico Parti_v%i/%s.mat.\n",versione,macchinari)
end
info_PN = load(sprintf("Parti_v%i/PN_%s.mat",versione,macchinari));
PN = info_PN.PN.Ridotta;
ImpostazioniIndici = info_PN.PN.ImpostazioniIndici;

if log==0
    fprintf("   -> Carico Parti_v%i/Grafo_%s.mat.\n",versione,macchinari)
end
info_Grafo = load(sprintf("Parti_v%i/Grafo_%s.mat",versione,macchinari));
Grafo=info_Grafo.Grafo;
clear info_PN info_Grafo;

if log==0
    fprintf("   -> Adeguo i rate di input e output con i parametri passati.\n")
end
switch string(macchinari)
    case "M1_2_3"
    PN.T.Rate(PN.T.Transizione=="Giunzione3") = RATE_OUT;
    case "M2"
    PN.T.Rate(PN.T.Transizione=="Giunzione1") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione2") = RATE_OUT;
    case "M3"
    PN.T.Rate(PN.T.Transizione=="Giunzione2") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione3" ) = RATE_OUT;
    case "M4"
    PN.T.Rate(PN.T.Transizione=="Giunzione3" ) = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione4") = RATE_OUT;
    case "M5"
    PN.T.Rate(PN.T.Transizione=="Giunzione4") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione5" ) = RATE_OUT;
    case "M6"
    PN.T.Rate(PN.T.Transizione=="Giunzione5" ) = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione6") = RATE_OUT;
    case "M7_1"
    PN.T.Rate(PN.T.Transizione=="Giunzione6" ) = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione7_1") = RATE_OUT;
    case "M7_2"
    PN.T.Rate(PN.T.Transizione=="Giunzione7_1") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione7_2") = RATE_OUT;
    case "M7_3"
    PN.T.Rate(PN.T.Transizione=="Giunzione7_2") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione7") = RATE_OUT;
    case "M8"
    PN.T.Rate(PN.T.Transizione=="Giunzione7") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione8") = RATE_OUT;
    case "M9"
    PN.T.Rate(PN.T.Transizione=="Giunzione8") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione9") = RATE_OUT;
    case "M10"
    PN.T.Rate(PN.T.Transizione=="Giunzione9") = RATE_IN;
    PN.T.Rate(PN.T.Transizione=="Giunzione10") = RATE_OUT;
    case "M11_12_13"
    PN.T.Rate(PN.T.Transizione=="Giunzione10") = RATE_IN;
end

if string(macchinari)~="M7_2"
    PN.T.Rate = round(PN.T.Rate,2);
end

% Il numero di marcature
n.stati=size(Grafo,2);

%% CALCOLO MATRICE ADIACENZA ==============================================
if log<=1
    fprintf("\n2) Calcolo matrice di adiacenza A.\n")
end

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
if log<=1
    fprintf("\n3) Calcolo matrice delle probabilità U.\n")
end
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
clear A a_i_j i j t h num probabilita_tot peso peso_tot rate rate_tot id_t_temp;

if log==0
    fprintf("   -> Verifico la correttezza degli arrotondamenti calcolati.\n")
end
% Controllo che ogni riga abbia sommatoria pari a 1. U deve essere
% stocastica
U=VerificaStocastica(U,Precisione.U);

% if macchinari=='P3'
%     PN.T.Rate=PN.T.Rate/100;
% end

%% TRASFORMAZIONE DI COORDINATE ===========================================
if log<=1
    fprintf("\n4) Trasformazione di coordinate della matrice delle probabilità con U.\n")
end
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

n.stati_v = sum(v1);
n.stati_t = n.stati - n.stati_v;

if log==0
    fprintf("   -> Ci sono %i marcature, %i tangible e %i vanishing.\n",n.stati,n.stati_t,n.stati_v)
end

%% CALCOLO U' =============================================================
if log<=1
    fprintf("\n5) Calcolo della matrice delle probabilità U ridotta.\n")
end

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

if log==0
    fprintf("   -> Verifico la correttezza degli arrotondamenti calcolati con U1.\n")
end
U1=VerificaStocastica(U1,Precisione.U1);

%% CALCOLO PROPRIETÀ ======================================================
if log<=1
    fprintf("\n6) Calcolo dei valori a regime.\n")
end
%__VALORI A REGIME_________________________________________________________
if log==0
    fprintf("   -> Calcolo delle probabilità a regime nella EMC.\n")
end
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
if log==0
    fprintf("   -> Calcolo dei tempi di soggiorno.\n")
end
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
if log==0
    fprintf("   -> Calcolo delle probabilità a regime nella GSPN.\n")
end
PI=zeros(length(Y),1);
for i=1:length(Y)
    PI(i,1)=(Y(i)*m(i))/sum(Y.*m);
end

clear i;

%% INDICI DI PRESTAZIONE ==================================================
if log<=1
    fprintf("\n7) Calcolo degli indici di prestazione.\n")
end
% fprintf("\n\n=========== INDICI DI PRESTAZIONE ============================================")
IndiciPrestazione.Transizioni = table(PN.T.Transizione,'VariableNames',"Transizione");
IndiciPrestazione.Posti       = table(PN.P            ,'VariableNames',"Posto");

%__THROUGHPUT______________________________________________________________
if log==0
    fprintf("   -> Calcolo throughput.\n")
end
% Il throughput è il reciproco del tempo di produzione per unità di
% prodotto. La reward function r è ottenuta moltiplicando il rate della
% transizione temporizzata per il numero di server attivati. Il throughput
% della transizione k-esima è dato dalla somma delle reward function
% moltiplicate per le probabilità a regime.
tp=zeros(1,height(PN.T));
for k=1:height(PN.T)
r=zeros(n.stati_t,1);
    for i=1+n.stati_v:(n.stati)
        try
        if ismember(k,Grafo(OrdineV_T(i)).Raggiungibili.Transizione)
            r(i-n.stati_v)=PN.T.Rate(k)*ServerAttivati(Grafo(OrdineV_T(i)).Iniziale,PN.T.Server(k),PN.Pre(:,k));
        end
        catch 
            fprintf("ao");
        end
    end
    tp(k)=sum(r.*PI);
end
switch string(macchinari)
    case "M1_2_3"
        macc = '1,2,3';
        nome_t_input = "M1_Caricamento";
    case "M2"
        macc = '2';
        nome_t_input = "Giunzione1";
    case "M3"
        macc= '3';
        nome_t_input= "Giunzione2";
    case "M4"
        macc= '4';
        nome_t_input= "Giunzione3";
    case "M5"
        macc= '5';
        nome_t_input= "Giunzione4";
    case "M6"
        macc = '6';
        nome_t_input = "Giunzione5";
    case "M7_1"
        macc = '7_1';
        nome_t_input="Giunzione6";
    case "M7_2"
    macc = '7_2';
    nome_t_input="Giunzione7_1";
    case "M7_3"
    macc = '7_3';
    nome_t_input="Giunzione7_2";
    case "M8"
    macc = '8';
    nome_t_input="Giunzione7";
    case "M9"
    macc = '9';
    nome_t_input="Giunzione8";
    case "M10"
    macc = '10';
    nome_t_input="Giunzione9";
    case "M11_12_13"
    macc = '11,12,13';
    nome_t_input="Giunzione10";
end
tp=SistemaThroughput(tp,macc,PN);

IndiciPrestazione.TPU_OUT=tp(PN.T.Transizione==string(ImpostazioniIndici.T_Per_TPU));
IndiciPrestazione.TPU_IN=tp(PN.T.Transizione==nome_t_input);


IndiciPrestazione.Transizioni.TPU = tp.';
clear nome_t_input k i r tp

%__NUMERO MEDIO DI TOKEN___________________________________________________
if log==0
    fprintf("   -> Calcolo numero medio token.\n")
end
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
if log==0
    fprintf("   -> Calcolo WIP.\n")
end
% Il Work in Process è dato dalla somma del numero medio di token
WIP=sum(IndiciPrestazione.Posti.NumeroMedioToken.*ImpostazioniIndici.Tabella_WIP.DaConsiderare);

IndiciPrestazione.WIP=WIP;
clear WIP

%__MLT_____________________________________________________________________
if log==0
    fprintf("   -> Calcolo MLT.\n")
end
% Il Manufacturing Lead Time è stato calcolando facendo il rapporto tra il
% WIP e il throughput minimo (diverso da zero) del sistema
MLT=IndiciPrestazione.WIP/IndiciPrestazione.TPU_OUT;

IndiciPrestazione.MLT=duration(hours(MLT),'format','hh:mm:ss.SSSS');

clear i j tp_min MLT

%__TEMPO MEDIO ATTESA______________________________________________________
if log==0
    fprintf("   -> Calcolo tempo medio di attesa.\n")
end
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
if log==0
    fprintf("   -> Calcolo efficenza.\n")
end
eff_mac=table();
for i_macc = 1 : height(ImpostazioniIndici.Tabella_EFF)
    id_t=find(PN.T.Transizione==ImpostazioniIndici.Tabella_EFF.Transizione(i_macc));
    for i_marc=n.stati_v+1:n.stati
        server_in_lavorazione = ServerAttivati(Grafo(OrdineV_T(i_marc)).Iniziale,PN.T.Server(id_t),PN.Pre(:,id_t));
        eff_marc(i_marc-n.stati_v)=PI(i_marc-n.stati_v)*server_in_lavorazione/PN.T.Server(id_t);
    end
    eff_mac(i_macc,:)=table(ImpostazioniIndici.Tabella_EFF.Gruppo(i_macc),sum(eff_marc)*100,'VariableNames',["Macchinario","Efficenza"]);
    clear eff_marc;
end
if ~isempty(eff_mac)
    eff_mac=rmmissing(eff_mac);
end
IndiciPrestazione.Macchinari=eff_mac;

clear eff_marc eff_mac i_macc i_marc i_eff trans_macc trans_temp posti_macc nome server_totali server_in_lavorazione t

%% SALVATAGGIO
if log<=1
    fprintf("\n8) Calcolo degli indici di prestazione.\n")
end
save(sprintf("Parti_v%i\\IndiciPrestazione_%s.mat",versione,macchinari),"IndiciPrestazione");

end

