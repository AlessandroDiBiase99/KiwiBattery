function VisualizzaGrafo1(Grafo,T)
figure;
plot(1,-1,'o','Color','black');
text(1.02,-1+0.2,array2string(Grafo(1).Iniziale));
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
                    plot([j x],[-y+1 -y],'-','Color','black');
                    text(x + 0.02,-y+ 0.7,T(Grafo(nodo).Raggiungibili.Transizione(i)));
                    txt=array2string(Grafo(Grafo(nodo).Raggiungibili.Marcatura(i)).Iniziale);
                    text(x + 0.02,-y+ 0.2,txt);
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
                    if x1==x2
                        x1=x1-0.05;
                        x2=x2-0.05;
                    end
                    if y1==y2
                        y1=y1-0.05;
                        y2=y2-0.05;
                    end
                    %quiver(x1,y1,x2-x1,y2-y1,1,'Color','red');
                    plot([x1 x2],[y1 y2],'Color','red');
                    plot(x2,y2,'>r');
                    txt=T(Grafo(nodo).Raggiungibili.Transizione(i));
                    text((3*x1+x2)/4 + 0.2,(3*y1+y2)/4+ 0.2,txt,'Color','red');
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