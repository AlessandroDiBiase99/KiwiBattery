function VisualizzaGrafo(Grafo)
figure;
disponibile=[0];
printed=table(0,0,0,'VariableNames',[{'Nodo'},{'x'},{'y'}]);
printNodo(0,disponibile,1,Grafo,printed);

plot(0,0,'o');


Grafo(1).Raggiungibili.Marcatura
for i=1:length(Grafo)
    for j=1:height(Grafo(i).Raggiungibili)
        
    end
end

treeplot(p);
[x,y] = treelayout(p);
texts=[array2string(Grafo(p(1)+1).Iniziale)];
for i=2:length(p)
    texts=[texts {array2string(Grafo(p(i)+1).Iniziale)}];
end
text(x + 0.002,y,texts);
end

function s=array2string(array)
    s='[';
    for i=1:length(array)-1
        s=[s,' ',num2str(array(i)),','];
    end
    s=[s,' ',num2str(array(end)), ']'];
end

function printNodo(livello, disponibile, nodo, grafo,printed)
temp=table2array(printed);
if ~ismember(nodo,temp(:,1))
    if length(disponibile)<livello+1
        disponibile(livello+1)=0;
    end
    x=disponibile(livello+1);
    disponibile(livello+1)=x+1;
    fprintf('x: %i; y:%i;\n',x,livello);
    plot(x,-livello,'o','Color','black');
    hold on;
    printed(height(printed)+1,:)=table(nodo,x,-livello);
    for i=1:height(grafo(nodo).Raggiungibili)
        printNodo(livello+1,disponibile,grafo(nodo).Raggiungibili.Marcatura(i),grafo,printed);
    end
end
end