function PrintResultForLatex(versione, nome)
% PrintResultForLatex è una funzione per stampare gli indici di prestazione
% risultanti su tabelle formattate in latex.
%
% INPUT:
%    - versione:
%      la versione da analizzare.
%    - nome:
%      il nome del file da dove estrapolare i risultati.
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Stampo l'intestazione
fprintf("\n\n|_=_=_=_=_=_=_=_=_=_=_=_=_=_=__LATEX TEXT__=_=_=_=_=_=_=_=_=_=_=_=_=_=_|\n\n");

% Carico il file
IndiciPrestazione=load(nome);

% Verifico che non ci siano dubplicati, e che il tempo sia correttamente
% formattato
IndiciPrestazione.Transizioni=RemoveDuplicate(IndiciPrestazione.Transizioni);
IndiciPrestazione.EFF=RemoveDuplicate(IndiciPrestazione.EFF);
if ~isduration(IndiciPrestazione.MLT)
    IndiciPrestazione.MLT=hours(IndiciPrestazione.MLT);
end

% Stampa dei dati
fprintf("Throughput\n" + ...
    "\\begin{longtabu}[H]{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Transizione} & \\textbf{Troughput}\\\\\n"+...
    "\\hline \\endhead\n"+...
    "\\hline \\endfoot\n"+...
    "\\endlastfoot\n");
for i=1:height(IndiciPrestazione.Transizioni)
    t=check(IndiciPrestazione.Transizioni.Transizione(i));
    tpu=num2str(IndiciPrestazione.Transizioni.TPU(i));
    fprintf("\t%s & %s\\\\\n",t,tpu);
end
fprintf("\\hline\n"+...
    "\\caption{Throughput dei macchinari %i}\n" + ...
    "\\label{tab:TPU%i}\n" + ...
    "\\end{longtabu}\n\n",versione,versione);

fprintf("Numero medio token\n" + ...
    "\\begin{longtabu}[H]{|c|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Posto} & \\textbf{Numero medio Token}& \\textbf{Tempo medio attesa}\\\\\n"+...
    "\\hline \\endhead\n"+...
    "\\hline \\endfoot\n"+...
    "\\endlastfoot\n");
for i=1:height(IndiciPrestazione.Posti)
    p=check(IndiciPrestazione.Posti.Posto(i));
    nmt=num2str(IndiciPrestazione.Posti.NumeroMedioToken(i));
    tma=PrintTime(IndiciPrestazione.Posti.TempoMedioAttesa(i));
    fprintf("\t%s & %s & %s\\\\\n",p,nmt,tma);
end
fprintf("\\hline\n"+...
    "\\caption{Numero medio dei token dei posti dei macchinari %i}\n" + ...
    "\\label{tab:NMT%i}\n" + ...
    "\\end{longtabu}\n\n",versione,versione);

fprintf("Efficenza macchinari\n" + ...
    "\\begin{longtabu}[H]{|c|c|}\n" + ...
    "\\hline\n"+...
    "\\textbf{Macchinario} & \\textbf{Efficenza}\\\\\n"+...
    "\\hline \\endhead\n"+...
    "\\hline \\endfoot\n"+...
    "\\endlastfoot\n");
for i=1:height(IndiciPrestazione.EFF)
    m=check(IndiciPrestazione.EFF.Macchinario(i));
    test_m=char(m);
    if test_m(1)~='N'
        eff=num2str(IndiciPrestazione.EFF.Efficienza(i));
        fprintf("\t%s & %s\\%%\\\\\n",m,eff);
    end
end
fprintf("\\hline\n"+...
    "\\caption{Efficenza dei macchinari %i}\n" + ...
    "\\label{tab:EFF%i}\n" + ...
    "\\end{longtabu}\n\n",versione,versione);

fprintf("Il throughput di input sistema è: %.4f\\\\\n" + ...
    "Il throughput di output sistema è: %.4f\\\\\n" + ...
    "Il WIP di sistema è: %.4f\\\\\n" + ...
    "Il MLT di sistema è: %s\n\n",IndiciPrestazione.TPU_IN,IndiciPrestazione.TPU_OUT,IndiciPrestazione.WIP,PrintTime(IndiciPrestazione.MLT));

clear t p m tpu nmt tma eff;

%% FUNZIONI________________________________________________________________
    function stringa=check(testo)
        stringa = strrep(testo,"_","\_");
    end
    function stringa=PrintTime(durata)
        stringa = sprintf("%s",duration(durata,"format","mm:ss.SSSS"));
    end
    function tabella=RemoveDuplicate(tabella)
        usedString=[];
        i=1;
        while i<=height(tabella)
            if isempty(usedString) || ~ismember(tabella{i,1},usedString)
                usedString=[usedString; tabella{i,1}];
            else
                tabella(i,:)=[];
            end
            i=i+1;
        end
    end
end