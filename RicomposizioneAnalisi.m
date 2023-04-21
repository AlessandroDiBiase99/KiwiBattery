close;clear;clc;
IP=table();
IP1=load('Dati\IndiciPrestazione_{1,2,3,4}.mat');
IP1=IP1.IndiciPrestazione;
IP(1,:)=[{IP1.Transizioni} {IP1.Posti} {IP1.Macchinari} IP1.WIP {IP1.MLT} IP1.TPU_Sistema];
IP2=load('Dati\IndiciPrestazione_{5,6}.mat');
IP2=IP2.IndiciPrestazione;
IP(2,:)=[{IP2.Transizioni} {IP2.Posti} {IP2.Macchinari} IP2.WIP {IP2.MLT} IP2.TPU_Sistema];
IP3=load('Dati\IndiciPrestazione_{8,9,10}.mat');
IP3=IP3.IndiciPrestazione;
IP(3,:)=[{IP3.Transizioni} {IP3.Posti} {IP3.Macchinari} IP3.WIP {IP3.MLT} IP3.TPU_Sistema];
IP4=load('Dati\IndiciPrestazione_{11,12,13}.mat');
IP4=IP4.IndiciPrestazione;
IP(4,:)=[{IP4.Transizioni} {IP4.Posti} {IP4.Macchinari} IP4.WIP {IP4.MLT} IP4.TPU_Sistema];
IP.Properties.VariableNames=["Transizioni"; "Posti"; "Macchinari"; "WIP"; "MLT"; "TPU"];
clear IP1 IP2 IP3 IP4;

PN=load('Dati\PN_Configurazione2.mat');
PN=PN.PN;
Post=PN.Completa.Post;

%% TRANSIZIONI ============================================================
Table_T=table();
Table_T.Macchinario=zeros(length(PN.Completa.T.Transizione),1);
Table_T.Transizione=PN.Completa.T.Transizione;
Table_T.TPU_old=zeros(length(PN.Completa.T.Transizione),1);
Table_T.TPU_new=zeros(length(PN.Completa.T.Transizione),1);
Table_T.N_tok  =zeros(length(PN.Completa.T.Transizione),1);

mac=1;
for i=1:height(PN.Macchinari)
    trans=PN.Macchinari.Transizioni{i};
    if ~isempty(trans)
        for j=1:length(trans)
            Table_T.Macchinario(Table_T.Transizione==trans(j))=mac;
        end
        mac=mac+1;
    end
end
Table_T=sortrows(Table_T,1);
clear mac trans;

for i=1:height(IP)
    temp=IP.Transizioni{i};
    for j=1:height(temp)
        Table_T.TPU_old(Table_T.Transizione==temp.Transizione(j))=temp.TPU(j);
    end
end
for i=1:height(Table_T)
    Table_T.N_tok(i)=sum(PN.Completa.Post(:,find(PN.Completa.T.Transizione==Table_T.Transizione(i))));
end
Table_T.temp=Table_T.TPU_old.*Table_T.N_tok;
clear i temp j;

% INIZIO - PRIMO TEST
first = 1;
last  = find(Table_T.Macchinario<5,1,"last");
Table_T_1S=[Table_T(first:last,:);Table_T(Table_T.Transizione=="M5Test",:)];
TPU_REF=min(Table_T_1S.temp(Table_T_1S.temp~=0));
riga=first;
while Table_T.Macchinario(riga)<5
    Table_T.TPU_new(riga)=Table_T.TPU_old(riga)*TPU_REF/Table_T.temp(riga);
    riga=riga+1;
end
fattore=TPU_REF/Table_T.temp(Table_T.Transizione=="M5Test");
while Table_T.Macchinario(riga)==5
    Table_T.TPU_new(riga)=Table_T.TPU_old(riga)*fattore;
    riga=riga+1;
end
clear Table_T_1S;

% PRIMO TEST - SECONDO TEST
first=find(Table_T.Macchinario==6,1,"first");
last=find(Table_T.Macchinario<11,1,"last");
Table_T_2S=[Table_T(Table_T.Transizione=="TP1OK",:);Table_T(first:last,:);Table_T(Table_T.Transizione=="M11Test",:)];
Table_T_2S.temp(1)=Table_T_2S.TPU_new(1);
TPU_REF=min(Table_T_2S.temp(Table_T_2S.temp~=0));
riga=first;
fattore=TPU_REF/Table_T.temp(Table_T.Transizione=="ScaricamentoM6");
while Table_T.Macchinario(riga)==6
    Table_T.TPU_new(riga)=Table_T.TPU_old(riga)*fattore;
    riga=riga+1;
end
while Table_T.Macchinario(riga)<11
    Table_T.TPU_new(riga)=Table_T.TPU_old(riga)*TPU_REF/Table_T.temp(riga);
    riga=riga+1;
end
fattore=TPU_REF/Table_T.temp(Table_T.Transizione=="M11Test");
while Table_T.Macchinario(riga)==11
    Table_T.TPU_new(riga)=Table_T.TPU_old(riga)*fattore;
    riga=riga+1;
end
clear Table_T_2S;

% SECONDO TEST - FINE
Table_T.TPU_new(end-1:end)=Table_T.TPU_new(end-2);
clear first last riga fattore TPU_REF

Table_T=Table_T(:,1:4);
INDICI_TPU_TOT=Table_T.TPU_new(end);

%% POSTI ==================================================================
Table_P=table();
Table_P.Macchinario=zeros(length(PN.Completa.P),1);
Table_P.Posto=PN.Completa.P;
Table_P.PerWIP=PN.ImpostazioniIndici.Tabella_WIP.DaConsiderare;

mac=1;
for i=1:height(PN.Macchinari)
    pos=PN.Macchinari.Posti{i};
    if ~isempty(PN.Macchinari.Transizioni{i})
        for j=1:length(pos)
            Table_P.Macchinario(Table_P.Posto==pos(j))=mac;
        end
        mac=mac+1;
    end
end
clear i j mac pos;
Table_P=sortrows(Table_P,1);

% Come cambiano le probabilità a regime?
Table_P.NumeroMedioToken(:) = zeros(height(Table_P),1);
for k=1:height(Table_P)
%     r=zeros(n.stati_t,1);
%     for i=1+n.stati_v:(n.stati)
%         r(i-n.stati_v)=Grafo(OrdineV_T(i)).Iniziale(k);
%     end
%     numero_medio_token(k)=sum(r.*PI);
end
clear k;

INDICI_WIP=sum(Table_P.NumeroMedioToken.*Table_P.PerWIP);
INDICI_MLT=INDICI_WIP/INDICI_TPU_TOT;

Table_P.TempoMedioAttesa(:) = zeros(height(Table_P),1);
for k=1:height(Table_P)
     tp_posti=0;
     for j=1:height(Table_T)
         if Post(k,j)>0
             tp_posti=tp_posti+Table_T.TPU_new(j)*Post(k,j);
         end
     end
     tempo_medio_attesa(k)=Table_P.NumeroMedioToken(k)/tp_posti;
end
clear k j;