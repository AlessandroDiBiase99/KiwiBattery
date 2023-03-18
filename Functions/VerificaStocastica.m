function M = VerificaStocastica(M,Precisione)

M=round(M,Precisione);  

Ricalcolo_M = table(-1,{-1},'VariableNames',["SUM" "Riga"]);
Errore_M    = [];

for i=1:size(M,1)
    sum_= sum(M(i,:));
    if sum_~=1
        primo_non_vuoto=find(M(i,:)~=0 & M(i,:)>sum(M(i,:))-1,1);
        M(i,primo_non_vuoto)=0;
        M(i,primo_non_vuoto)=1-sum(M(i,:));
        id=find(sum_==Ricalcolo_M.SUM);
        if isempty(id)
            Ricalcolo_M(end+1,:)=table(sum_,{i});
        else
            Ricalcolo_M.Riga(id)={[Ricalcolo_M.Riga{id} i]};
        end
    end
    if sum(M(i,:))~=1
        Errore_M=[Errore_M i];
    end
end
if height(Ricalcolo_M)>1
    fprintf("!=== ATTENZIONE ===!\nEseguite le correzioni automatiche dell'arrotondamento:\n");
    Ricalcolo_M=Ricalcolo_M(2:end,:);
    for i=1:height(Ricalcolo_M)
        fprintf("Sommatoria ottenuta: %1$.*2$f sulle righe: %3$s\n",Ricalcolo_M.SUM(i),Precisione,array2string(Ricalcolo_M.Riga{i}));
    end
    fprintf("\n");
end
if ~isempty(Errore_M)
    fprintf("!=== ERRORE ===!\nLa precisione specificata è troppo elevata. Si suggerisce di abbassarla. Righe:%s\n\n",array2string(Errore_M));
end
end

