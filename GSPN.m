%% PREPARAZIONE WORKSPACE ================================================
% Tutte le figure sono chiuse, il workspace svuotato, la command window
% pulita. Viene aggiunta la directory delle funzioni al spazio di
% esecuzione Matlab.
close all;
clear all;
clc;
addpath("Functions")

%% PARAMETRI ==============================================================
% Nome del file generato con GestoreAnalisiPN da caricare
macchinari='1,2,3,4';
dati_PN = ['Dati/PN_{',macchinari,'}.mat'];
dati_Grafo = ['Dati/Grafo_{',macchinari,'}.mat'];

TAB = 27;

clear macchinari;

%% CARICAMENTO DATI =======================================================
% I dati relativi alla PN e al Grafo realizzati attraverso GestoreAnalisiPN
% sono importati nello script, assicurando di avere i nomi corretti.
info_PN = load(dati_PN);
PN = info_PN.PN.Ridotta;
Macchinari=info_PN.PN.Macchinari;

info_Grafo = load(dati_Grafo);
Grafo=info_Grafo.Grafo;

% Le variabili di appoggio possono ora essere eliminate
clear info_PN info_Grafo

% Un messaggio che descrive la PN e il grafo in breve viene stampato per 
% l'utente
fprintf("La rete di petri è composta da %i posti e %i transizioni.\n",size(PN.P,1),size(PN.T,1))
fprintf(" - %i transizioni sono immediate;\n - %i transizioni temporizzate.\n\n",sum(PN.T.Maschera==1),sum(PN.T.Maschera==0))

% Arrotondiamo all'unità per evitare errori numerici nel calcolo di U
PN.T.Rate=round(PN.T.Rate/10,1)*10;
%PN.T.Rate(end)=1;

% Il numero di marcature raggiunte viene salvato
n_stati=size(Grafo,2);

%% CALCOLO MATRICE ADIACENZA ==============================================
% Inizializzazione matrice adiacenze per gli stati
A=cell(n_stati,n_stati);

% Per ogni marcatura A raggiunta verifico quali sono le marcature B
% raggiungibili, e aggiungo l'indice della transizione nella matrice in
% posizione (A,B)
for id1=1:n_stati
    for k=1:height(Grafo(id1).Raggiungibili)
        id2=Grafo(id1).Raggiungibili.Marcatura(k);
        A(id1,id2)={[A{id1,id2} Grafo(id1).Raggiungibili.Transizione(k)]};
    end
end

% Le variabili di appoggio possono ora essere eliminate
clear id1 k id2;

%% CALCOLO MATRICE U ======================================================
% Inizializzazione matrice delle probabilità
U=zeros(n_stati,n_stati);

% Da ogni marcatura, a ogni marcatura, considero tutte le transizioni
% presenti, calcolando la probabilità che si verifichino sulla base delle
% transizioni abilitate (immediate o temporizzate), dei pesi e dei rates.
for i=1:n_stati
    for j=1:n_stati
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
                clear u_temp
            end
        end
    end
end

% Le variabili di appoggio possono ora essere eliminate
clear i j h num probabilita_tot peso peso_tot rate rate_tot;

% Controllo che ogni riga abbia sommatoria pari a 1. U deve essere
% stocastica
for i=1:n_stati
    sum=0;
    for j=1:n_stati
        sum=sum+U(i,j);
    end
    if sum~=1
        fprintf("!=== ERRORE ===!\nLa riga %i non ha sommatoria pari a 1. Valore:%.20f\n",i,sum);
    end
end

% Le variabili di appoggio possono ora essere eliminate
clear i j sum;

%% TRASFORMAZIONE DI COORDINATE ===========================================
% Viene associata a ogni marcatura una variabile v, 1 se la marcatura è
% vanishing 0 altrimenti.
for i=1:n_stati
    if ~isempty(Grafo(i).Raggiungibili) && PN.T.Maschera(Grafo(i).Raggiungibili.Transizione(1))
        v(i)=1;
    else
        v(i)=0;
    end
end
fprintf("Le marcature sono %i\n",n_stati);
fprintf(" - %i stati sono vanishing;\n - %i stati sono tangible.\n\n",sum(v),length(v)-sum(v))

% Ordino il vettore degli stati mettendo prima quelli vanishing al fine di
% trovare la matrice di trasformazione di base
[v1,In]=sort(v,'descend');

% Riordino la matrice U
U_riordinata=zeros(size(U));
for i=1:size(U,1)
    for j=1:size(U,2)
        U_riordinata(i,j)=U(In(i),In(j));
    end
end

%% CALCOLO U' =============================================================
num_stati_v = sum(v1);
num_stati_t = n_stati - num_stati_v;
%    V T
% V |C D|
% T |E F|;
C = U_riordinata(            1:num_stati_v,            1:num_stati_v);
D = U_riordinata(            1:num_stati_v,num_stati_v+1:        end);
E = U_riordinata(num_stati_v+1:        end,            1:num_stati_v);
F = U_riordinata(num_stati_v+1:        end,num_stati_v+1:        end);

% Ricerco possibili loop tra le marcature vanishing. Se non trovo alcun
% loop dopo aver al massimo iterato tutte le marcature vanishing allora la
% matrice G è già calcolata. Se è presente un loop, G viene calcolata con
% la inversione di matrice.
C_temp=eye(num_stati_v,num_stati_v);
G_temp=C_temp;
loop=true;
for k=1:num_stati_v+1
   C_temp = C_temp*C;
   if C_temp==zeros(num_stati_v,num_stati_v)
       loop=false;
       fprintf("Non è presente alcun loop tra le marcature vanishing. Il " + ...
           "calcolo di G viene effettuatto attraverso la sommatoria.\n\n");
       G=G_temp;
       break;
   end
   G_temp=G_temp+C^k;
end
if loop
    fprintf("È presente un loop  tra le marcature vanishing. Il calcolo di" + ...
        " G viene effettuato attraverso l'inversione di matrice\n\n");
    G=inv(eye(num_stati_v,num_stati_v)-C);
end

% La matrice delle probabilità ridotta è così calcolata
U1=F+E*G*D;

%% CALCOLO PROPRIETÀ =============================================
%__PERIODICITÀ_____________________________________________________________
U_temp=eye(num_stati_t);
for i=1:n_stati*2
    U_temp=U_temp*U1;
    for j=1:size(U_temp,1)
        if U_temp(j,j)>0
            p_ric(j,i)=1;
        else 
            p_ric(j,i)=0;
        end
    end
end
p_ric = unique(p_ric,'rows');
for j=1:size(p_ric,1)
    idxs = sym(find(p_ric(j,:)==1));
    periodo(j) = gcd(idxs); 
end
if any(periodo==1)
    fprintf("Il sistema tangible è aperiodico.\n");
elseif all(periodo~=0)
    temp = unique(periodo);
    fprintf("Il sistema tangible è periodico, il periodo degli stati è: %i\n",temp);
end
fprintf("\n");

%__IRRIDUCIBILITÀ__________________________________________________________
U_temp=eye(num_stati_t);
connesso_a_M0=zeros(num_stati_t,1);
for i=1:num_stati_t
    U_temp=U_temp*U1;
    connesso_a_M0(U_temp(:,1)~=0)=1;
end
if sum(connesso_a_M0)==num_stati_t
    fprintf("Il sistema tangible è irriducibile.\n\n");
else
    fprintf("Il sistema tangible è riducibile, sono presenti almeno 2 classi di comunicazione.\n\n");
end

%__RICORRENZA______________________________________________________________
% precisione_ricorrenza=0.99;
% f_i=zeros(num_stati_t,1);
% f_ok=false(num_stati_t,1);
% for i=1:num_stati_t
%     contatore=0;
%     U_temp=eye(num_stati_t);
%     while ~f_ok(i)
%         U_temp=U_temp*U1;
%         contatore=contatore+1;
%         f_i(i)=f_i(i)+U_temp(i,i);
%         U_temp(i,i)=0;
%         if f_i(i)>=precisione_ricorrenza
%             f_ok(i)=true;
%             fprintf("Lo stato %i ha probabilità maggiore di %f di tornare in %i in esattamente %i passi.\n",i,precisione_ricorrenza,i,contatore);
%         end
%     end
% end
%
% if all(f_ok==true)
%     fprintf("Tutti gli stati del sistema sono ricorrenti.\n\n");
% else
%     fprintf("Non tutti gli stati del sistema sono ricorrenti.\n\n");
% end

%__VALORI A REGIME_________________________________________________________
% Se il sistema è irriducibile e riccorrente positivo allora esiste la
% probabilità a regime
Y_sym = sym('y1_',[1 num_stati_t],'real');
equations= Y_sym.'==U1*(Y_sym.');
Y_struct=solve([equations; sum(Y_sym)==1],Y_sym);
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

%__TEMPI DI SOGGIORNO______________________________________________________
for i=1:(num_stati_t)
    lambda=0;
    for k=1:height(Grafo(In(num_stati_v+i)).Raggiungibili)
        idMarcatura=In(num_stati_v+i);
        id_t_temp=Grafo(idMarcatura).Raggiungibili.Transizione(k);
        lambda=lambda+PN.T.Rate(id_t_temp)*ServerAttivati(Grafo(idMarcatura).Iniziale,PN.T.Server(id_t_temp),PN.Pre(:,id_t_temp));
    end
    m(i,1)=1/lambda;
end

fprintf("\n" + ...
    "______________________________________________________________________________\n" + ...
    "I tempi di soggiorno sono:\n")
for i=1:length(m)
    fprintf("Lo stato [%s] (%i) ha tempo di soggiorno: %s;\n", num2str(Grafo(i).Iniziale'),In(i),duration(hours(m(i)),'format','hh:mm:ss.SSSS'));
end

%__PROBABILITÀ A REGIME____________________________________________________
PI=[];
for i=1:length(Y)
    PI(i,1)=(Y(i)*m(i))/sum(Y.*m);
end

fprintf("\n" + ...
    "______________________________________________________________________________\n" + ...
    "Le probabilità a regime sono:\n")
for i=1:length(PI)
    fprintf("Lo stato [%s] (%i) ha probabilità a regime: %.10f;\n", num2str(Grafo(i).Iniziale'),In(i),PI(i));
end

%% INDICI DI PRESTAZIONE ==================================================
fprintf("\n\n=========== INDICI DI PRESTAZIONE ============================================")
%__THROUGHPUT______________________________________________________________
% Il throughput è il reciproco del tempo di produzione per unità di
% prodotto. La reward function r è ottenuta moltiplicando il rate della
% transizione temporizzata per il numero di server attivati. Il throughput
% della transizione k-esima è dato dalla somma delle reward function
% moltiplicate per le probabilità a regime.
for k=1:height(PN.T)
r=zeros(num_stati_t,1);
    for i=1+num_stati_v:(n_stati)
        if ismember(k,Grafo(In(i)).Raggiungibili.Transizione)
            r(i-num_stati_v)=PN.T.Rate(k)*ServerAttivati(Grafo(In(i)).Iniziale,PN.T.Server(k),PN.Pre(:,k));
        end
    end
    tp(k)=sum(r.*PI);
end
fprintf("\nTPU] Il throughput del sistema analizzato è pari a:\n");
for i=1:height(PN.T)
    fprintf("    %s%s%.4f\n",PN.T.Transizione{i},repmat(' ',1,TAB-length(char(PN.T.Transizione{i}))),tp(i));
end

%__NUMERO MEDIO DI TOKEN___________________________________________________
% Per ogni posto k-esimo viene calcolato il numero medio di token associato
% al posto. Esso viene calcolato sommando il prodotto tra le probabilità a
% regime che il sistema si trovi in quella marcatura e il numero di token
% nel posto k-esimo
for k=1:length(PN.P)
    r=zeros(num_stati_t,1);
    for i=1+num_stati_v:(n_stati)
        r(i-num_stati_v)=Grafo(In(i)).Iniziale(k);
    end
    numero_medio_token(k)=sum(r.*PI);
end
fprintf("\nNMT] Il numero medio di token è pari a:\n");
for i=1:length(numero_medio_token)
    fprintf("    %s%s%.4f\n",PN.P(i),repmat(' ',1,TAB-length(char(PN.P(i)))),numero_medio_token(i));
end

%__WIP_____________________________________________________________________
% Il Work in Process è dato dalla somma del numero medio di token
wip=sum(numero_medio_token);
fprintf("\nWIP] Il Work In Process del sistema analizzato è pari a: %.10f pezzi\n",wip);

%__MLT_____________________________________________________________________
% Il Manufacturing Lead Time è stato calcolando facendo il rapporto tra il
% WIP e il throughput minimo (diverso da zero) del sistema
tp_min=0;
for i=1:length(PN.P)
    for j=1:height(PN.T)
        if any(tp(j)~=0) 
            if PN.Pre(i,j)~=0
            tp_min=min(PN.Pre(i,j)*tp(j));
            end
        end
    end
end
MLT=wip/tp_min;
fprintf("\nMLT] Il Manifacturing Lead Time del sistema analizzato è pari a: %s\n",duration(hours(MLT),'format','hh:mm:ss.SSSS'));

%__TEMPO MEDIO ATTESA______________________________________________________
% Il tempo medio di attesa relativo al k-esimo posto è dato dal rapporto 
% tra il numero medio di token del posto e la somma dei throughput relativi
% alle transizioni che depositano token nel posto.
 for k=1:length(PN.P)
     tp_posti=0;
     for j=1:height(PN.T)
         if PN.Post(k,j)>0
             tp_posti=tp_posti+tp(j);
         end
     end
     tempo_medio_attesa(k)=numero_medio_token(k)/tp_posti;
 end
 fprintf("\nTMA] Il tempo medio di attesa per ogni posto è pari a:\n");
for i=1:length(tempo_medio_attesa)
    fprintf("    %s%s%s\n",PN.P(i),repmat(' ',1,TAB-length(char(PN.P(i)))),duration(hours(tempo_medio_attesa(i)),'format','hh:mm:ss.SSSS'));
end

%__EFFICENZA_______________________________________________________________
% L'efficienza di un dato macchinario è dato dalla somma delle probabilità
% a regime di ciascuna marcatura moltiplicate per il rapporto tra il numero
% di server in lavorazione e i server totali.
for i_macc=1:height(Macchinari)
    if Macchinari.DaAnalizzare(i_macc)
        posti_macc=Macchinari.Posti{i_macc};
        trans_macc=Macchinari.Transizioni{i_macc};
        if ~isempty(trans_macc)
            trans_macc=mod(find(trans_macc==PN.T.Transizione),height(PN.T));
            trans_macc=trans_macc(trans_macc~=0);
            trans_temp=trans_macc(PN.T.Maschera(trans_macc)==0);
            if ~isempty(trans_macc)
                server_totali = sum(PN.T.Server(trans_temp));
                for i_marc=num_stati_v+1:n_stati
                    server_in_lavorazione=0;
                    for t=1:length(trans_temp)
                        server_in_lavorazione=server_in_lavorazione+ServerAttivati(Grafo(In(i_marc)).Iniziale,PN.T.Server(trans_temp(t)),PN.Pre(:,trans_temp(t)));
                    end
                    eff_marc(i_marc-num_stati_v)=PI(i_marc-num_stati_v)*server_in_lavorazione/server_totali;
                end
                eff_mac(i_macc,:)=table(Macchinari.Macchinario(i_macc),sum(eff_marc),'VariableNames',["Macchinario","Efficenza"]);
            end
        end
    end
end
eff_mac=rmmissing(eff_mac);
fprintf("\nEFF] L'efficenza del sistema analizzato è pari a:\n");
for i_eff=1:height(eff_mac)
    nome=eff_mac{i_eff,1};
    fprintf("    %s%s%.4f\n",nome,repmat(' ',1,TAB-length(char(nome))),eff_mac{i_eff,2});
end

 %% Functions =============================================================
function s_a = ServerAttivati(Marcatura,MaxServer,Input)
    s_a = min(Marcatura./Input);
    if s_a>MaxServer
        s_a=MaxServer;
    end
end






