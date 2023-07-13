function s=array2string(array)
% array2string è una funzione che converte in stringa un array di numeri.
%
% INPUT:
%    - array:
%      array di 
% OUTPUT:
%    - s:
%      stringa correttamente formata: [...]
%
% AUTHORS:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

s='[';
for i=1:length(array)-1
    s=[s,' ',num2str(array(i)),','];
end
s=[s,' ',num2str(array(end)), ']'];
end