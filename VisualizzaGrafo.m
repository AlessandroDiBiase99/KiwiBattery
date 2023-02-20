function VisualizzaGrafo(Grafo,T)
figure;
plot(1,-1,'o','Color','black');
text(1.02,-0.9,array2string(Grafo(1).Iniziale));
hold on;
almeno1=true;
printed=[1];
y=2;
xMax=0;
while almeno1
    thislevel=printed(y-1,:);
    almeno1=false;
    x=1;
    for j=1:length(thislevel)
        nodo=thislevel(j);
        if nodo>0
            if x<j
                x=j;
            end
            for i=1:height(Grafo(nodo).Raggiungibili)
                if ~ismember(Grafo(nodo).Raggiungibili.Marcatura(i),printed)
                    plot(x,-y,'o','Color','black');
                    txt=array2string(Grafo(Grafo(nodo).Raggiungibili.Marcatura(i)).Iniziale);
                    text(x + 0.02,-y,txt);

                    plot([j x],[-y+1 -y],'-','Color','black');
                    text((x+j)/2,-y+1/2,T(Grafo(nodo).Raggiungibili.Transizione(i)));
                    
                    printed(y,x)=Grafo(nodo).Raggiungibili.Marcatura(i);
                    x=x+1;
                    if x>xMax
                        xMax=x;
                    end
                    almeno1=true;
                else
                    [r,c]=find(printed==Grafo(nodo).Raggiungibili.Marcatura(i));
                    x1=j; y1=-y+1;
                    x2=c; y2=-r;
                    
                    txt=T(Grafo(nodo).Raggiungibili.Transizione(i));
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

function s=array2string(array)
    s='[';
    for i=1:length(array)-1
        s=[s,' ',num2str(array(i)),','];
    end
    s=[s,' ',num2str(array(end)), ']'];
end