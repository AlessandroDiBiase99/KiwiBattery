%% PREPARAZIONE WORKSPACE__________________________________________________
clear all;
clc;
addpath("Functions\")

%% IMPOSTAZIONI____________________________________________________________
versione=1;
codice_macchinario=2;
PN=load(sprintf('Parti_v%i/PN_M%i.mat',versione, codice_macchinario));

token.init=2;
token.ending=15;
token.delta=1;

Impostazioni.Precisione.U  = 5;
Impostazioni.Precisione.U1 = 5;
Impostazioni.log=0;
Impostazioni.RecuperoGrafo="Si";

rate_in=[255.5333, 268.3663, 134.4334, 267.9495, 267.9409, 200.9588, 200.9595, 3.1400, 100.4797, 100.4803, 200.9624, 100.4799];
rate_out=[253.5367, 134.1820, 268.8662, 267.9480, 200.9588, 200.9595, 3.1400, 100.4797, 100.4806, 200.9627, 100.4811, 90.4316];

soglia=0.90;

%% CALCOLO ITERATIVO_______________________________________________________
plot_tp=Calcolo_Iterativo_PN_Grafo(versione,PN,codice_macchinario,token,rate_in(codice_macchinario),rate_out(codice_macchinario),Impostazioni);
cerca=find(plot_tp(:,2)/rate_out(codice_macchinario)>=soglia,1,'first');
if ~isempty(cerca)
   trova_token=(cerca-1)*token.delta+token.init;
end
%% PLOT
figure
plot(token.init:token.delta:token.ending, plot_tp(:,1), token.init:token.delta:token.ending, plot_tp(:,2))
figure
a=[trova_token, token.ending];
b=[soglia*100,soglia*100];
area(a,b,100,'FaceColor','green','FaceAlpha',0.3,'LineStyle','none')
hold on
plot(token.init:token.delta:token.ending, plot_tp(:,1)/rate_in(codice_macchinario)*100, token.init:token.delta:token.ending, plot_tp(:,2)/rate_out(codice_macchinario)*100,'Color','r')
hold on
xline(trova_token,'-.')
yline(soglia*100,'-.')
hold on
plot(trova_token, plot_tp(cerca,2)/rate_out(codice_macchinario)*100,'*','Color','b')