function VisualizzaGrafo(Grafo,T)
% VisualizzaGrafo è una funzione che permette di visualizzare graficamente
% il grafo di raggiungibilità realizzato. Per ogni stato si crea un nodo, e
% si creano archi rivolti verso i nuovi nodi che saranno posizionati sempre
% al di sotto. Se si deve tornare a uno stato già esistente si crea un arco
% rivolto verso il nodo associato, nella stessa riga o nelle righe
% superiori. Si stampa anche lo stato associato al nodo e la transizione
% che permette di cambiare stato.
% 
% INPUT:
%    - Grafo:
%      il grafo di raggiungibilità determinato. 
%    - T:
%      il vettore che contiene il nome delle transizioni per inserire le
%      etichette corrette.
% 
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Creo la figura
figure;

% Stampo la marcatura iniziale con la sua etichetta
plot(1,-1,'o','Color','black');
text(1.02,-0.9,array2string(Grafo(1).Iniziale));
hold on;

% Condizione boolenana per sapere se ho finito di esaminare il grafo
almeno1=true;
printed=[1];

% Mi abbasso di livello
y=2;
xMax=0.1;
while almeno1
    % Il livello "padre" che deve generare il livello "figlio"
    thislevel=printed(y-1,:);
    almeno1=false;
    x=1;
    % Seleziono ogni nodo del livello "padre"
    for j=1:length(thislevel)
        nodo=thislevel(j);
        % Se il nodo ha indice non nullo, quindi corrisponde a uno stato
        if nodo>0
            % Se i nodi del livello "figlio" creati finora mi allineo al
            % padre lasciando i buchi
            if x<j
                x=j;
            end
            % Per ogni stato raggiungibile creo un nodo nel livello
            % "figlio" e lo inserisco nel plot, mettendo etichetta al nuovo
            % nodo e all'arco che unisce i nodi
            for i=1:height(Grafo(nodo).Raggiungibili)
                % Se lo stato non è mai stato esplorato
                if ~ismember(Grafo(nodo).Raggiungibili.Marcatura(i),printed)
                    % NODO
                    plot(x,-y,'o','Color','black');
                    txt=array2string(Grafo(Grafo(nodo).Raggiungibili.Marcatura(i)).Iniziale);
                    text(x + 0.02,-y,txt);

                    % ARCO
                    plot([j x],[-y+1 -y],'-','Color','black');
                    text((x+j)/2,-y+1/2,T(Grafo(nodo).Raggiungibili.Transizione(i)));
                    
                    % inserisco il nodo nella matrice per considerarlo nel
                    % prossimo livello, sposto la x per mettere il prossimo
                    % nodo sullo stesso livello, ma distanziato
                    printed(y,x)=Grafo(nodo).Raggiungibili.Marcatura(i);
                    x=x+1;

                    % Verifico se la x massima raggiunta è incrementata
                    if x>xMax
                        xMax=x;
                    end
                    
                    % C'è almeno uno stato nuovo da espandere
                    almeno1=true;
                % Se lo stato è stato già esplorato
                else
                    % ARCO
                    [r,c]=find(printed==Grafo(nodo).Raggiungibili.Marcatura(i));
                    x1=j; y1=-y+1;
                    x2=c; y2=-r;
                    
                    txt=T(Grafo(nodo).Raggiungibili.Transizione(i));
                    % Sistemo graficamente l'arco affinchè non si accavalli
                    % con quelli già esistenti
                    if(y2==y1-1)
                        plot([x1 x2],[y1 y2],'Color','black');
                        text((x1+x2)/2,(y1+y2)/2,txt,'Color','black');
                    else
                        x2=x2-0.1;
                        y2=y2+0.05;
                        plot([x1 x2],[y1 y2],'Color','red');
                        plot(x2,y2,'>r');
                        text((x1+x2)/2,(y1+y2)/2,txt,'Color','red');
                    end

                end
            end
        end
    end
    y=y+1;
end
xlim([0 xMax]);
ylim([-y 1]);
end