inizio= 'B3'%input('Indicare la cella(1,1) della matrice che si vuole leggere(es.C3): ','s');
fine= 'N19' %('Indicare la cella(n,n) della matrice che si vuole leggere(es.Y25): ','s');
due_punti=':';
range=strcat(inizio,due_punti,fine);

[pre]=xlsread('Pre&Incidenza.xlsx',range);
inizio1= 'B22'%input('Indicare la cella(1,1) della matrice che si vuole leggere(es.C3): ','s');
fine1= 'N38'%('Indicare la cella(n,n) della matrice che si vuole leggere(es.Y25): ','s');
range=strcat(inizio1,due_punti,fine1);
[I]=xlsread('Pre&Incidenza.xlsx',range);


