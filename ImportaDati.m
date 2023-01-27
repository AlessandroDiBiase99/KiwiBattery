function [Pre,Post,Combinazione,Inibizione,M0,Posti,Transizioni]=ImportaDati(file,sheet)
    
    T=readtable(file,'sheet',sheet,'DataRange','A:A');

    riga1 = find(string(T.PetriNetIncidenceAndMarking)=='Forwards incidence matrix I+');

    riga2 = find(string(T.PetriNetIncidenceAndMarking)=='Backwards incidence matrix I-');

    riga3 = find(string(T.PetriNetIncidenceAndMarking)=='Combined incidence matrix I');

    riga4 = find(string(T.PetriNetIncidenceAndMarking)=='Inhibition matrix H');

    riga5 = find(string(T.PetriNetIncidenceAndMarking)=='Marking');

    riga6 = find(string(T.PetriNetIncidenceAndMarking)=='Enabled transitions');

    Post        = readtable('MatriciCalcolate.xlsx','sheet','7_T_S','DataRange',[num2str(riga1+1),':',num2str(riga2-1)]);
    Post = SistemaTabella(Post);
    
    Pre         = readtable('MatriciCalcolate.xlsx','sheet','7_T_S','DataRange',[num2str(riga2+1),':',num2str(riga3-1)]);
    Pre = SistemaTabella(Pre);

    Combinazione= readtable('MatriciCalcolate.xlsx','sheet','7_T_S','DataRange',[num2str(riga3+1),':',num2str(riga4-1)]);
    Combinazione = SistemaTabella(Combinazione);
    
    Inibizione  = readtable('MatriciCalcolate.xlsx','sheet','7_T_S','DataRange',[num2str(riga4+1),':',num2str(riga5-1)]);
    Inibizione = SistemaTabella(Inibizione);
    
    M0          = readtable('MatriciCalcolate.xlsx','sheet','7_T_S','DataRange',[num2str(riga5+1),':',num2str(riga6-1)]);
    M0 = SistemaTabella(M0);

    Transizioni = string(Post.Properties.VariableNames);
    Posti = string(Post.Var1);

    Post=2matrix(Post);
%     TransizioniPost = string(Post.Properties.VariableNames);
%     TransizioniPre = string(Pre.Properties.VariableNames);
%     TransizioniCombinazione = string(Combinazione.Properties.VariableNames);
%     TransizioniInibizione = string(Inibizione.Properties.VariableNames);
%     if all(TransizioniPost==TransizioniPre & TransizioniPost==TransizioniCombinazione &TransizioniPost==TransizioniInibizione)
%         fprintf('Le transizioni hanno lo stesso ordine\n');
%     end
%     PostiPost = upper(strtrim(string(Post.Var1)));
%     PostiPre = upper(strtrim(string(Pre.Var1)));
%     PostiCombinazione = upper(strtrim(string(Combinazione.Var1)));
%     PostiInibizione = upper(strtrim(string(Inibizione.Var1)));
%     PostiM0 = upper(strtrim(string(M0(:,2:end).Properties.VariableNames)))';
%     if all(PostiPost==PostiPre & PostiPost==PostiCombinazione & PostiPost==PostiInibizione & PostiPost==PostiM0)
%         fprintf('I posti hanno lo stesso ordine\n');
%     end
end

function tabella1 = SistemaTabella(tabella)
    tabella1 = tabella(2:end,:);
    tabella1=rmmissing(tabella1,2);
end
function 2matrix