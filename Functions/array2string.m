function s=array2string(array)
% array2string è una funzione che converte in stringa un array di numeri.
%
% INPUT:
%    - array:
%      array di numeri
% OUTPUT:
%    - s:
%      stringa correttamente formata: [...]
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Metto il carattere inziale per distinguere il vettore
s='[';
% Metto tutti gli elementi separati con uno spazio e una virgola
for i=1:length(array)-1
    s=[s,' ',num2str(array(i)),','];
end
% L'ultimo termine non deve avere aggiunto anche la virgola, ma la
% parantesi che chiude l'array
s=[s,' ',num2str(array(end)), ']'];
end