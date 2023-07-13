function s_a = ServerAttivati(Marcatura,MaxServer,Pre,H)
% ServerAttivati è una funzione che restituisce il numero di server che
% risultano attivati in base alla marcatura presente, al numero di token
% richiesti in ingresso e il numero di server totali.
%
% INPUT:
%    - Marcatura:
%      la marcatura corrente.
%    - MaxServer:
%      il numero massimo di server disponibili.
%    - Input:
%      il numero di token richiesto in input.
% OUTPUT:
%    - s_a:
%      il numero di server che risultano contemporaneamente attivi date le
%      configurazioni presenti.
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

if all(H==0 | (H>0 & Marcatura<H))
    s_a = floor(min(Marcatura./Pre));
    if sum(Pre)==0 || s_a>MaxServer
        s_a=MaxServer;
    end
else
    s_a=0;
end
%     if MaxServer>1
%         load('prova.mat');
%         v_sa=[v_sa s_a];
%         save('prova.mat',"v_sa");
%     end
end

