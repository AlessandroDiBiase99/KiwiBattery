clear all;
clc;
addpath("Dati\");

macchinari='1,2,3,4';

load(['IndiciPrestazione_{',macchinari,'}'],'IndiciPrestazione')

if ~isduration(IndiciPrestazione.MLT)
    IndiciPrestazione.MLT=hours(IndiciPrestazione.MLT);
end

fprintf("Throughput\n" + ...
    "\\begin{table}[H]\n" + ...
    "\t\\centering\n" + ...
    "\t\\begin{tabular}{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Transizione} & \\textbf{Troughput}\\\\\n"+...
    "\\hline\t\n");
for i=1:height(IndiciPrestazione.Transizioni)
    t=check(IndiciPrestazione.Transizioni.Transizione(i));
    tpu=num2str(IndiciPrestazione.Transizioni.TPU(i));
    fprintf("\t%s & %s\\\\\n",t,tpu);
end
fprintf("\\hline\n"+...
    "\\end{tabular}\n" + ...
    "\\caption{Throughput dei macchinari %s}\n" + ...
    "\\label{tab:TPU%s}\n" + ...
    "\\end{table}\n\n",macchinari,macchinari);

fprintf("Numero medio token\n" + ...
    "\\begin{table}[H]\n" + ...
    "\t\\centering\n" + ...
    "\t\\begin{tabular}{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Posto} & \\textbf{Numero medio Token}\\\\\n"+...
    "\\hline\t\n");
for i=1:height(IndiciPrestazione.Posti)
    p=check(IndiciPrestazione.Posti.Posto(i));
    nmt=num2str(IndiciPrestazione.Posti.NumeroMedioToken(i));
    fprintf("\t%s & %s\\\\\n",p,nmt);
end
fprintf("\\hline\n"+...
    "\\end{tabular}\n" + ...
    "\\caption{Numero medio dei token dei posti dei macchinari %s}\n" + ...
    "\\label{tab:NMT%s}\n" + ...
    "\\end{table}\n\n",macchinari,macchinari);

fprintf("Tempo medio attesa\n" + ...
    "\\begin{table}[H]\n" + ...
    "\t\\centering\n" + ...
    "\t\\begin{tabular}{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Posto} & \\textbf{Tempo medio attesa}\\\\\n"+...
    "\\hline\t\n");
for i=1:height(IndiciPrestazione.Posti)
    p=check(IndiciPrestazione.Posti.Posto(i));
    tma=PrintTime(IndiciPrestazione.Posti.TempoMedioAttesa(i));
    fprintf("\t%s & %s\\\\\n",p,tma);
end
fprintf("\\hline\n"+...
    "\\end{tabular}\n" + ...
    "\\caption{Tempo medio attesa dei posti dei macchinari %s}\n" + ...
    "\\label{tab:TMA%s}\n" + ...
    "\\end{table}\n\n",macchinari,macchinari);

fprintf("Efficenza macchinari\n" + ...
    "\\begin{table}[H]\n" + ...
    "\t\\centering\n" + ...
    "\t\\begin{tabular}{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Macchinario} & \\textbf{Efficenza}\\\\\n"+...
    "\\hline\t\n");
for i=1:height(IndiciPrestazione.Macchinari)
    m=check(IndiciPrestazione.Macchinari.Macchinario(i));
    eff=num2str(IndiciPrestazione.Macchinari.Efficenza(i));
    fprintf("\t%s & %s\\%%\\\\\n",m,eff);
end
fprintf("\\hline\n"+...
    "\\end{tabular}\n" + ...
    "\\caption{Efficenza dei macchinari %s}\n" + ...
    "\\label{tab:EFF%s}\n" + ...
    "\\end{table}\n\n",macchinari,macchinari);

fprintf("Il throughput di sistema è: %.4f\n" + ...
    "Il WIP di sistema è: %.4f\n" + ...
    "Il MLT di sistema è: %s\n\n",IndiciPrestazione.WIP/hours(IndiciPrestazione.MLT),IndiciPrestazione.WIP,PrintTime(IndiciPrestazione.MLT));

clear t p m tpu nmt tma eff;

function stringa=check(testo)
    stringa = strrep(testo,"_","\_");
end
function stringa=PrintTime(durata)
    stringa = sprintf("%s",duration(durata,"format","mm:ss.SSSS"));
end