function den=denominatore(Ragg,i,u0,u1,u3,u4,u5,u8,u9,u10,n_multiple)
den=0;
alert=0;

for l=1:10
    switch Ragg(i).abi(l)
        
        
        % Si calcola il denominatore da associare al calcolo del U(i,j)
        % scorrendo le varie transizioni con i case che sono in numero pari
        % al numero di transizioni, mentre sono ordinati secondo
        % l'ordinamento che dà Pipe per la I).
        % Si mette alert=1 quando la transizione è immediata.
        % Nella nostra rete ci sono 10 transizioni => 10 case
        case 1  %T0 
            den=den+u0;
        case 2  %T1 
            den=den+u1;
        case 3  %T2
            alert=1;
        case 4  %T3 
            den=den+u3*min([Ragg(i).value(8),Ragg(i).value(10),n_multiple]);
        case 5  %T4
            den=den+u4*min([Ragg(i).value(9),Ragg(i).value(12),n_multiple]);
        case 6  %T5
            den=den+u5*min([Ragg(i).value(11),Ragg(i).value(13),n_multiple]);
        case 7  %T6
            alert=1;
        case 8  %T7 
            alert=1;
        case 9  %T8 
            den=den+u8;
        case 10  %T9 
            den=den+u9;
        case 11
            den=den+u10;
           
    end
end

if alert==1
    den=0;
    
end
end
