clear all
clc 
versione=1;
codice_macchinario=2;
PN=load(sprintf('Parti_v%i/PN_M%i.mat',versione, codice_macchinario));
token.init=2;
token.ending=4;
token.delta=1;
rate_in=268.3662;
rate_out=134.1820;
Precisione.U  = 5;
Precisione.U1 = 5;
log=2;
plot_tp=Calcolo_Iterativo_PN_Grafo(versione,PN,codice_macchinario,token,rate_in,rate_out,Precisione,log);

figure
plot(token.init:token.delta:token.ending, plot_tp(:,1), token.init:token.delta:token.ending, plot_tp(:,2))
figure
plot(token.init:token.delta:token.ending, plot_tp(:,1)/rate_in*100, token.init:token.delta:token.ending, plot_tp(:,2)/rate_out*100)
