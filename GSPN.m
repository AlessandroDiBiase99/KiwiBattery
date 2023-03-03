%% PREPARAZIONE WORKSPACE ================================================
close all;
clear all;
clc;
format short;
addpath("Functions")

%% PARAMETRI ==============================================================
% Nome del file generato con GestoreAnalisiPN da caricare 
dati_PN = "PN_svuotatrice.mat";
dati_Grafo = "Grafo_svuotatrice.mat";

% Verificare che sia ricorrente positivo con precisione:
precisione_ricorrenza=1; %0.9999;

%% CARICAMENTO DATI =======================================================
info_PN = load(dati_PN);

PN = info_PN.PN.Ridotta;

info_Grafo = load(dati_Grafo);

Grafo=info_Grafo.Grafo;

clear info_PN info_Grafo

[~,num_stati]=size(Grafo);

fprintf("La rete di petri è composta da %i posti e %i transizioni.\n",size(PN.P,1),size(PN.T,1))
fprintf(" - %i transizioni sono immediate;\n - %i transizioni temporizzate.\n\n",sum(PN.T.Maschera==1),sum(PN.T.Maschera==0))
fprintf("Le marcature sono %i\n",num_stati);

%% CALCOLO MATRICE ADIACENZA ==============================================
% Inizializzazione matrice adiacenze per gli stati
A=cell(num_stati,num_stati);
for id1=1:num_stati
    for k=1:height(Grafo(id1).Raggiungibili)
        id2=Grafo(id1).Raggiungibili.Marcatura(k);
        A(id1,id2)={[A{id1,id2} Grafo(id1).Raggiungibili.Transizione(k)]};
    end
end
clear id1 k id2;

%% CALCOLO MATRICE U ======================================================
U=zeros(num_stati,num_stati);

%costruzione della matrice U
for i=1:num_stati
    for j=1:num_stati
        % Se è presente una transizione che porta dallo stato i a j
        if ~isempty(A{i,j})
            % Le transizioni sono:
            a_i_j = A{i,j};

            % Se la prima transizione è immediata, allora tutte lo sono
            if PN.T.Maschera(a_i_j(1))==1
                for t=1:length(a_i_j)
                    % La probabilità è equa
                    u_temp(t)=1/height(Grafo(i).Raggiungibili);
                    % A meno che la transizione non abbia altre probabilità in
                    % conflitto con altre transizioni
                    if PN.T.Peso(a_i_j)>0
                        % Determino il numero di transizioni con probabilità
                        % cambiata in caso di conflitto, e la somma delle
                        % probabilità presenti. Determino il numero di
                        % transizioni abilitate che appartengono alla tabella e
                        % calcolo il peso totale.
                        num=0;
                        peso_tot=0;
                        for h=1:height(Grafo(i).Raggiungibili)
                            if PN.T.Peso(Grafo(i).Raggiungibili.Transizione(h))>0
                                num=num+1;
                                peso_tot=peso_tot+PN.T.Peso(Grafo(i).Raggiungibili.Transizione(h));
                            end
                        end
                        % La probabilità della transizione è pari alla somma
                        % delle probabilità interessate, pesata con il rapporto
                        % tra il peso assegnato alla transizione e le altre
                        % transizioni in conflitto nella tabella q
                        probabilita_tot = num/height(Grafo(i).Raggiungibili);
                        peso = PN.T.Peso(a_i_j);
                        u_temp(t)=probabilita_tot*peso/peso_tot;
                    end
                end
                U(i,j)=sum(u_temp);
                clear u_temp
                % Se è una transizione temporizzata
            else

                % La probabilità è pari al rate della transizione diviso la
                % somma di tutti i rate delle transizioni abilitate
                for t=1:length(a_i_j)
                    rate=PN.T.Rate(a_i_j(t));
                    rate_tot=0;
                    for h=1:height(Grafo(i).Raggiungibili)
                        if PN.T.Maschera(Grafo(i).Raggiungibili.Transizione(h))==0
                            rate_tot=rate_tot+PN.T.Rate(Grafo(i).Raggiungibili.Transizione(h));
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
    if ~isempty(Grafo(i).Raggiungibili) && PN.T.Maschera(Grafo(i).Raggiungibili.Transizione(1))
        v(i)=1;
    else
        v(i)=0;
    end
end

fprintf("Il sistema analizzato presenta %i stati vanishing e %i stati tangible.\n\n",sum(v),length(v)-sum(v))

% Ricavo gli indici degli stati tangible
Index=find(v==1);
% Inizializzo la matrice di cambio di base
T=zeros(num_stati,num_stati);
% Ordino il vettore degli stati mettendo prima quelli vanishing al fine di trovare la matrice di trasformazione di base
[v1,In]=sort(v,'descend');

U_riordinata=zeros(size(U));
for i=1:size(U,1)
    for j=1:size(U,2)
        U_riordinata(i,j)=U(In(i),In(j));
    end
end

%% CALCOLO U' =============================================================
num_stati_vanishing=sum(v1);
%    V T
% V |C D|
% T |E F|;
C = U_riordinata(1:num_stati_vanishing,1:num_stati_vanishing);
D = U_riordinata(1:num_stati_vanishing,num_stati_vanishing+1:end);
E = U_riordinata(num_stati_vanishing+1:end,1:num_stati_vanishing);
F = U_riordinata(num_stati_vanishing+1:end,num_stati_vanishing+1:end);

% trovare loop
C_temp=eye(num_stati_vanishing,num_stati_vanishing);
G_temp=C_temp;
loop=true;
for k=1:num_stati_vanishing
   C_temp = C_temp*C;
   if C_temp==zeros(num_stati_vanishing,num_stati_vanishing)
       loop=false;
       fprintf("Non è presente alcun loop tra le marcature vanishing. Il" + ...
           "calcolo di G viene effettuatto attraverso la sommatoria.\n\n");
       G=G_temp;
       break;
   end
   G_temp=G_temp+C^k;
end
if loop
    fprintf("È presente un loop  tra le marcature vanishing. Il calcolo di" + ...
        " G viene effettuato attraverso l'inversione di matrice\n\n");
    G=inv(eye(num_stati_vanishing,num_stati_vanishing)-C);
end

U1=F+E*G*D;

%% CALCOLO TEMPI DI SOGGIORNO =============================================
% Controllo se il sistema è periodico o aperiodico
U_temp=eye(num_stati);
for i=1:num_stati*2
    U_temp=U_temp*U;
    for j=1:size(U_temp,1)
        if U_temp(j,j)>0
            p_ric(j,i)=1;
        end
    end
end
for j=1:size(U_temp,1)
    idxs = sym(find(p_ric(j,:)==1));
    periodo(j) = gcd(idxs); 
end
if any(periodo==1)
    fprintf("Il sistema è aperiodico.\n");
else
    temp = unique(periodo);
    fprintf("Il sistema è periodico, il periodo degli stati è:%i\n",temp);
end
fprintf("\n");

% Verifico che il sistema sia irriducibile
U_temp=eye(num_stati);
connesso_a_M0=zeros(num_stati,1);
for i=1:num_stati
    U_temp=U_temp*U;
    connesso_a_M0(U_temp(:,1)~=0)=1;
end
if sum(connesso_a_M0)==num_stati
    fprintf("Il sistema è irriducibile.\n\n");
else
    fprintf("Il sistema è riducibile, sono presenti almeno 2 classi di comunicazione.\n\n");
end

% Da perfezionare: devo evitare di calcolare gli arrivi in passi successivi
f_i=zeros(num_stati,1);
f_ok=false(num_stati,1);

% for i=1:num_stati
%     contatore=0;
%     U_temp=eye(num_stati);
%     while ~f_ok(i)
%         U_temp=U_temp*U;
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

% Se il sistema è irriducibile e riccorrente positivo allora esiste la
% probabilità a regime




Y1 = sym('y1_',[1 num_stati-num_stati_vanishing],'real');
equations= Y1==Y1*U1; 

clear eq
for i=1:num_stati-num_stati_vanishing
    eq(i,1) = Y1(i)==Y1*U1(:,i);
end
sommatoria=0;
for i=1:length(Y1)
    sommatoria=sommatoria+Y1(i);
end
eq(end+1,1)=sommatoria==1;
Y2=solve(eq,Y1);
if isstruct(Y2)
    PI=vpa(struct2cell(solve(eq,Y1)));
elseif length(Y2)==1
    PI=Y2;
else
    PI=[];
end
fprintf("Le probabilità a regime sono:\n")
for i=1:length(PI)
    fprintf("Lo stato [%s] (%i) ha probabilità a regime: %.10f;\n", num2str(Grafo(i).Iniziale'),In(i),PI(i));
end

%% INDICI DI PRESTAZIONE ==================================================




% THROUGHPUT
% 
% (Svuotatrice)
% 64 stati: 64 marcature 
% 1 marcatura iniziale M0
% 
% per i=1:stati_tangible
% per j=1:N_transizioni 
% se la transizione è abilitata:
% r(i,j)=rate(i,j)
% altrimenti
% r(i,j)=0
% end
% 
% f(j)=sum(r(:,j))*P(i)
% end
% end





% INDICE DI PRESTAZIONE
    %THROUGHPUT

for k=1:height(PN.T)
r=zeros(num_stati-num_stati_vanishing,1);
    for i=1+num_stati_vanishing:(num_stati)
        if ismember(k,Grafo(In(i)).Raggiungibili.Transizione)
            r(i-num_stati_vanishing)=PN.T.Rate(k);
        end
    end
    tp(k)=sum(r.*PI);
end









